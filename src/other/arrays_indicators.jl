# Array convenience functions for the Indicators module
# These functions are included directly in the Indicators module, so they use
# direct type references (e.g., SMA, not Indicators.SMA)

function _apply_indicator_to_array(
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

SMA(x::AbstractArray, args...; kwargs...) = _apply_indicator_to_array(x, SMA, args...; kwargs...)

EMA(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, EMA, args...; kwargs...)

SMMA(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, SMMA, args...; kwargs...)

RSI(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, RSI, args...; kwargs...)

MeanDev(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, MeanDev, args...; kwargs...)

StdDev(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, StdDev, args...; kwargs...)

ROC(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, ROC, args...; kwargs...)

WMA(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, WMA, args...; kwargs...)

KAMA(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, KAMA, args...; kwargs...)

HMA(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, HMA, args...; kwargs...)

DPO(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, DPO, args...; kwargs...)

CoppockCurve(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, CoppockCurve, args...; kwargs...)

DEMA(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, DEMA, args...; kwargs...)

TEMA(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, TEMA, args...; kwargs...)

ALMA(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, ALMA, args...; kwargs...)

McGinleyDynamic(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, McGinleyDynamic, args...; kwargs...)

ZLEMA(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, ZLEMA, args...; kwargs...)

T3(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, T3, args...; kwargs...)

TRIX(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, TRIX, args...; kwargs...)

TSI(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, TSI, args...; kwargs...)

# SIMO indicators

BB(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, BB, args...; kwargs...)

MACD(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, MACD, args...; kwargs...)

StochRSI(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, StochRSI, args...; kwargs...)

KST(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, KST, args...; kwargs...)

# MISO indicators

AccuDist(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, AccuDist, args...; kwargs...)

BOP(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, BOP, args...; kwargs...)

CCI(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, CCI, args...; kwargs...)

ChaikinOsc(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, ChaikinOsc, args...; kwargs...)

VWMA(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, VWMA, args...; kwargs...)

VWAP(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, VWAP, args...; kwargs...)

AO(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, AO, args...; kwargs...)

TrueRange(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, TrueRange, args...; kwargs...)

ATR(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, ATR, args...; kwargs...)

ForceIndex(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, ForceIndex, args...; kwargs...)

OBV(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, OBV, args...; kwargs...)

SOBV(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, SOBV, args...; kwargs...)

EMV(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, EMV, args...; kwargs...)

MassIndex(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, MassIndex, args...; kwargs...)

CHOP(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, CHOP, args...; kwargs...)

KVO(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, KVO, args...; kwargs...)

UO(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, UO, args...; kwargs...)

NATR(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, NATR, args...; kwargs...)

MFI(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, MFI, args...; kwargs...)

IntradayRange(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, IntradayRange, args...; kwargs...)

RelativeIntradayRange(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, RelativeIntradayRange, args...; kwargs...)

ADR(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, ADR, args...; kwargs...)

ARDR(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, ARDR, args...; kwargs...)

# Utility types - Smoother with array

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
using OnlineTechnicalIndicators.Indicators
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

Stoch(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, Stoch, args...; kwargs...)

ADX(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, ADX, args...; kwargs...)

SuperTrend(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, SuperTrend, args...; kwargs...)

VTX(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, VTX, args...; kwargs...)

DonchianChannels(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, DonchianChannels, args...; kwargs...)

KeltnerChannels(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, KeltnerChannels, args...; kwargs...)

Aroon(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, Aroon, args...; kwargs...)

ChandeKrollStop(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, ChandeKrollStop, args...; kwargs...)

ParabolicSAR(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, ParabolicSAR, args...; kwargs...)

SFX(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, SFX, args...; kwargs...)

TTM(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, TTM, args...; kwargs...)

GannHiloActivator(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, GannHiloActivator, args...; kwargs...)

GannSwingChart(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, GannSwingChart, args...; kwargs...)

PeakValleyDetector(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, PeakValleyDetector, args...; kwargs...)

RetracementCalculator(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, RetracementCalculator, args...; kwargs...)

SupportResistanceLevel(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, SupportResistanceLevel, args...; kwargs...)

function PivotsHL(x::AbstractArray, args...; kwargs...)
    ind = PivotsHL{eltype(x)}(memory = length(x), args...; kwargs...)
    for val in x
        fit!(ind, val)
    end
    return value(ind.output_values)
end

# Others indicators
STC(x::AbstractArray, args...; kwargs...) =
    _apply_indicator_to_array(x, STC, args...; kwargs...)
