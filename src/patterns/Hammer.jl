const HAMMER_BODY_RATIO = 0.33
const HAMMER_SHADOW_RATIO = 2.0
const HAMMER_UPPER_SHADOW_TOLERANCE = 0.1

"""
    Hammer{Tohlcv}(; body_ratio = HAMMER_BODY_RATIO, shadow_ratio = HAMMER_SHADOW_RATIO, upper_shadow_tolerance = HAMMER_UPPER_SHADOW_TOLERANCE, input_filter = always_true, input_modifier = identity, input_modifier_return_type = Tohlcv)

The `Hammer` type implements Hammer and Hanging Man candlestick pattern detectors.

A Hammer is a bullish reversal pattern with a small body at the top and a long lower shadow.
A Hanging Man is the same pattern but appears at the end of an uptrend (bearish).

# Parameters
- `body_ratio`: Maximum ratio of body to total range (default: 0.33)
- `shadow_ratio`: Minimum ratio of lower shadow to body (default: 2.0)
- `upper_shadow_tolerance`: Maximum ratio of upper shadow to total range (default: 0.1)

# Output
- [`SingleCandlePatternVal`](@ref): Pattern value with HAMMER or HANGING_MAN
"""
mutable struct Hammer{Tohlcv,IN,S} <: TechnicalIndicatorSingleOutput{Tohlcv}
    value::Union{Missing,SingleCandlePatternVal}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    body_ratio::S
    shadow_ratio::S
    upper_shadow_tolerance::S

    input_modifier::Function
    input_filter::Function
    input_values::CircBuff

    function Hammer{Tohlcv}(;
        body_ratio = HAMMER_BODY_RATIO,
        shadow_ratio = HAMMER_SHADOW_RATIO,
        upper_shadow_tolerance = HAMMER_UPPER_SHADOW_TOLERANCE,
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
            upper_shadow_tolerance,
            input_modifier,
            input_filter,
            input_values,
        )
    end
end

function _calculate_new_value(ind::Hammer{T,IN,S}) where {T,IN,S}
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
    upper_to_range = upper_shadow / total_range

    # Check conditions for Hammer/Hanging Man
    # 1. Small body (< 1/3 of range)
    if body_to_range > ind.body_ratio
        return SingleCandlePatternVal(
            SingleCandlePatternType.NONE,
            zero(S),
            PatternDirection.NEUTRAL,
        )
    end

    # 2. Long lower shadow (>= 2x body)
    if lower_shadow < ind.shadow_ratio * body
        return SingleCandlePatternVal(
            SingleCandlePatternType.NONE,
            zero(S),
            PatternDirection.NEUTRAL,
        )
    end

    # 3. Minimal upper shadow
    if upper_to_range > ind.upper_shadow_tolerance
        return SingleCandlePatternVal(
            SingleCandlePatternType.NONE,
            zero(S),
            PatternDirection.NEUTRAL,
        )
    end

    # Calculate confidence based on how well it fits the ideal pattern
    shadow_to_body_ratio = lower_shadow / body
    shadow_confidence = min(shadow_to_body_ratio / (ind.shadow_ratio * 2), one(S))
    body_confidence = one(S) - (body_to_range / ind.body_ratio)
    upper_confidence = one(S) - (upper_to_range / ind.upper_shadow_tolerance)

    confidence = (shadow_confidence + body_confidence + upper_confidence) / 3

    # Note: We detect HAMMER here. Context (trend) would determine if it's actually
    # a HANGING_MAN (which appears in uptrend). For now, we classify as bullish HAMMER.
    # Users can combine with trend indicators to distinguish.
    return SingleCandlePatternVal(
        SingleCandlePatternType.HAMMER,
        confidence,
        PatternDirection.BULLISH,
    )
end
