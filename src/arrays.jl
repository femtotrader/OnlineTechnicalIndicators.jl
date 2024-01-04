function apply_func_single_input(
    arr::AbstractArray,
    IND::Type{I},
    args...;
    kwargs...,
) where {I<:TechnicalIndicator}
    ind = IND{eltype(arr)}(args...; kwargs...)
    mapped = map(val -> value(fit!(ind, val)), arr)
    return collect(mapped)
end

function apply_func_candle_input(
    arr::AbstractArray,
    IND::Type{I},
    args...;
    kwargs...,
) where {I<:TechnicalIndicator}
    ind = IND{eltype(arr),eltype(arr).types[1]}(args...; kwargs...)
    mapped = map(val -> value(fit!(ind, val)), arr)
    return collect(mapped)
end

# SISO indicators

SMA(x::AbstractArray, args...; kwargs...) =
    apply_func_single_input(x, SMA, args...; kwargs...)

EMA(x::AbstractArray, args...; kwargs...) =
    apply_func_single_input(x, IncTA.EMA, args...; kwargs...)

SMMA(x::AbstractArray, args...; kwargs...) =
    apply_func_single_input(x, IncTA.SMMA, args...; kwargs...)

RSI(x::AbstractArray, args...; kwargs...) =
    apply_func_single_input(x, IncTA.RSI, args...; kwargs...)

MeanDev(x::AbstractArray, args...; kwargs...) =
    apply_func_single_input(x, IncTA.MeanDev, args...; kwargs...)

StdDev(x::AbstractArray, args...; kwargs...) =
    apply_func_single_input(x, IncTA.StdDev, args...; kwargs...)

ROC(x::AbstractArray, args...; kwargs...) =
    apply_func_single_input(x, IncTA.ROC, args...; kwargs...)

WMA(x::AbstractArray, args...; kwargs...) =
    apply_func_single_input(x, IncTA.WMA, args...; kwargs...)

KAMA(x::AbstractArray, args...; kwargs...) =
    apply_func_single_input(x, IncTA.KAMA, args...; kwargs...)

HMA(x::AbstractArray, args...; kwargs...) =
    apply_func_single_input(x, IncTA.HMA, args...; kwargs...)

DPO(x::AbstractArray, args...; kwargs...) =
    apply_func_single_input(x, IncTA.DPO, args...; kwargs...)

CoppockCurve(x::AbstractArray, args...; kwargs...) =
    apply_func_single_input(x, IncTA.CoppockCurve, args...; kwargs...)

DEMA(x::AbstractArray, args...; kwargs...) =
    apply_func_single_input(x, IncTA.DEMA, args...; kwargs...)

TEMA(x::AbstractArray, args...; kwargs...) =
    apply_func_single_input(x, IncTA.TEMA, args...; kwargs...)

ALMA(x::AbstractArray, args...; kwargs...) =
    apply_func_single_input(x, IncTA.ALMA, args...; kwargs...)

McGinleyDynamic(x::AbstractArray, args...; kwargs...) =
    apply_func_single_input(x, IncTA.McGinleyDynamic, args...; kwargs...)

ZLEMA(x::AbstractArray, args...; kwargs...) =
    apply_func_single_input(x, IncTA.ZLEMA, args...; kwargs...)

T3(x::AbstractArray, args...; kwargs...) =
    apply_func_single_input(x, IncTA.T3, args...; kwargs...)

TRIX(x::AbstractArray, args...; kwargs...) =
    apply_func_single_input(x, IncTA.TRIX, args...; kwargs...)

TSI(x::AbstractArray, args...; kwargs...) =
    apply_func_single_input(x, IncTA.TSI, args...; kwargs...)

# SIMO indicators
BB(x::AbstractArray, args...; kwargs...) =
    apply_func_single_input(x, IncTA.BB, args...; kwargs...)

MACD(x::AbstractArray, args...; kwargs...) =
    apply_func_single_input(x, IncTA.MACD, args...; kwargs...)

StochRSI(x::AbstractArray, args...; kwargs...) =
    apply_func_single_input(x, IncTA.StochRSI, args...; kwargs...)

KST(x::AbstractArray, args...; kwargs...) =
    apply_func_single_input(x, IncTA.KST, args...; kwargs...)

# MISO indicators
AccuDist(x::AbstractArray, args...; kwargs...) =
    apply_func_candle_input(x, IncTA.AccuDist, args...; kwargs...)

