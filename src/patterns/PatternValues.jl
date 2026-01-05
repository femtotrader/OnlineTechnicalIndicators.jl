"""
Return value types for pattern detection indicators.
"""

# Pattern type modules are defined in PatternTypes.jl which is included before this file
# They are available in the current scope (Patterns module) via include

"""
    SingleCandlePatternVal{T}

Return value type for single candlestick pattern indicators.

# Fields
- `pattern::SingleCandlePatternType.SingleCandlePattern`: The detected pattern
- `confidence::T`: Confidence level (0.0 to 1.0)
- `direction::PatternDirection.Direction`: Pattern direction (BULLISH, BEARISH, NEUTRAL)
"""
struct SingleCandlePatternVal{T}
    pattern::SingleCandlePatternType.SingleCandlePattern
    confidence::T
    direction::PatternDirection.Direction
end

"""
    TwoCandlePatternVal{T}

Return value type for two-candle pattern indicators.

# Fields
- `pattern::TwoCandlePatternType.TwoCandlePattern`: The detected pattern
- `confidence::T`: Confidence level (0.0 to 1.0)
- `direction::PatternDirection.Direction`: Pattern direction (BULLISH, BEARISH, NEUTRAL)
"""
struct TwoCandlePatternVal{T}
    pattern::TwoCandlePatternType.TwoCandlePattern
    confidence::T
    direction::PatternDirection.Direction
end

"""
    ThreeCandlePatternVal{T}

Return value type for three-candle pattern indicators.

# Fields
- `pattern::ThreeCandlePatternType.ThreeCandlePattern`: The detected pattern
- `confidence::T`: Confidence level (0.0 to 1.0)
- `direction::PatternDirection.Direction`: Pattern direction (BULLISH, BEARISH, NEUTRAL)
"""
struct ThreeCandlePatternVal{T}
    pattern::ThreeCandlePatternType.ThreeCandlePattern
    confidence::T
    direction::PatternDirection.Direction
end

# Helper functions to check if a pattern was detected
is_detected(val::SingleCandlePatternVal) = val.pattern != SingleCandlePatternType.NONE
is_detected(val::TwoCandlePatternVal) = val.pattern != TwoCandlePatternType.NONE
is_detected(val::ThreeCandlePatternVal) = val.pattern != ThreeCandlePatternType.NONE

# Helper to check validity
is_valid(val::Union{SingleCandlePatternVal,TwoCandlePatternVal,ThreeCandlePatternVal}) =
    !ismissing(val) && is_detected(val) && val.confidence > 0
