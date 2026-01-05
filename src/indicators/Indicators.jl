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
    MovingAverage,
    DAGWrapper

# Import from Candlesticks submodule
using ..OnlineTechnicalIndicators.Candlesticks: OHLCV, ValueExtractor

# Import from Internals submodule
using ..OnlineTechnicalIndicators.Internals:
    has_output_value,
    has_valid_values,
    always_true,
    is_valid

# Import functions for extension (allows adding methods to Internals functions)
import ..OnlineTechnicalIndicators.Internals: is_multi_input, has_output_value, is_valid
import ..OnlineTechnicalIndicators.Internals: _calculate_new_value, _calculate_new_value_only_from_incoming_data

using OnlineStatsBase
using OnlineStatsBase: CircBuff, Series, nobs, value, fit!
using OnlineStatsChains

# Re-export fit! and value for user convenience
export fit!, value

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

# is_multi_input definitions for indicators
is_multi_input(::Type{SMA}) = false
is_multi_input(::Type{EMA}) = false
is_multi_input(::Type{SMMA}) = false
is_multi_input(::Type{RSI}) = false
is_multi_input(::Type{MeanDev}) = false
is_multi_input(::Type{StdDev}) = false
is_multi_input(::Type{ROC}) = false
is_multi_input(::Type{WMA}) = false
is_multi_input(::Type{KAMA}) = false
is_multi_input(::Type{HMA}) = false
is_multi_input(::Type{DPO}) = false
is_multi_input(::Type{CoppockCurve}) = false
is_multi_input(::Type{DEMA}) = false
is_multi_input(::Type{TEMA}) = false
is_multi_input(::Type{ALMA}) = false
is_multi_input(::Type{McGinleyDynamic}) = false
is_multi_input(::Type{ZLEMA}) = false
is_multi_input(::Type{T3}) = false
is_multi_input(::Type{TRIX}) = false
is_multi_input(::Type{TSI}) = false
# SIMO
is_multi_input(::Type{BB}) = false
is_multi_input(::Type{MACD}) = false
is_multi_input(::Type{StochRSI}) = false
is_multi_input(::Type{KST}) = false
# MISO
is_multi_input(::Type{AccuDist}) = true
is_multi_input(::Type{BOP}) = true
is_multi_input(::Type{CCI}) = true
is_multi_input(::Type{ChaikinOsc}) = true
is_multi_input(::Type{VWMA}) = true
is_multi_input(::Type{VWAP}) = true
is_multi_input(::Type{AO}) = true
is_multi_input(::Type{TrueRange}) = true
is_multi_input(::Type{ATR}) = true
is_multi_input(::Type{ForceIndex}) = true
is_multi_input(::Type{OBV}) = true
is_multi_input(::Type{SOBV}) = true
is_multi_input(::Type{EMV}) = true
is_multi_input(::Type{MassIndex}) = true
is_multi_input(::Type{CHOP}) = true
is_multi_input(::Type{KVO}) = true
is_multi_input(::Type{UO}) = true
is_multi_input(::Type{NATR}) = true
is_multi_input(::Type{MFI}) = true
is_multi_input(::Type{IntradayRange}) = true
is_multi_input(::Type{RelativeIntradayRange}) = true
is_multi_input(::Type{ADR}) = true
is_multi_input(::Type{ARDR}) = true
# Utility types
is_multi_input(::Type{Smoother}) = true
# MIMO
is_multi_input(::Type{Stoch}) = true
is_multi_input(::Type{ADX}) = true
is_multi_input(::Type{SuperTrend}) = true
is_multi_input(::Type{VTX}) = true
is_multi_input(::Type{DonchianChannels}) = true
is_multi_input(::Type{KeltnerChannels}) = true
is_multi_input(::Type{Aroon}) = true
is_multi_input(::Type{ChandeKrollStop}) = true
is_multi_input(::Type{ParabolicSAR}) = true
is_multi_input(::Type{SFX}) = true
is_multi_input(::Type{TTM}) = true
is_multi_input(::Type{PivotsHL}) = true
is_multi_input(::Type{GannHiloActivator}) = true
is_multi_input(::Type{GannSwingChart}) = true
is_multi_input(::Type{PeakValleyDetector}) = true
is_multi_input(::Type{RetracementCalculator}) = true
is_multi_input(::Type{SupportResistanceLevel}) = true
# Other
is_multi_input(::Type{STC}) = false

# Include array convenience functions (e.g., SMA(array; period=...))
include("../other/arrays_indicators.jl")

# Include Tables.jl convenience functions (e.g., SMA(tsframe; period=...))
include("../other/tables_indicators.jl")

end  # module Indicators
