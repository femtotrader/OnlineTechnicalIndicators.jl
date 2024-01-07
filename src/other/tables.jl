using Tables
using IncTA: ismultiinput

struct TechnicalIndicatorWrapper{T}
    indicator_type::T
    args::Tuple
    kwargs::Base.Pairs
    function TechnicalIndicatorWrapper(indicator_type, args...; kwargs...)
        new{typeof(indicator_type)}(indicator_type, args, kwargs)
    end
end

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

Base.names(results::TechnicalIndicatorResults) = [Symbol("$(results.name)_$(fieldname)") for fieldname in results.fieldnames]
Tables.istable(::Type{<:TechnicalIndicatorResults}) = true
Tables.schema(results::TechnicalIndicatorResults) = Tables.Schema([:Index, names(results)...], [eltype(results.index), (Union{Missing,typ} for typ in results.fieldtypes)...])
Tables.rowaccess(::Type{<:TechnicalIndicatorResults}) = true

@generated fieldvalues(x) = Expr(:tuple, (:(x.$f) for f in fieldnames(x))...)
function Tables.rows(results::TechnicalIndicatorResults)
    _names = names(results)
    n = length(_names)
    if n == 1  # results from a single output indicator
        return (NamedTuple{(:Index, names(results)...)}( (idx, !ismissing(vals) ? vals : missing) ) for (idx, vals) in zip(results.index, results.output))  #works with single output indicators
    else  # results from a multi output indicator
        println(_names, " ", n)
        throw(ErrorException("WIP"))
        val_to_tup = val -> !ismissing(val) ? fieldvalues(val) : ntuple(i->missing, n)
        return (NamedTuple{(:Index, names(results)...)}( (idx, (val_to_tup(val) for val in vals)... ) for (idx, vals) in zip(results.index, results.output)))
    end
end


function load!(
    table,
    ti_wrap::TechnicalIndicatorWrapper;
    default = :Close,
    index = :Index,
    candle = [:Open, :High, :Low, :Close],
    volume = :Volume,
)
    rows = Tables.rows(table)
    sch = Tables.schema(table)
    _names = sch.names  # name of columns of input

    Ttime = index ∈ sch.names ? Tables.columntype(sch, index) : Missing
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
