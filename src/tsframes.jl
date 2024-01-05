using TSFrames

using IncTA
using IncTA: TechnicalIndicator, expected_return_type
using IncTA.SampleData: OPEN_TMPL, HIGH_TMPL, LOW_TMPL, CLOSE_TMPL, VOLUME_TMPL, DATE_TMPL

using TSFrames
using TSFrames: Not, select!

const INPUT_FIELD = :Close
const INPUT_FIELDS = [:Open, :High, :Low, :Close, :Volume]

const OHLCV_TSFRAME = TSFrame(
    [OPEN_TMPL HIGH_TMPL LOW_TMPL CLOSE_TMPL VOLUME_TMPL],
    DATE_TMPL,
    colnames = INPUT_FIELDS,
)

function apply_func_SISO(
    ts::TSFrame,
    IND::Type{I},
    input_field::Symbol,
    output_field::Symbol,
    args...;
    kwargs...,
) where {I<:TechnicalIndicator}
    vct = ts[:, input_field]
    ind = IND{eltype(vct)}(args...; kwargs...)
    mapped = map(val -> value(fit!(ind, val)), vct)
    return TSFrame(collect(mapped), index(ts), colnames = [output_field])
end

@generated fieldvalues(x) = Expr(:tuple, (:(x.$f) for f in fieldnames(x))...)

function apply_func_SIMO(
    ts::TSFrame,
    IND::Type{I},
    input_field::Symbol,
    output_field::Symbol,
    args...;
    kwargs...,
) where {I<:TechnicalIndicator}
    vct = ts[:, input_field]
    ind = IND{eltype(vct)}(args...; kwargs...)
    Tout = expected_return_type(ind)  # type of return (BBVal, ...)
    return_types = fieldtypes(Tout)  # types of each field of indicator return
    results = Vector{Union{Missing,Tout}}()
    for val in vct
        fit!(ind, val)
        ret = value(ind)
        t = fieldvalues(ret)
        println(t)
        println(length(return_types))
        if length(t) != length(return_types)
            push!(results, missing)
        else
            push!(results, Tout(t...))
        end

    end
    ts_result = TSFrame(results, index(ts))
    for field in fieldnames(Tout)
        colname = String(output_field) * "_" * String(field)
        ts_result.coredata[:, colname] = map(
            ret -> hasproperty(ret, field) ? getproperty(ret, field) : missing,
            ts_result.coredata[:, :x1],
        )
    end
    select!(ts_result.coredata, Not([:x1]))
    return ts_result
end


#= eachrow
        opn = row[INPUT_FIELDS[2]]
        hig = row[INPUT_FIELDS[3]]
        low = row[INPUT_FIELDS[4]]
        cls = row[INPUT_FIELDS[5]]
        vol = row[INPUT_FIELDS[6]]
        tim = row[INPUT_FIELDS[1]]
        candle = OHLCV(opn, hig, low, cls, volume = vol, time = tim)

=#


# SISO
SMA(x::TSFrame, input_field = INPUT_FIELD, args...; kwargs...) =
    apply_func_SISO(x, IncTA.SMA, input_field, :SMA, args...; kwargs...)

EMA(x::TSFrame, input_field = INPUT_FIELD, args...; kwargs...) =
    apply_func_SISO(x, IncTA.EMA, input_field, :EMA, args...; kwargs...)

SMMA(x::TSFrame, input_field = INPUT_FIELD, args...; kwargs...) =
    apply_func_SISO(x, IncTA.SMMA, input_field, :SMMA, args...; kwargs...)

RSI(x::TSFrame, input_field = INPUT_FIELD, args...; kwargs...) =
    apply_func_SISO(x, IncTA.RSI, input_field, :RSI, args...; kwargs...)

MeanDev(x::TSFrame, input_field = INPUT_FIELD, args...; kwargs...) =
    apply_func_SISO(x, IncTA.MeanDev, input_field, :MeanDev, args...; kwargs...)

StdDev(x::TSFrame, input_field = INPUT_FIELD, args...; kwargs...) =
    apply_func_SISO(x, IncTA.StdDev, input_field, :StdDev, args...; kwargs...)

