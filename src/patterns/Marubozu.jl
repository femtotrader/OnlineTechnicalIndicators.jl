const MARUBOZU_SHADOW_TOLERANCE = 0.05

"""
    Marubozu{Tohlcv}(; shadow_tolerance = MARUBOZU_SHADOW_TOLERANCE, input_modifier_return_type = Tohlcv)

The `Marubozu` type implements Marubozu candlestick pattern detector.

A Marubozu is characterized by having little to no shadows (wicks), indicating strong
directional momentum. A bullish Marubozu closes at/near the high, a bearish one closes at/near the low.

# Parameters
- `shadow_tolerance`: Maximum ratio of shadow to total range (default: 0.05)

# Output
- [`SingleCandlePatternVal`](@ref): Pattern value with MARUBOZU_BULLISH or MARUBOZU_BEARISH
"""
mutable struct Marubozu{Tohlcv,IN,S} <: TechnicalIndicatorSingleOutput{Tohlcv}
    value::Union{Missing,SingleCandlePatternVal}
    n::Int

    shadow_tolerance::S

    input_values::CircBuff

    function Marubozu{Tohlcv}(;
        shadow_tolerance = MARUBOZU_SHADOW_TOLERANCE,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        S = hasfield(T2, :close) ? fieldtype(T2, :close) : Float64
        input_values = CircBuff(T2, 1, rev = false)
        new{Tohlcv,true,S}(
            missing,
            0,
            shadow_tolerance,
            input_values,
        )
    end
end

function _calculate_new_value(ind::Marubozu{T,IN,S}) where {T,IN,S}
    candle = ind.input_values[end]

    o = candle.open
    h = candle.high
    l = candle.low
    c = candle.close

    body = abs(c - o)
    total_range = h - l

    # Avoid division by zero or no movement
    if total_range == 0 || body == 0
        return SingleCandlePatternVal(
            SingleCandlePatternType.NONE,
            zero(S),
            PatternDirection.NEUTRAL,
        )
    end

    upper_shadow = h - max(o, c)
    lower_shadow = min(o, c) - l

    upper_ratio = upper_shadow / total_range
    lower_ratio = lower_shadow / total_range

    # Check if shadows are minimal
    if upper_ratio > ind.shadow_tolerance || lower_ratio > ind.shadow_tolerance
        return SingleCandlePatternVal(
            SingleCandlePatternType.NONE,
            zero(S),
            PatternDirection.NEUTRAL,
        )
    end

    # Calculate confidence (less shadow = higher confidence)
    total_shadow_ratio = (upper_ratio + lower_ratio) / 2
    confidence = one(S) - (total_shadow_ratio / ind.shadow_tolerance)

    # Determine if bullish or bearish based on close vs open
    if c > o
        return SingleCandlePatternVal(
            SingleCandlePatternType.MARUBOZU_BULLISH,
            confidence,
            PatternDirection.BULLISH,
        )
    else
        return SingleCandlePatternVal(
            SingleCandlePatternType.MARUBOZU_BEARISH,
            confidence,
            PatternDirection.BEARISH,
        )
    end
end
