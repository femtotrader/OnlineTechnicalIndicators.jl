const SPINNING_TOP_BODY_RATIO = 0.25
const SPINNING_TOP_MIN_SHADOW_RATIO = 0.3

"""
    SpinningTop{Tohlcv}(; body_ratio = SPINNING_TOP_BODY_RATIO, min_shadow_ratio = SPINNING_TOP_MIN_SHADOW_RATIO, input_modifier_return_type = Tohlcv)

The `SpinningTop` type implements Spinning Top candlestick pattern detector.

A Spinning Top has a small body with relatively long shadows on both sides, indicating
indecision with buying and selling pressure roughly equal.

# Parameters
- `body_ratio`: Maximum ratio of body to total range (default: 0.25)
- `min_shadow_ratio`: Minimum ratio of each shadow to total range (default: 0.3)

# Output
- [`SingleCandlePatternVal`](@ref): Pattern value with SPINNING_TOP
"""
mutable struct SpinningTop{Tohlcv,IN,S} <: TechnicalIndicatorSingleOutput{Tohlcv}
    value::Union{Missing,SingleCandlePatternVal}
    n::Int

    body_ratio::S
    min_shadow_ratio::S

    input_values::CircBuff

    function SpinningTop{Tohlcv}(;
        body_ratio = SPINNING_TOP_BODY_RATIO,
        min_shadow_ratio = SPINNING_TOP_MIN_SHADOW_RATIO,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        S = hasfield(T2, :close) ? fieldtype(T2, :close) : Float64
        input_values = CircBuff(T2, 1, rev = false)
        new{Tohlcv,true,S}(
            missing,
            0,
            body_ratio,
            min_shadow_ratio,
            input_values,
        )
    end
end

function _calculate_new_value(ind::SpinningTop{T,IN,S}) where {T,IN,S}
    candle = ind.input_values[end]

    o = candle.open
    h = candle.high
    l = candle.low
    c = candle.close

    body = abs(c - o)
    total_range = h - l

    # Avoid division by zero
    if total_range == 0
        return SingleCandlePatternVal(
            SingleCandlePatternType.NONE,
            zero(S),
            PatternDirection.NEUTRAL,
        )
    end

    body_to_range = body / total_range
    upper_shadow = h - max(o, c)
    lower_shadow = min(o, c) - l

    upper_ratio = upper_shadow / total_range
    lower_ratio = lower_shadow / total_range

    # Check conditions for Spinning Top
    # 1. Small body (< 25% of range)
    if body_to_range > ind.body_ratio
        return SingleCandlePatternVal(
            SingleCandlePatternType.NONE,
            zero(S),
            PatternDirection.NEUTRAL,
        )
    end

    # 2. Both shadows should be significant (>= 30% each)
    if upper_ratio < ind.min_shadow_ratio || lower_ratio < ind.min_shadow_ratio
        return SingleCandlePatternVal(
            SingleCandlePatternType.NONE,
            zero(S),
            PatternDirection.NEUTRAL,
        )
    end

    # Calculate confidence based on symmetry and body size
    shadow_symmetry = one(S) - abs(upper_ratio - lower_ratio)
    body_confidence = one(S) - (body_to_range / ind.body_ratio)
    shadow_strength = (min(upper_ratio, lower_ratio) / ind.min_shadow_ratio)

    confidence = (shadow_symmetry + body_confidence + min(shadow_strength, one(S))) / 3

    return SingleCandlePatternVal(
        SingleCandlePatternType.SPINNING_TOP,
        confidence,
        PatternDirection.NEUTRAL,
    )
end
