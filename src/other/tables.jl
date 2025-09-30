using Tables
using OnlineTechnicalIndicators: ismultiinput

const DEFAULT_FIELD_DEFAULT = :Close
const DEFAULT_FIELD_INDEX = :Index
const DEFAULT_FIELDS_CANDLE = [:Open, :High, :Low, :Close]
const DEFAULT_FIELD_VOLUME = :Volume
const DEFAULT_OTHERS_POSSIBLE_INDEX = [:timestamp]

"""
    TechnicalIndicatorWrapper{T}

Wraps a technical indicator type with its constructor arguments for deferred instantiation.

# Fields
- `indicator_type::T`: The type of technical indicator to construct
- `args::Tuple`: Positional arguments for the indicator constructor
- `kwargs::Base.Pairs`: Keyword arguments for the indicator constructor
"""
struct TechnicalIndicatorWrapper{T}
    indicator_type::T
    args::Tuple
    kwargs::Base.Pairs
    function TechnicalIndicatorWrapper(indicator_type, args...; kwargs...)
        new{typeof(indicator_type)}(indicator_type, args, kwargs)
    end
end

"""
    TechnicalIndicatorResults{Ttime,Tout}

Container for technical indicator results implementing the Tables.jl interface.

# Fields
- `name::Symbol`: Name of the indicator
- `fieldnames::Tuple`: Names of the output fields
- `fieldtypes::Tuple`: Types of the output fields
- `index::Vector{Ttime}`: Vector of timestamps/indices
- `output::Vector{Tout}`: Vector of indicator output values
"""
struct TechnicalIndicatorResults{Ttime,Tout}
    name::Symbol
    fieldnames::Tuple
    fieldtypes::Tuple

    index::Vector{Ttime}
    output::Vector{Tout}

    function TechnicalIndicatorResults{Ttime,Tout}(
        name,
        fieldnames,
        fieldtypes,
    ) where {Ttime,Tout}
        new{Ttime,Tout}(name, fieldnames, fieldtypes, Ttime[], Tout[])
    end
end

function Base.push!(results::TechnicalIndicatorResults, result)
    (tim, val) = result
    push!(results.index, tim)
    push!(results.output, val)
end

function Base.names(results::TechnicalIndicatorResults)
    if length(results.fieldnames) == 1
        return [results.name]
    else
        return [Symbol("$(results.name)_$(fieldname)") for fieldname in results.fieldnames]
    end
end
Tables.istable(::Type{<:TechnicalIndicatorResults}) = true
Tables.schema(results::TechnicalIndicatorResults) = Tables.Schema(
    [:Index, names(results)...],
    [eltype(results.index), (Union{Missing,typ} for typ in results.fieldtypes)...],
)
Tables.rowaccess(::Type{<:TechnicalIndicatorResults}) = true

@generated fieldvalues(x) = Expr(:tuple, (:(x.$f) for f in fieldnames(x))...)
function Tables.rows(results::TechnicalIndicatorResults)
    _names = names(results)
    n = length(_names)
    if n == 1  # results from a single output indicator
        return (
            NamedTuple{(:Index, names(results)...)}((
                idx,
                !ismissing(vals) ? vals : missing,
            )) for (idx, vals) in zip(results.index, results.output)
        )  #works with single output indicators
    else  # results from a multi output indicator
        val_to_tup = val -> !ismissing(val) ? fieldvalues(val) : ntuple(i -> missing, n)
        z = zip(results.index, results.output)
        _values = ((idx, val_to_tup(vals)...) for (idx, vals) in z)
        _names = (:Index, names(results)...)
        return (NamedTuple{_names}(val) for val in _values)
    end
end