ROC(x::TSFrame, input_field = INPUT_FIELD, args...; kwargs...) =
    apply_func_SISO(x, IncTA.ROC, input_field, :ROC, args...; kwargs...)

WMA(x::TSFrame, input_field = INPUT_FIELD, args...; kwargs...) =
    apply_func_SISO(x, IncTA.WMA, input_field, :WMA, args...; kwargs...)

KAMA(x::TSFrame, input_field = INPUT_FIELD, args...; kwargs...) =
    apply_func_SISO(x, IncTA.KAMA, input_field, :KAMA, args...; kwargs...)

HMA(x::TSFrame, input_field = INPUT_FIELD, args...; kwargs...) =
    apply_func_SISO(x, IncTA.HMA, input_field, :HMA, args...; kwargs...)

DPO(x::TSFrame, input_field = INPUT_FIELD, args...; kwargs...) =
    apply_func_SISO(x, IncTA.DPO, input_field, :DPO, args...; kwargs...)

CoppockCurve(x::TSFrame, input_field = INPUT_FIELD, args...; kwargs...) =
    apply_func_SISO(x, IncTA.CoppockCurve, input_field, :CoppockCurve, args...; kwargs...)

DEMA(x::TSFrame, input_field = INPUT_FIELD, args...; kwargs...) =
    apply_func_SISO(x, IncTA.DEMA, input_field, :DEMA, args...; kwargs...)

TEMA(x::TSFrame, input_field = INPUT_FIELD, args...; kwargs...) =
    apply_func_SISO(x, IncTA.TEMA, input_field, :TEMA, args...; kwargs...)

ALMA(x::TSFrame, input_field = INPUT_FIELD, args...; kwargs...) =
    apply_func_SISO(x, IncTA.ALMA, input_field, :ALMA, args...; kwargs...)

McGinleyDynamic(x::TSFrame, input_field = INPUT_FIELD, args...; kwargs...) =
    apply_func_SISO(
        x,
        IncTA.McGinleyDynamic,
        input_field,
        :McGinleyDynamic,
        args...;
        kwargs...,
    )

ZLEMA(x::TSFrame, input_field = INPUT_FIELD, args...; kwargs...) =
    apply_func_SISO(x, IncTA.ZLEMA, input_field, :ZLEMA, args...; kwargs...)

T3(x::TSFrame, input_field = INPUT_FIELD, args...; kwargs...) =
    apply_func_SISO(x, IncTA.T3, input_field, :T3, args...; kwargs...)

TRIX(x::TSFrame, input_field = INPUT_FIELD, args...; kwargs...) =
    apply_func_SISO(x, IncTA.TRIX, input_field, :TRIX, args...; kwargs...)

TSI(x::TSFrame, input_field = INPUT_FIELD, args...; kwargs...) =
    apply_func_SISO(x, IncTA.TSI, input_field, :TSI, args...; kwargs...)

# SIMO
BB(x::TSFrame, input_field = INPUT_FIELD, args...; kwargs...) =
    apply_func_SIMO(x, IncTA.BB, input_field, :BB, args...; kwargs...)
MACD(x::TSFrame, input_field = INPUT_FIELD, args...; kwargs...) =
    apply_func_SIMO(x, IncTA.MACD, input_field, :MACD, args...; kwargs...)
StochRSI(x::TSFrame, input_field = INPUT_FIELD, args...; kwargs...) = 
    apply_func_SIMO(x, IncTA.StochRSI, input_field, :StochRSI, args...; kwargs...)
KST(x::TSFrame, input_field = INPUT_FIELD, args...; kwargs...) = 
    apply_func_SIMO(x, IncTA.KST, input_field, :KST, args...; kwargs...)

# MISO

# MIMO

#SMA(OHLCV_TSFRAME)
#ZLEMA(OHLCV_TSFRAME)

#BB(OHLCV_TSFRAME)
#MACD(OHLCV_TSFRAME)
#StochRSI(OHLCV_TSFRAME)
#KST(OHLCV_TSFRAME)
