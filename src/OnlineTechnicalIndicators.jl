module OnlineTechnicalIndicators

export OHLCV, OHLCVFactory, ValueExtractor
export fit!

# Re-export from Wrappers submodule
export Smoother, DAGWrapper

# Re-export from Factories submodule
export MovingAverage, MAFactory

export SampleData
export ArraysInterface

# Export submodules for direct access
export Wrappers, Factories

SISO_INDICATORS = [
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
SIMO_INDICATORS = ["BB", "MACD", "StochRSI", "KST"]
MISO_INDICATORS = [
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
MIMO_INDICATORS = [
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
# More complex indicators (for example STC is SISO but uses MIMO indicator such as Stoch with input_modifier)
OTHERS_INDICATORS = ["STC"]

# Pattern Recognition Indicators
PATTERN_INDICATORS = [
    "Doji",
    "Hammer",
    "ShootingStar",
    "Marubozu",
    "SpinningTop",
    "Engulfing",
    "Harami",
    "PiercingDarkCloud",
    "Tweezer",
    "Star",
    "ThreeSoldiersCrows",
    "ThreeInside",
    "CandlestickPatternDetector",
]

ALL_INDICATORS = [
    SISO_INDICATORS...,
    SIMO_INDICATORS...,
    MISO_INDICATORS...,
    MIMO_INDICATORS...,
    OTHERS_INDICATORS...,
    PATTERN_INDICATORS...,
]

# Export indicators
for ind in ALL_INDICATORS
    ind = Symbol(ind)
    @eval export $ind
end
export SARTrend, Trend, HLType
export GannHiloActivatorVal,
    GannSwingChartVal, PeakValleyVal, RetracementVal, SupportResistanceLevelVal

# Export pattern recognition types and modules
export SingleCandlePatternType,
    TwoCandlePatternType, ThreeCandlePatternType, PatternDirection
export SingleCandlePatternVal, TwoCandlePatternVal, ThreeCandlePatternVal, AllPatternsVal

# Export pattern recognition types and modules
export SingleCandlePatternType,
    TwoCandlePatternType, ThreeCandlePatternType, PatternDirection
export SingleCandlePatternVal, TwoCandlePatternVal, ThreeCandlePatternVal, AllPatternsVal

export add_input_indicator!

using OnlineStatsBase
export value

abstract type TechnicalIndicator{T} <: OnlineStat{T} end
abstract type TechnicalIndicatorSingleOutput{T} <: TechnicalIndicator{T} end
abstract type TechnicalIndicatorMultiOutput{T} <: TechnicalIndicator{T} end
abstract type MovingAverageIndicator{T} <: TechnicalIndicatorSingleOutput{T} end

include("stats.jl")
include("ohlcv.jl")
include("sample_data.jl")

# Include MovingAverage factory (needed by SISO indicators like DEMA)
include("factories/MovingAverage.jl")

# Include DAGWrapper (needed by SISO indicators like DEMA, TEMA, T3, TRIX)
include("wrappers/dag.jl")

ismultioutput(ind::Type{O}) where {O<:TechnicalIndicator} =
    ind <: TechnicalIndicatorMultiOutput
expected_return_type(ind::O) where {O<:TechnicalIndicatorSingleOutput} =
    typeof(ind).parameters[end]
function expected_return_type(ind::O) where {O<:TechnicalIndicatorMultiOutput}
    retval = String(nameof(typeof(ind))) * "Val"  # return value as String "BBVal", "MACDVal"...
    RETVAL = eval(Meta.parse(retval))
    return RETVAL{typeof(ind).parameters[end]}
end

function expected_return_type(IND::Type{O}) where {O<:TechnicalIndicatorMultiOutput}
    retval = String(nameof(IND)) * "Val"  # return value as String "BBVal", "MACDVal"...
    RETVAL = eval(Meta.parse(retval))
    return RETVAL
end

function OnlineStatsBase._fit!(ind::O, data) where {O<:TechnicalIndicator}
    _fieldnames = fieldnames(O)
    # Only apply input_filter/input_modifier if they exist (legacy indicators)
    # StatDAG-based indicators (DEMA, TEMA, T3, TRIX) don't have these fields
    if :input_filter in _fieldnames && :input_modifier in _fieldnames
        if ind.input_filter(data)
            data = ind.input_modifier(data)
        else
            return nothing
        end
    end
    has_input_values = :input_values in _fieldnames
    if has_input_values
        fit!(ind.input_values, data)
    end
    has_sub_indicators =
        :sub_indicators in _fieldnames && length(ind.sub_indicators.stats) > 0
    if has_sub_indicators
        fit!(ind.sub_indicators, data)
    end
    ind.n += 1
    ind.value =
        (has_input_values || has_sub_indicators) ? _calculate_new_value(ind) :
        _calculate_new_value_only_from_incoming_data(ind, data)
    fit_listeners!(ind)
end

is_valid(::Missing) = false

function has_output_value(ind::O) where {O<:OnlineStat}
    return !ismissing(value(ind))
end


function has_output_value(cb::CircBuff)
    if length(cb.value) > 0
        return !ismissing(cb[end])
    else
        return false
    end
end

#=
function has_valid_values(cb::CircBuff, period)
    try
        _has_valid_values = true
        for i in 1:period
            _has_valid_values = _has_valid_values && !ismissing(cb[end-i+1])
        end
        return _has_valid_values
    catch
        return false
    end
end
=#

function has_valid_values(sequence::CircBuff, window; exact = false)
    if !exact
        return length(sequence) >= window && !ismissing(sequence[end-window+1])
    else
        return (length(sequence) == window && !ismissing(sequence[end-window+1])) || (
            length(sequence) > window &&
            !ismissing(sequence[end-window+1]) &&
            ismissing(sequence[end-window])
        )
    end
end

function fit_listeners!(ind::O) where {O<:TechnicalIndicator}
    # Legacy function - no longer used with StatDAG-based indicators
    # Kept for backward compatibility but does nothing
    return
end

"""
    add_input_indicator!(ind2, ind1)

**DEPRECATED**: This function is deprecated. Use `OnlineStatsChains.StatDAG` to chain indicators instead.

# Migration Guide
Instead of using `add_input_indicator!` to chain indicators:

```julia
# Old way (deprecated):
ema1 = EMA(period=10)
ema2 = EMA(period=10)
add_input_indicator!(ema2, ema1)
```

Use `OnlineStatsChains.StatDAG` with filtered edges:

```julia
# New way (recommended):
using OnlineStatsChains

dag = StatDAG()
add_node!(dag, :ema1, EMA(period=10))
add_node!(dag, :ema2, EMA(period=10))
connect!(dag, :ema1, :ema2, filter = !ismissing)

# Feed data to the first node
fit!(dag, :ema1 => data)

# Get values from any node
value(dag, :ema1)  # First EMA
value(dag, :ema2)  # Second EMA (automatically updated)
```

See the implementations of DEMA, TEMA, T3, and TRIX for complete examples.
"""
function add_input_indicator!(
    ind2::O1,
    ind1::O2,
) where {O1<:TechnicalIndicator,O2<:TechnicalIndicator}
    error(
        "add_input_indicator! is no longer functional as the required fields (input_indicator, output_listeners) have been removed. Use OnlineStatsChains.StatDAG to chain indicators. See documentation for migration guide.",
    )
end

always_true(x) = true

function Base.setindex!(o::CircBuff, val, i::Int)
    if nobs(o) ≤ length(o.rng.rng)
        o.value[i] = val
    else
        o.value[o.rng[nobs(o)+i]] = val
    end
end
function Base.setindex!(o::CircBuff{<:Any,true}, val, i::Int)
    i = length(o.value) - i + 1
    if nobs(o) ≤ length(o.rng.rng)
        o.value[i] = val
    else
        o.value[o.rng[nobs(o)+i]] = val
    end
end

# include pattern types first
include("patterns/PatternTypes.jl")
using .SingleCandlePatternType
using .TwoCandlePatternType
using .ThreeCandlePatternType
using .PatternDirection

include("patterns/PatternValues.jl")

# include SISO and SIMO indicators first (no dependencies on Smoother)
for ind in [
    SISO_INDICATORS...,
    SIMO_INDICATORS...,
]
    include("indicators/$(ind).jl")
end

# Include Smoother (after MA indicators are defined, before MISO indicators that use it)
include("wrappers/smoother.jl")

# include MISO, MIMO and OTHERS indicators
for ind in [
    MISO_INDICATORS...,
    MIMO_INDICATORS...,
    OTHERS_INDICATORS...,
]
    include("indicators/$(ind).jl")
end

# include pattern indicators
for ind in PATTERN_INDICATORS
    include("patterns/$(ind).jl")
end

# ismultiinput
# ismultiinput(ind::O) where {O<:TechnicalIndicator} = typeof(ind).parameters[2]
# SISO
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
# Utility types (not in indicator lists)
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
# Pattern Recognition
ismultiinput(::Type{Doji}) = true
ismultiinput(::Type{Hammer}) = true
ismultiinput(::Type{ShootingStar}) = true
ismultiinput(::Type{Marubozu}) = true
ismultiinput(::Type{SpinningTop}) = true
ismultiinput(::Type{Engulfing}) = true
ismultiinput(::Type{Harami}) = true
ismultiinput(::Type{PiercingDarkCloud}) = true
ismultiinput(::Type{Tweezer}) = true
ismultiinput(::Type{Star}) = true
ismultiinput(::Type{ThreeSoldiersCrows}) = true
ismultiinput(::Type{ThreeInside}) = true
ismultiinput(::Type{CandlestickPatternDetector}) = true

# Other stuff
include("resample.jl")

# Integration with Julia ecosystem (Arrays, Iterators...)
include("other/arrays.jl")
include("other/iterators.jl")
include("other/tables.jl")

# Include re-export modules (must be at the end after all types are defined)
include("wrappers/Wrappers.jl")
include("factories/Factories.jl")

end