function load!(
    table,
    ti_wrap::TechnicalIndicatorWrapper;
    default = DEFAULT_FIELD_DEFAULT,
    index = DEFAULT_FIELD_INDEX,
    others_possible_index = DEFAULT_OTHERS_POSSIBLE_INDEX,
    candle = DEFAULT_FIELDS_CANDLE,
    volume = DEFAULT_FIELD_VOLUME,
)
    rows = Tables.rows(table)
    sch = Tables.schema(table)
    _names = sch.names  # name of columns of input

    Ttime = index ∈ sch.names ? Tables.columntype(sch, index) : Missing
    if index ∉ sch.names
        index = collect(intersect(Set(sch.names), Set(others_possible_index)))[1]
        Ttime = Tables.columntype(sch, index)
    end
    Tin =
        default ∈ sch.names ? Tables.columntype(sch, default) :
        throw(ArgumentError("default field `$default` not found"))
    if !ismultioutput(ti_wrap.indicator_type)
        Tout = Union{Missing,Tin}
        _expected_return_type = Tin
        results = TechnicalIndicatorResults{Ttime,Tout}(
            Symbol(ti_wrap.indicator_type),
            (:value,),
            (Tin,),
        )
    else
        Tout = Union{Missing,expected_return_type(ti_wrap.indicator_type){Tin}}
        _expected_return_type = expected_return_type(ti_wrap.indicator_type){Tin}
        results = TechnicalIndicatorResults{Ttime,Tout}(
            Symbol(ti_wrap.indicator_type),
            fieldnames(_expected_return_type),
            fieldtypes(_expected_return_type),
        )
    end

    if !ismultiinput(ti_wrap.indicator_type)
        ind = ti_wrap.indicator_type{Tin}(ti_wrap.args...; ti_wrap.kwargs...)
        for row in rows
            tim = index ∈ _names ? row[index] : missing
            data = row[default]
            fit!(ind, data)
            push!(results, (tim, value(ind)))
        end
    else
        Ttime = index ∈ sch.names ? Tables.columntype(sch, index) : Missing
        Tprice = Tin
        Tvol = volume ∈ sch.names ? Tables.columntype(sch, volume) : Missing
        ind = ti_wrap.indicator_type{OHLCV{Ttime,Tprice,Tvol}}(
            ti_wrap.args...;
            ti_wrap.kwargs...,
        )
        for candle_field in candle
            (candle_field ∉ _names) && throw(
                ArgumentError(
                    "field `$candle_field` not found - $candle are expected in input data",
                ),
            )
        end
        for row in rows
            tim = index ∈ _names ? row[index] : missing
            opn = row[candle[1]]
            hig = row[candle[2]]
            low = row[candle[3]]
            cls = row[candle[4]]
            vol = volume ∈ _names ? row[volume] : missing
            data = OHLCV(opn, hig, low, cls, volume = vol, time = tim)
            fit!(ind, data)
            push!(results, (tim, value(ind)))
        end
    end
    return results
end


# More convenient functions
function apply_ti(
    indicator_type,
    table,
    args...;
    default = DEFAULT_FIELD_DEFAULT,
    index = DEFAULT_FIELD_INDEX,
    others_possible_index = DEFAULT_OTHERS_POSSIBLE_INDEX,
    candle = DEFAULT_FIELDS_CANDLE,
    volume = DEFAULT_FIELD_VOLUME,
    kwargs...,
)
    ti_wrap = TechnicalIndicatorWrapper(indicator_type, args...; kwargs...)
    result = load!(
        table,
        ti_wrap;
        default = default,
        index = index,
        others_possible_index = others_possible_index,
        candle = candle,
        volume = volume,
    )
    return typeof(table)(result)
end

# SISO_INDICATORS
SMA(table, args...; kwargs...) = apply_ti(SMA, table, args...; kwargs...)
EMA(table, args...; kwargs...) = apply_ti(EMA, table, args...; kwargs...)
SMMA(table, args...; kwargs...) = apply_ti(SMMA, table, args...; kwargs...)
RSI(table, args...; kwargs...) = apply_ti(RSI, table, args...; kwargs...)
MeanDev(table, args...; kwargs...) = apply_ti(MeanDev, table, args...; kwargs...)
StdDev(table, args...; kwargs...) = apply_ti(StdDev, table, args...; kwargs...)
ROC(table, args...; kwargs...) = apply_ti(ROC, table, args...; kwargs...)
WMA(table, args...; kwargs...) = apply_ti(WMA, table, args...; kwargs...)
KAMA(table, args...; kwargs...) = apply_ti(KAMA, table, args...; kwargs...)
HMA(table, args...; kwargs...) = apply_ti(HMA, table, args...; kwargs...)
DPO(table, args...; kwargs...) = apply_ti(DPO, table, args...; kwargs...)
CoppockCurve(table, args...; kwargs...) = apply_ti(CoppockCurve, table, args...; kwargs...)
DEMA(table, args...; kwargs...) = apply_ti(DEMA, table, args...; kwargs...)
TEMA(table, args...; kwargs...) = apply_ti(TEMA, table, args...; kwargs...)
ALMA(table, args...; kwargs...) = apply_ti(ALMA, table, args...; kwargs...)
McGinleyDynamic(table, args...; kwargs...) =
    apply_ti(McGinleyDynamic, table, args...; kwargs...)
