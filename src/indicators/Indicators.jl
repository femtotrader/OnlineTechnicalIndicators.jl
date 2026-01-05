"""
    OnlineTechnicalIndicators.Indicators

The Indicators module provides access to all technical indicators for financial analysis.

# Categories
- **SISO (Single Input, Single Output)**: SMA, EMA, RSI, MACD, etc.
- **SIMO (Single Input, Multiple Output)**: BB, MACD, StochRSI, KST
- **MISO (Multiple Input, Single Output)**: AccuDist, ATR, OBV, etc.
- **MIMO (Multiple Input, Multiple Output)**: Stoch, ADX, SuperTrend, etc.

# Usage

```julia
using OnlineTechnicalIndicators.Indicators

# Create indicators
sma = SMA{Float64}(period=14)
ema = EMA{Float64}(period=10)
rsi = RSI{Float64}(period=14)

# Feed data
for price in prices
    fit!(sma, price)
    fit!(ema, price)
    fit!(rsi, price)
end

# Get values
println(value(sma))
println(value(ema))
println(value(rsi))
```

See also: [`OnlineTechnicalIndicators.Patterns`](@ref)
"""
module Indicators

# Import base types from parent module
using ..OnlineTechnicalIndicators:
    TechnicalIndicator,
    TechnicalIndicatorSingleOutput,
    TechnicalIndicatorMultiOutput,
    MovingAverageIndicator,
    OHLCV,
    MovingAverage,
    DAGWrapper,
    ValueExtractor,
    has_output_value,
    has_valid_values,
    always_true

# Import functions for extension (allows adding methods to parent's functions)
import ..OnlineTechnicalIndicators: is_valid, has_output_value, ismultiinput
import ..OnlineTechnicalIndicators: _calculate_new_value, _calculate_new_value_only_from_incoming_data

using OnlineStatsBase
using OnlineStatsBase: CircBuff, Series, nobs, value, fit!
using OnlineStatsChains

# Indicator category lists (for reference)
const SISO_INDICATORS = [
    "SMA",
    "EMA",
    "SMMA",
    "RSI",
    "MeanDev",
    "StdDev",
    "ROC",
    "WMA",
    "KAMA",
    "HMA",
    "DPO",
    "CoppockCurve",
    "DEMA",
    "TEMA",
    "ALMA",
    "McGinleyDynamic",
    "ZLEMA",
    "T3",
    "TRIX",
    "TSI",
]

const SIMO_INDICATORS = ["BB", "MACD", "StochRSI", "KST"]

const MISO_INDICATORS = [
    "AccuDist",
    "BOP",
    "CCI",
    "ChaikinOsc",
    "VWMA",
    "VWAP",
    "AO",
    "TrueRange",
    "ATR",
    "ForceIndex",
    "OBV",
    "SOBV",
    "EMV",
    "MassIndex",
    "CHOP",
    "KVO",
    "UO",
    "NATR",
    "MFI",
    "IntradayRange",
    "RelativeIntradayRange",
    "ADR",
    "ARDR",
]

const MIMO_INDICATORS = [
    "Stoch",
    "ADX",
    "SuperTrend",
    "VTX",
    "DonchianChannels",
    "KeltnerChannels",
    "Aroon",
    "ChandeKrollStop",
    "ParabolicSAR",
    "SFX",
    "TTM",
    "PivotsHL",
    "GannHiloActivator",
    "GannSwingChart",
    "PeakValleyDetector",
    "RetracementCalculator",
    "SupportResistanceLevel",
]

const OTHERS_INDICATORS = ["STC"]

# Include SISO indicators
for ind in SISO_INDICATORS
    include("$(ind).jl")
end

# Include SIMO indicators
for ind in SIMO_INDICATORS
    include("$(ind).jl")
end

# Include Smoother (after MA indicators are defined, before MISO indicators that use it)
include("../wrappers/smoother.jl")

# Include MISO indicators
for ind in MISO_INDICATORS
    include("$(ind).jl")
end

# Include MIMO indicators
for ind in MIMO_INDICATORS
    include("$(ind).jl")
end

# Include OTHER indicators
for ind in OTHERS_INDICATORS
    include("$(ind).jl")
end

# Export SISO indicators
export SMA, EMA, SMMA, RSI, MeanDev, StdDev, ROC, WMA, KAMA, HMA
export DPO, CoppockCurve, DEMA, TEMA, ALMA, McGinleyDynamic, ZLEMA, T3, TRIX, TSI

# Export SIMO indicators and their value types
export BB, BBVal
export MACD, MACDVal
export StochRSI, StochRSIVal
export KST, KSTVal

# Export Smoother
export Smoother

# Export MISO indicators
export AccuDist, BOP, CCI, ChaikinOsc, VWMA, VWAP, AO
export TrueRange, ATR, ForceIndex, OBV, SOBV, EMV, MassIndex
export CHOP, KVO, UO, NATR, MFI
export IntradayRange, RelativeIntradayRange, ADR, ARDR

