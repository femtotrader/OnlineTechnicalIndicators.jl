const THREE_INSIDE_MAX_HARAMI_RATIO = 0.5

"""
    ThreeInside{Tohlcv}(; max_harami_ratio = THREE_INSIDE_MAX_HARAMI_RATIO, input_modifier_return_type = Tohlcv)

The `ThreeInside` type implements Three Inside Up and Three Inside Down candlestick pattern detectors.

- Three Inside Up: Bullish pattern - Harami followed by bullish confirmation
- Three Inside Down: Bearish pattern - Harami followed by bearish confirmation

# Parameters
- `max_harami_ratio`: Maximum ratio of second candle body to first candle body for Harami (default: 0.5)

# Output
- [`ThreeCandlePatternVal`](@ref): Pattern value with THREE_INSIDE_UP or THREE_INSIDE_DOWN
"""
mutable struct ThreeInside{Tohlcv,IN,S} <: TechnicalIndicatorSingleOutput{Tohlcv}
    value::Union{Missing,ThreeCandlePatternVal}
    n::Int

    max_harami_ratio::S

    input_values::CircBuff

    function ThreeInside{Tohlcv}(;
        max_harami_ratio = THREE_INSIDE_MAX_HARAMI_RATIO,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        S = hasfield(T2, :close) ? fieldtype(T2, :close) : Float64
        input_values = CircBuff(T2, 3, rev = false)
        new{Tohlcv,true,S}(missing, 0, max_harami_ratio, input_values)
    end
end

function _calculate_new_value(ind::ThreeInside{T,IN,S}) where {T,IN,S}
    # Need at least 3 candles
    if ind.n < 3
        return missing
    end

    c1 = ind.input_values[end-2]
    c2 = ind.input_values[end-1]
    c3 = ind.input_values[end]

    # Extract OHLC values
    o1, c1_close = c1.open, c1.close
    o2, c2_close = c2.open, c2.close
    o3, c3_close = c3.open, c3.close

    # Calculate body sizes
    body1 = abs(c1_close - o1)
    body2 = abs(c2_close - o2)
    body3 = abs(c3_close - o3)

    # Avoid division by zero
    if body1 == 0 || body2 == 0 || body3 == 0
        return ThreeCandlePatternVal(
            ThreeCandlePatternType.NONE,
            zero(S),
            PatternDirection.NEUTRAL,
        )
    end

    c1_is_bearish = c1_close < o1
    c3_is_bullish = c3_close > o3

    # Check if c1 and c2 form a Harami
    body_ratio = body2 / body1
    if body_ratio > ind.max_harami_ratio
        return ThreeCandlePatternVal(
            ThreeCandlePatternType.NONE,
            zero(S),
            PatternDirection.NEUTRAL,
        )
    end

    # Get body ranges
    c1_body_high = max(o1, c1_close)
    c1_body_low = min(o1, c1_close)
    c2_body_high = max(o2, c2_close)
    c2_body_low = min(o2, c2_close)

    # Check if c2 is contained within c1
    c2_contained = c2_body_low >= c1_body_low && c2_body_high <= c1_body_high

    if !c2_contained
        return ThreeCandlePatternVal(
            ThreeCandlePatternType.NONE,
            zero(S),
            PatternDirection.NEUTRAL,
        )
    end

    # Three Inside Up: c1 bearish (Harami) + c3 bullish confirmation closing above c1
    if c1_is_bearish && c3_is_bullish && c3_close > c1_close
        # Calculate confidence
        harami_confidence = one(S) - (body_ratio / ind.max_harami_ratio)
        confirmation_strength = min((c3_close - c1_close) / body1, one(S))
        confidence = (harami_confidence + confirmation_strength) / 2

        return ThreeCandlePatternVal(
            ThreeCandlePatternType.THREE_INSIDE_UP,
            confidence,
            PatternDirection.BULLISH,
        )
    end

    # Three Inside Down: c1 bullish (Harami) + c3 bearish confirmation closing below c1
    if !c1_is_bearish && !c3_is_bullish && c3_close < c1_close
        # Calculate confidence
        harami_confidence = one(S) - (body_ratio / ind.max_harami_ratio)
        confirmation_strength = min((c1_close - c3_close) / body1, one(S))
        confidence = (harami_confidence + confirmation_strength) / 2

        return ThreeCandlePatternVal(
            ThreeCandlePatternType.THREE_INSIDE_DOWN,
            confidence,
            PatternDirection.BEARISH,
        )
    end

    return ThreeCandlePatternVal(
        ThreeCandlePatternType.NONE,
        zero(S),
        PatternDirection.NEUTRAL,
    )
end