BOP(x::AbstractArray, args...; kwargs...) =
    apply_func_candle_input(x, IncTA.BOP, args...; kwargs...)

CCI(x::AbstractArray, args...; kwargs...) =
    apply_func_candle_input(x, IncTA.CCI, args...; kwargs...)

ChaikinOsc(x::AbstractArray, args...; kwargs...) =
    apply_func_candle_input(x, IncTA.ChaikinOsc, args...; kwargs...)

VWMA(x::AbstractArray, args...; kwargs...) =
    apply_func_candle_input(x, IncTA.VWMA, args...; kwargs...)

VWAP(x::AbstractArray, args...; kwargs...) =
    apply_func_candle_input(x, IncTA.VWAP, args...; kwargs...)

AO(x::AbstractArray, args...; kwargs...) =
    apply_func_candle_input(x, IncTA.AO, args...; kwargs...)

ATR(x::AbstractArray, args...; kwargs...) =
    apply_func_candle_input(x, IncTA.ATR, args...; kwargs...)

ForceIndex(x::AbstractArray, args...; kwargs...) =
    apply_func_candle_input(x, IncTA.ForceIndex, args...; kwargs...)

OBV(x::AbstractArray, args...; kwargs...) =
    apply_func_candle_input(x, IncTA.OBV, args...; kwargs...)

SOBV(x::AbstractArray, args...; kwargs...) =
    apply_func_candle_input(x, IncTA.SOBV, args...; kwargs...)

EMV(x::AbstractArray, args...; kwargs...) =
    apply_func_candle_input(x, IncTA.EMV, args...; kwargs...)

Stoch(x::AbstractArray, args...; kwargs...) =
    apply_func_candle_input(x, IncTA.Stoch, args...; kwargs...)

MassIndex(x::AbstractArray, args...; kwargs...) =
    apply_func_candle_input(x, IncTA.MassIndex, args...; kwargs...)

CHOP(x::AbstractArray, args...; kwargs...) =
    apply_func_candle_input(x, IncTA.CHOP, args...; kwargs...)

ADX(x::AbstractArray, args...; kwargs...) =
    apply_func_candle_input(x, IncTA.ADX, args...; kwargs...)

KVO(x::AbstractArray, args...; kwargs...) =
    apply_func_candle_input(x, IncTA.KVO, args...; kwargs...)

UO(x::AbstractArray, args...; kwargs...) =
    apply_func_candle_input(x, IncTA.UO, args...; kwargs...)


# MIMO indicators

SuperTrend(x::AbstractArray, args...; kwargs...) =
    apply_func_candle_input(x, IncTA.SuperTrend, args...; kwargs...)

VTX(x::AbstractArray, args...; kwargs...) =
    apply_func_candle_input(x, IncTA.VTX, args...; kwargs...)

DonchianChannels(x::AbstractArray, args...; kwargs...) =
    apply_func_candle_input(x, IncTA.DonchianChannels, args...; kwargs...)

KeltnerChannels(x::AbstractArray, args...; kwargs...) =
    apply_func_candle_input(x, IncTA.KeltnerChannels, args...; kwargs...)

Aroon(x::AbstractArray, args...; kwargs...) =
    apply_func_candle_input(x, IncTA.Aroon, args...; kwargs...)

ChandeKrollStop(x::AbstractArray, args...; kwargs...) =
    apply_func_candle_input(x, IncTA.ChandeKrollStop, args...; kwargs...)

ParabolicSAR(x::AbstractArray, args...; kwargs...) =
    apply_func_candle_input(x, IncTA.ParabolicSAR, args...; kwargs...)

SFX(x::AbstractArray, args...; kwargs...) =
    apply_func_candle_input(x, IncTA.SFX, args...; kwargs...)

TTM(x::AbstractArray, args...; kwargs...) =
    apply_func_candle_input(x, IncTA.TTM, args...; kwargs...)

function PivotsHL(x::AbstractArray, args...; kwargs...)
    ind = PivotsHL{eltype(x),eltype(x).types[1]}(memory = length(x), args...; kwargs...)
    for val in x
        fit!(ind, val)
    end
    return value(ind.output_values)
end

# Others indicators
STC(x::AbstractArray, args...; kwargs...) =
    apply_func_single_input(x, IncTA.STC, args...; kwargs...)