# Export MIMO indicators and their value types
export Stoch, StochVal
export ADX, ADXVal
export SuperTrend, SuperTrendVal
export VTX, VTXVal
export DonchianChannels, DonchianChannelsVal
export KeltnerChannels, KeltnerChannelsVal
export Aroon, AroonVal
export ChandeKrollStop, ChandeKrollStopVal
export ParabolicSAR, SARTrend
export SFX, SFXVal
export TTM, TTMVal
export PivotsHL, PivotsHLVal
export GannHiloActivator, GannHiloActivatorVal
export GannSwingChart, GannSwingChartVal
export PeakValleyDetector, PeakValleyVal
export RetracementCalculator, RetracementVal
export SupportResistanceLevel, SupportResistanceLevelVal

# Export additional types
export Trend, HLType

# Export OTHER indicators
export STC

# Export indicator category lists (for testing and introspection)
export SISO_INDICATORS, SIMO_INDICATORS, MISO_INDICATORS, MIMO_INDICATORS, OTHERS_INDICATORS

# ismultiinput definitions for indicators
ismultiinput(::Type{SMA}) = false
ismultiinput(::Type{EMA}) = false
ismultiinput(::Type{SMMA}) = false
ismultiinput(::Type{RSI}) = false
ismultiinput(::Type{MeanDev}) = false
ismultiinput(::Type{StdDev}) = false
ismultiinput(::Type{ROC}) = false
ismultiinput(::Type{WMA}) = false
ismultiinput(::Type{KAMA}) = false
ismultiinput(::Type{HMA}) = false
ismultiinput(::Type{DPO}) = false
ismultiinput(::Type{CoppockCurve}) = false
ismultiinput(::Type{DEMA}) = false
ismultiinput(::Type{TEMA}) = false
ismultiinput(::Type{ALMA}) = false
ismultiinput(::Type{McGinleyDynamic}) = false
ismultiinput(::Type{ZLEMA}) = false
ismultiinput(::Type{T3}) = false
ismultiinput(::Type{TRIX}) = false
ismultiinput(::Type{TSI}) = false
# SIMO
ismultiinput(::Type{BB}) = false
ismultiinput(::Type{MACD}) = false
ismultiinput(::Type{StochRSI}) = false
ismultiinput(::Type{KST}) = false
# MISO
ismultiinput(::Type{AccuDist}) = true
ismultiinput(::Type{BOP}) = true
ismultiinput(::Type{CCI}) = true
ismultiinput(::Type{ChaikinOsc}) = true
ismultiinput(::Type{VWMA}) = true
ismultiinput(::Type{VWAP}) = true
ismultiinput(::Type{AO}) = true
ismultiinput(::Type{TrueRange}) = true
ismultiinput(::Type{ATR}) = true
ismultiinput(::Type{ForceIndex}) = true
ismultiinput(::Type{OBV}) = true
ismultiinput(::Type{SOBV}) = true
ismultiinput(::Type{EMV}) = true
ismultiinput(::Type{MassIndex}) = true
ismultiinput(::Type{CHOP}) = true
ismultiinput(::Type{KVO}) = true
ismultiinput(::Type{UO}) = true
ismultiinput(::Type{NATR}) = true
ismultiinput(::Type{MFI}) = true
ismultiinput(::Type{IntradayRange}) = true
ismultiinput(::Type{RelativeIntradayRange}) = true
ismultiinput(::Type{ADR}) = true
ismultiinput(::Type{ARDR}) = true
# Utility types
ismultiinput(::Type{Smoother}) = true
# MIMO
ismultiinput(::Type{Stoch}) = true
ismultiinput(::Type{ADX}) = true
ismultiinput(::Type{SuperTrend}) = true
ismultiinput(::Type{VTX}) = true
ismultiinput(::Type{DonchianChannels}) = true
ismultiinput(::Type{KeltnerChannels}) = true
ismultiinput(::Type{Aroon}) = true
ismultiinput(::Type{ChandeKrollStop}) = true
ismultiinput(::Type{ParabolicSAR}) = true
ismultiinput(::Type{SFX}) = true
ismultiinput(::Type{TTM}) = true
ismultiinput(::Type{PivotsHL}) = true
ismultiinput(::Type{GannHiloActivator}) = true
ismultiinput(::Type{GannSwingChart}) = true
ismultiinput(::Type{PeakValleyDetector}) = true
ismultiinput(::Type{RetracementCalculator}) = true
ismultiinput(::Type{SupportResistanceLevel}) = true
# Other
ismultiinput(::Type{STC}) = false

# Include array convenience functions (e.g., SMA(array; period=...))
include("../other/arrays_indicators.jl")

end  # module Indicators
