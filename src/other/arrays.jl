function apply_func(
    arr::AbstractArray,
    IND::Type{I},
    args...;
    kwargs...,
) where {I<:TechnicalIndicator}
    ind = IND{eltype(arr)}(args...; kwargs...)
    mapped = map(val -> value(fit!(ind, val)), arr)
    return collect(mapped)
end

# SISO indicators

SMA(x::AbstractArray, args...; kwargs...) = apply_func(x, SMA, args...; kwargs...)

EMA(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.EMA, args...; kwargs...)

SMMA(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.SMMA, args...; kwargs...)

RSI(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.RSI, args...; kwargs...)

MeanDev(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.MeanDev, args...; kwargs...)

StdDev(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.StdDev, args...; kwargs...)

ROC(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.ROC, args...; kwargs...)

WMA(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.WMA, args...; kwargs...)

KAMA(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.KAMA, args...; kwargs...)

HMA(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.HMA, args...; kwargs...)

DPO(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.DPO, args...; kwargs...)

CoppockCurve(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.CoppockCurve, args...; kwargs...)

DEMA(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.DEMA, args...; kwargs...)

TEMA(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.TEMA, args...; kwargs...)

ALMA(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.ALMA, args...; kwargs...)

McGinleyDynamic(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.McGinleyDynamic, args...; kwargs...)

ZLEMA(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.ZLEMA, args...; kwargs...)

T3(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.T3, args...; kwargs...)

TRIX(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.TRIX, args...; kwargs...)

TSI(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.TSI, args...; kwargs...)

# SIMO indicators

BB(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.BB, args...; kwargs...)

MACD(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.MACD, args...; kwargs...)

StochRSI(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.StochRSI, args...; kwargs...)

KST(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.KST, args...; kwargs...)

# MISO indicators

AccuDist(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.AccuDist, args...; kwargs...)

BOP(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.BOP, args...; kwargs...)

CCI(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.CCI, args...; kwargs...)

ChaikinOsc(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.ChaikinOsc, args...; kwargs...)

VWMA(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.VWMA, args...; kwargs...)

VWAP(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.VWAP, args...; kwargs...)

AO(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.AO, args...; kwargs...)

TrueRange(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.TrueRange, args...; kwargs...)

ATR(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.ATR, args...; kwargs...)

ForceIndex(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.ForceIndex, args...; kwargs...)

OBV(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.OBV, args...; kwargs...)

SOBV(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.SOBV, args...; kwargs...)

EMV(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.EMV, args...; kwargs...)

Stoch(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.Stoch, args...; kwargs...)

MassIndex(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.MassIndex, args...; kwargs...)

CHOP(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.CHOP, args...; kwargs...)

ADX(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.ADX, args...; kwargs...)

KVO(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.KVO, args...; kwargs...)

UO(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.UO, args...; kwargs...)

NATR(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.NATR, args...; kwargs...)

MFI(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.MFI, args...; kwargs...)

IntradayRange(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.IntradayRange, args...; kwargs...)

RelativeIntradayRange(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.RelativeIntradayRange, args...; kwargs...)

ADR(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.ADR, args...; kwargs...)

ARDR(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.ARDR, args...; kwargs...)

# Utility types

"""
    Smoother(x::AbstractArray, InnerType::Type{<:TechnicalIndicator}; period, ma, kwargs...)

Apply a Smoother to an array of OHLCV data.

# Arguments
- `x::AbstractArray`: Input array of OHLCV data
- `InnerType::Type{<:TechnicalIndicator}`: The inner indicator type to smooth (e.g., TrueRange, IntradayRange)
- `period::Integer`: The number of periods for the moving average
- `ma::Type`: The moving average type (e.g., SMA, EMA, SMMA)

# Example
```julia
using OnlineTechnicalIndicators
ohlcv_data = [OHLCV(10.0, 11.0, 9.0, 10.5, volume=100.0), ...]
result = Smoother(ohlcv_data, TrueRange; period=14, ma=SMMA)
```
"""
function Smoother(x::AbstractArray, InnerType::Type{<:TechnicalIndicator}, args...; kwargs...)
    ind = Smoother{eltype(x)}(InnerType, args...; kwargs...)
    mapped = map(val -> value(fit!(ind, val)), x)
    return collect(mapped)
end

# MIMO indicators

SuperTrend(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.SuperTrend, args...; kwargs...)

VTX(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.VTX, args...; kwargs...)

DonchianChannels(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.DonchianChannels, args...; kwargs...)

KeltnerChannels(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.KeltnerChannels, args...; kwargs...)

Aroon(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.Aroon, args...; kwargs...)

ChandeKrollStop(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.ChandeKrollStop, args...; kwargs...)

ParabolicSAR(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.ParabolicSAR, args...; kwargs...)

SFX(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.SFX, args...; kwargs...)

TTM(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.TTM, args...; kwargs...)

GannHiloActivator(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.GannHiloActivator, args...; kwargs...)

GannSwingChart(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.GannSwingChart, args...; kwargs...)

PeakValleyDetector(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.PeakValleyDetector, args...; kwargs...)

RetracementCalculator(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.RetracementCalculator, args...; kwargs...)

SupportResistanceLevel(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.SupportResistanceLevel, args...; kwargs...)

function PivotsHL(x::AbstractArray, args...; kwargs...)
    ind = PivotsHL{eltype(x)}(memory = length(x), args...; kwargs...)
    for val in x
        fit!(ind, val)
    end
    return value(ind.output_values)
end

# Others indicators
STC(x::AbstractArray, args...; kwargs...) =
    apply_func(x, OnlineTechnicalIndicators.STC, args...; kwargs...)
