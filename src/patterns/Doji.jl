const DOJI_BODY_TOLERANCE = 0.1

"""
    Doji{Tohlcv}(; body_tolerance = DOJI_BODY_TOLERANCE, input_modifier_return_type = Tohlcv)

The `Doji` type implements a Doji candlestick pattern detector.

A Doji is characterized by having an open and close that are virtually equal,
indicating indecision in the market.

# Parameters
- `body_tolerance`: Maximum ratio of body size to full range to be considered a Doji (default: 0.1)

# Output
- [`SingleCandlePatternVal`](@ref): Pattern value with detected Doji type, confidence, and direction
"""
mutable struct Doji{Tohlcv,IN,S} <: TechnicalIndicatorSingleOutput{Tohlcv}
    value::Union{Missing,SingleCandlePatternVal}
    n::Int

    body_tolerance::S

    input_values::CircBuff

    function Doji{Tohlcv}(;
        body_tolerance = DOJI_BODY_TOLERANCE,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        S = hasfield(T2, :close) ? fieldtype(T2, :close) : Float64
        input_values = CircBuff(T2, 1, rev = false)
        new{Tohlcv,true,S}(missing, 0, body_tolerance, input_values)
    end
end

function _calculate_new_value(ind::Doji{T,IN,S}) where {T,IN,S}
    candle = ind.input_values[end]

    o = candle.open
    h = candle.high
    l = candle.low
    c = candle.close

    body = abs(c - o)
    total_range = h - l

    # Avoid division by zero
    if total_range == 0
        return missing
    end

    body_ratio = body / total_range

    # Not a Doji if body is too large
    if body_ratio > ind.body_tolerance
        return SingleCandlePatternVal(
            SingleCandlePatternType.NONE,
            zero(S),
            PatternDirection.NEUTRAL,
        )
    end

    # Calculate confidence (closer to 0 body ratio = higher confidence)
    confidence = one(S) - (body_ratio / ind.body_tolerance)

    # Determine Doji type
    upper_shadow = h - max(o, c)
    lower_shadow = min(o, c) - l

    # Dragonfly Doji: long lower shadow, no upper shadow
    if lower_shadow > 2 * body && upper_shadow < ind.body_tolerance * total_range
        return SingleCandlePatternVal(
            SingleCandlePatternType.DRAGONFLY_DOJI,
            confidence,
            PatternDirection.BULLISH,
        )
    end

    # Gravestone Doji: long upper shadow, no lower shadow
    if upper_shadow > 2 * body && lower_shadow < ind.body_tolerance * total_range
        return SingleCandlePatternVal(
            SingleCandlePatternType.GRAVESTONE_DOJI,
            confidence,
            PatternDirection.BEARISH,
        )
    end

    # Standard Doji
    return SingleCandlePatternVal(
        SingleCandlePatternType.DOJI,
        confidence,
        PatternDirection.NEUTRAL,
    )
end
