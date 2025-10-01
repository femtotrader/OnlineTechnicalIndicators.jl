const SHOOTING_STAR_BODY_RATIO = 0.33
const SHOOTING_STAR_SHADOW_RATIO = 2.0
const SHOOTING_STAR_LOWER_SHADOW_TOLERANCE = 0.1

"""
    ShootingStar{Tohlcv}(; body_ratio = SHOOTING_STAR_BODY_RATIO, shadow_ratio = SHOOTING_STAR_SHADOW_RATIO, lower_shadow_tolerance = SHOOTING_STAR_LOWER_SHADOW_TOLERANCE, input_filter = always_true, input_modifier = identity, input_modifier_return_type = Tohlcv)

The `ShootingStar` type implements Shooting Star and Inverted Hammer candlestick pattern detectors.

A Shooting Star is a bearish reversal pattern with a small body at the bottom and a long upper shadow.
An Inverted Hammer is the same pattern but appears at the end of a downtrend (bullish).

# Parameters
- `body_ratio`: Maximum ratio of body to total range (default: 0.33)
- `shadow_ratio`: Minimum ratio of upper shadow to body (default: 2.0)
- `lower_shadow_tolerance`: Maximum ratio of lower shadow to total range (default: 0.1)

# Output
- [`SingleCandlePatternVal`](@ref): Pattern value with SHOOTING_STAR or INVERTED_HAMMER
"""
mutable struct ShootingStar{Tohlcv,IN,S} <: TechnicalIndicatorSingleOutput{Tohlcv}
    value::Union{Missing,SingleCandlePatternVal}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    body_ratio::S
    shadow_ratio::S
    lower_shadow_tolerance::S

    input_modifier::Function
    input_filter::Function
    input_values::CircBuff

    function ShootingStar{Tohlcv}(;
        body_ratio = SHOOTING_STAR_BODY_RATIO,
        shadow_ratio = SHOOTING_STAR_SHADOW_RATIO,
        lower_shadow_tolerance = SHOOTING_STAR_LOWER_SHADOW_TOLERANCE,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        S = hasfield(T2, :close) ? fieldtype(T2, :close) : Float64
        input_values = CircBuff(T2, 1, rev = false)
        new{Tohlcv,true,S}(
            initialize_indicator_common_fields()...,
            body_ratio,
            shadow_ratio,
            lower_shadow_tolerance,
            input_modifier,
            input_filter,
            input_values,
        )
    end
end

function _calculate_new_value(ind::ShootingStar{T,IN,S}) where {T,IN,S}
    candle = ind.input_values[end]

    o = candle.open
    h = candle.high
    l = candle.low
    c = candle.close

    body = abs(c - o)
    total_range = h - l

    # Avoid division by zero
    if total_range == 0 || body == 0
        return SingleCandlePatternVal(
            SingleCandlePatternType.NONE,
            zero(S),
            PatternDirection.NEUTRAL,
        )
    end

    body_to_range = body / total_range
    upper_shadow = h - max(o, c)
    lower_shadow = min(o, c) - l
    lower_to_range = lower_shadow / total_range

    # Check conditions for Shooting Star/Inverted Hammer
    # 1. Small body (< 1/3 of range)
    if body_to_range > ind.body_ratio
        return SingleCandlePatternVal(
            SingleCandlePatternType.NONE,
            zero(S),
            PatternDirection.NEUTRAL,
        )
    end

    # 2. Long upper shadow (>= 2x body)
    if upper_shadow < ind.shadow_ratio * body
        return SingleCandlePatternVal(
            SingleCandlePatternType.NONE,
            zero(S),
            PatternDirection.NEUTRAL,
        )
    end

    # 3. Minimal lower shadow
    if lower_to_range > ind.lower_shadow_tolerance
        return SingleCandlePatternVal(
            SingleCandlePatternType.NONE,
            zero(S),
            PatternDirection.NEUTRAL,
        )
    end

    # Calculate confidence based on how well it fits the ideal pattern
    shadow_to_body_ratio = upper_shadow / body
    shadow_confidence = min(shadow_to_body_ratio / (ind.shadow_ratio * 2), one(S))
    body_confidence = one(S) - (body_to_range / ind.body_ratio)
    lower_confidence = one(S) - (lower_to_range / ind.lower_shadow_tolerance)

    confidence = (shadow_confidence + body_confidence + lower_confidence) / 3

    # Note: We detect SHOOTING_STAR here (bearish). Context would determine if it's
    # an INVERTED_HAMMER (bullish, in downtrend). Users can combine with trend indicators.
    return SingleCandlePatternVal(
        SingleCandlePatternType.SHOOTING_STAR,
        confidence,
        PatternDirection.BEARISH,
    )
end