ZLEMA(table, args...; kwargs...) = apply_ti(ZLEMA, table, args...; kwargs...)
T3(table, args...; kwargs...) = apply_ti(T3, table, args...; kwargs...)
TRIX(table, args...; kwargs...) = apply_ti(TRIX, table, args...; kwargs...)
TSI(table, args...; kwargs...) = apply_ti(TSI, table, args...; kwargs...)

# SIMO_INDICATORS
BB(table, args...; kwargs...) = apply_ti(BB, table, args...; kwargs...)
MACD(table, args...; kwargs...) = apply_ti(MACD, table, args...; kwargs...)
StochRSI(table, args...; kwargs...) = apply_ti(StochRSI, table, args...; kwargs...)
KST(table, args...; kwargs...) = apply_ti(KST, table, args...; kwargs...)

# MISO_INDICATORS
AccuDist(table, args...; kwargs...) = apply_ti(AccuDist, table, args...; kwargs...)
BOP(table, args...; kwargs...) = apply_ti(BOP, table, args...; kwargs...)
CCI(table, args...; kwargs...) = apply_ti(CCI, table, args...; kwargs...)
ChaikinOsc(table, args...; kwargs...) = apply_ti(ChaikinOsc, table, args...; kwargs...)
VWMA(table, args...; kwargs...) = apply_ti(VWMA, table, args...; kwargs...)
VWAP(table, args...; kwargs...) = apply_ti(VWAP, table, args...; kwargs...)
AO(table, args...; kwargs...) = apply_ti(AO, table, args...; kwargs...)
ATR(table, args...; kwargs...) = apply_ti(ATR, table, args...; kwargs...)
ForceIndex(table, args...; kwargs...) = apply_ti(ForceIndex, table, args...; kwargs...)
OBV(table, args...; kwargs...) = apply_ti(OBV, table, args...; kwargs...)
SOBV(table, args...; kwargs...) = apply_ti(SOBV, table, args...; kwargs...)
EMV(table, args...; kwargs...) = apply_ti(EMV, table, args...; kwargs...)
MassIndex(table, args...; kwargs...) = apply_ti(MassIndex, table, args...; kwargs...)
CHOP(table, args...; kwargs...) = apply_ti(CHOP, table, args...; kwargs...)
KVO(table, args...; kwargs...) = apply_ti(KVO, table, args...; kwargs...)
UO(table, args...; kwargs...) = apply_ti(UO, table, args...; kwargs...)

# MIMO_INDICATORS
Stoch(table, args...; kwargs...) = apply_ti(Stoch, table, args...; kwargs...)
ADX(table, args...; kwargs...) = apply_ti(ADX, table, args...; kwargs...)
SuperTrend(table, args...; kwargs...) = apply_ti(SuperTrend, table, args...; kwargs...)
VTX(table, args...; kwargs...) = apply_ti(VTX, table, args...; kwargs...)
DonchianChannels(table, args...; kwargs...) =
    apply_ti(DonchianChannels, table, args...; kwargs...)
KeltnerChannels(table, args...; kwargs...) =
    apply_ti(KeltnerChannels, table, args...; kwargs...)
Aroon(table, args...; kwargs...) = apply_ti(Aroon, table, args...; kwargs...)
ChandeKrollStop(table, args...; kwargs...) =
    apply_ti(ChandeKrollStop, table, args...; kwargs...)
ParabolicSAR(table, args...; kwargs...) = apply_ti(ParabolicSAR, table, args...; kwargs...)
SFX(table, args...; kwargs...) = apply_ti(SFX, table, args...; kwargs...)
TTM(table, args...; kwargs...) = apply_ti(TTM, table, args...; kwargs...)
PivotsHL(table, args...; kwargs...) = apply_ti(PivotsHL, table, args...; kwargs...)

# OTHERS_INDICATORS
STC(table, args...; kwargs...) = apply_ti(STC, table, args...; kwargs...)
