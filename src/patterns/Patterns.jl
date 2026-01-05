"""
    OnlineTechnicalIndicators.Patterns

The Patterns module provides access to all candlestick pattern recognition indicators.

# Categories
- **Single Candle Patterns**: Doji, Hammer, ShootingStar, Marubozu, SpinningTop
- **Two Candle Patterns**: Engulfing, Harami, PiercingDarkCloud, Tweezer
- **Three Candle Patterns**: Star, ThreeSoldiersCrows, ThreeInside
- **Composite Detector**: CandlestickPatternDetector

# Usage

```julia
using OnlineTechnicalIndicators.Patterns

# Create pattern detectors
doji = Doji{OHLCV{Missing,Float64,Float64}}()
hammer = Hammer{OHLCV{Missing,Float64,Float64}}()

# Or use the comprehensive detector
detector = CandlestickPatternDetector{OHLCV{Missing,Float64,Float64}}()

# Feed data
for candle in candles
    fit!(doji, candle)
    fit!(detector, candle)
end

# Get values
println(value(doji))
println(value(detector))
```

See also: [`OnlineTechnicalIndicators.Indicators`](@ref)
"""
module Patterns

# Import base types from parent module
using ..OnlineTechnicalIndicators:
    TechnicalIndicator,
    TechnicalIndicatorSingleOutput,
    TechnicalIndicatorMultiOutput

# Import from Candlesticks submodule
using ..OnlineTechnicalIndicators.Candlesticks: OHLCV

# Import from Internals submodule
using ..OnlineTechnicalIndicators.Internals:
    has_output_value,
    has_valid_values,
    always_true,
    is_valid

# Import functions for extension (allows adding methods to Internals functions)
import ..OnlineTechnicalIndicators.Internals: is_multi_input, is_valid
import ..OnlineTechnicalIndicators.Internals: _calculate_new_value, _calculate_new_value_only_from_incoming_data

using OnlineStatsBase
using OnlineStatsBase: CircBuff, Series, nobs, value, fit!

# Pattern type lists
const SINGLE_CANDLE_PATTERNS = ["Doji", "Hammer", "ShootingStar", "Marubozu", "SpinningTop"]

const TWO_CANDLE_PATTERNS = ["Engulfing", "Harami", "PiercingDarkCloud", "Tweezer"]

const THREE_CANDLE_PATTERNS = ["Star", "ThreeSoldiersCrows", "ThreeInside"]

# Include pattern type enumerations first
include("PatternTypes.jl")

# Include pattern value types (depends on PatternTypes)
include("PatternValues.jl")

# Include single candle patterns
for pattern in SINGLE_CANDLE_PATTERNS
    include("$(pattern).jl")
end

# Include two candle patterns
for pattern in TWO_CANDLE_PATTERNS
    include("$(pattern).jl")
end

# Include three candle patterns
for pattern in THREE_CANDLE_PATTERNS
    include("$(pattern).jl")
end

# Include composite detector (depends on all other patterns)
include("CandlestickPatternDetector.jl")

# Export pattern type modules and enums
export SingleCandlePatternType, TwoCandlePatternType, ThreeCandlePatternType, PatternDirection

# Export pattern value types
export SingleCandlePatternVal, TwoCandlePatternVal, ThreeCandlePatternVal, AllPatternsVal

# Export helper functions
export is_detected, has_patterns, count_patterns

# Export single candle pattern detectors
export Doji, Hammer, ShootingStar, Marubozu, SpinningTop

# Export two candle pattern detectors
export Engulfing, Harami, PiercingDarkCloud, Tweezer

# Export three candle pattern detectors
export Star, ThreeSoldiersCrows, ThreeInside

# Export composite detector
export CandlestickPatternDetector

# is_multi_input definitions for pattern detectors
is_multi_input(::Type{Doji}) = true
is_multi_input(::Type{Hammer}) = true
is_multi_input(::Type{ShootingStar}) = true
is_multi_input(::Type{Marubozu}) = true
is_multi_input(::Type{SpinningTop}) = true
is_multi_input(::Type{Engulfing}) = true
is_multi_input(::Type{Harami}) = true
is_multi_input(::Type{PiercingDarkCloud}) = true
is_multi_input(::Type{Tweezer}) = true
is_multi_input(::Type{Star}) = true
is_multi_input(::Type{ThreeSoldiersCrows}) = true
is_multi_input(::Type{ThreeInside}) = true
is_multi_input(::Type{CandlestickPatternDetector}) = true

end  # module Patterns
