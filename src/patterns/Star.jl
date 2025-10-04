const STAR_DOJI_TOLERANCE = 0.1
const STAR_MIN_GAP_RATIO = 0.1

"""
    Star{Tohlcv}(; doji_tolerance = STAR_DOJI_TOLERANCE, min_gap_ratio = STAR_MIN_GAP_RATIO, input_modifier_return_type = Tohlcv)

The `Star` type implements Morning Star and Evening Star candlestick pattern detectors.

- Morning Star: Bullish reversal with down candle, small-bodied star, then up candle
- Evening Star: Bearish reversal with up candle, small-bodied star, then down candle

# Parameters
- `doji_tolerance`: Maximum body ratio for middle candle to be considered a star (default: 0.1)
- `min_gap_ratio`: Minimum gap between star and adjacent candles (default: 0.1)

# Output
- [`ThreeCandlePatternVal`](@ref): Pattern value with MORNING_STAR or EVENING_STAR
"""
mutable struct Star{Tohlcv,IN,S} <: TechnicalIndicatorSingleOutput{Tohlcv}
    value::Union{Missing,ThreeCandlePatternVal}
    n::Int

    doji_tolerance::S
    min_gap_ratio::S

    input_values::CircBuff

    function Star{Tohlcv}(;
        doji_tolerance = STAR_DOJI_TOLERANCE,
        min_gap_ratio = STAR_MIN_GAP_RATIO,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        S = hasfield(T2, :close) ? fieldtype(T2, :close) : Float64
        input_values = CircBuff(T2, 3, rev = false)
        new{Tohlcv,true,S}(
            missing,
            0,
            doji_tolerance,
            min_gap_ratio,
            input_values,
        )
    end
end

function _calculate_new_value(ind::Star{T,IN,S}) where {T,IN,S}
    # Need at least 3 candles
    if ind.n < 3
        return missing
    end

    c1 = ind.input_values[end-2]  # First candle
    c2 = ind.input_values[end-1]  # Star (middle)
    c3 = ind.input_values[end]    # Third candle

    # Extract OHLC values
    o1, c1_close = c1.open, c1.close
    o2, h2, l2, c2_close = c2.open, c2.high, c2.low, c2.close
    o3, c3_close = c3.open, c3.close

    # Calculate body sizes
    body1 = abs(c1_close - o1)
    body2 = abs(c2_close - o2)
    body3 = abs(c3_close - o3)

    range2 = h2 - l2

    # Avoid division by zero
    if range2 == 0 || body1 == 0 || body3 == 0
        return ThreeCandlePatternVal(
            ThreeCandlePatternType.NONE,
            zero(S),
            PatternDirection.NEUTRAL,
        )
    end

    # Check if middle candle is a star (small body)
    star_body_ratio = body2 / range2
    if star_body_ratio > ind.doji_tolerance
        return ThreeCandlePatternVal(
            ThreeCandlePatternType.NONE,
            zero(S),
            PatternDirection.NEUTRAL,
        )
    end

    c1_is_bearish = c1_close < o1
    c3_is_bullish = c3_close > o3

    # Morning Star: c1 bearish, c2 star, c3 bullish
    if c1_is_bearish && c3_is_bullish
        # Check for gap down between c1 and c2
        c1_body_low = min(o1, c1_close)
        c2_body_high = max(o2, c2_close)
        gap_down = c1_body_low - c2_body_high

        # Check for gap up between c2 and c3
        c2_body_low = min(o2, c2_close)
        c3_body_high = max(o3, c3_close)
        gap_up = c3_body_high - c2_body_low

        # At least one gap should exist (relaxed condition)
        if gap_down > 0 || gap_up > 0
            # Third candle should close well into first candle's body
            penetration = (c3_close - c1_close) / body1

            if penetration > ind.min_gap_ratio
                # Calculate confidence
                star_confidence = one(S) - (star_body_ratio / ind.doji_tolerance)
                penetration_confidence = min(penetration, one(S))
                confidence = (star_confidence + penetration_confidence) / 2

                return ThreeCandlePatternVal(
                    ThreeCandlePatternType.MORNING_STAR,
                    confidence,
                    PatternDirection.BULLISH,
                )
            end
        end
    end

    # Evening Star: c1 bullish, c2 star, c3 bearish
    if !c1_is_bearish && !c3_is_bullish
        # Check for gap up between c1 and c2
        c1_body_high = max(o1, c1_close)
        c2_body_low = min(o2, c2_close)
        gap_up = c2_body_low - c1_body_high

        # Check for gap down between c2 and c3
        c2_body_high = max(o2, c2_close)
        c3_body_low = min(o3, c3_close)
        gap_down = c2_body_high - c3_body_low

        # At least one gap should exist (relaxed condition)
        if gap_up > 0 || gap_down > 0
            # Third candle should close well into first candle's body
            penetration = (o1 - c3_close) / body1

            if penetration > ind.min_gap_ratio
                # Calculate confidence
                star_confidence = one(S) - (star_body_ratio / ind.doji_tolerance)
                penetration_confidence = min(penetration, one(S))
                confidence = (star_confidence + penetration_confidence) / 2

                return ThreeCandlePatternVal(
                    ThreeCandlePatternType.EVENING_STAR,
                    confidence,
                    PatternDirection.BEARISH,
                )
            end
        end
    end

    return ThreeCandlePatternVal(
        ThreeCandlePatternType.NONE,
        zero(S),
        PatternDirection.NEUTRAL,
    )
end
