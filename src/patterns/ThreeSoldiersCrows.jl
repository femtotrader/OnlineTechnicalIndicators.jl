const THREE_SOLDIERS_MIN_PROGRESS = 0.2

"""
    ThreeSoldiersCrows{Tohlcv}(; min_progress = THREE_SOLDIERS_MIN_PROGRESS, input_modifier_return_type = Tohlcv)

The `ThreeSoldiersCrows` type implements Three White Soldiers and Three Black Crows candlestick pattern detectors.

- Three White Soldiers: Three consecutive bullish candles with progressive closes
- Three Black Crows: Three consecutive bearish candles with progressive closes

# Parameters
- `min_progress`: Minimum ratio of progression between consecutive candles (default: 0.2)

# Output
- [`ThreeCandlePatternVal`](@ref): Pattern value with THREE_WHITE_SOLDIERS or THREE_BLACK_CROWS
"""
mutable struct ThreeSoldiersCrows{Tohlcv,IN,S} <: TechnicalIndicatorSingleOutput{Tohlcv}
    value::Union{Missing,ThreeCandlePatternVal}
    n::Int

    min_progress::S

    input_values::CircBuff

    function ThreeSoldiersCrows{Tohlcv}(;
        min_progress = THREE_SOLDIERS_MIN_PROGRESS,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        S = hasfield(T2, :close) ? fieldtype(T2, :close) : Float64
        input_values = CircBuff(T2, 3, rev = false)
        new{Tohlcv,true,S}(missing, 0, min_progress, input_values)
    end
end

function _calculate_new_value(ind::ThreeSoldiersCrows{T,IN,S}) where {T,IN,S}
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

    # Check if all three are bullish
    all_bullish = (c1_close > o1) && (c2_close > o2) && (c3_close > o3)

    # Check if all three are bearish
    all_bearish = (c1_close < o1) && (c2_close < o2) && (c3_close < o3)

    if all_bullish
        # Three White Soldiers
        # Each candle should close higher than the previous
        if c2_close > c1_close && c3_close > c2_close
            # Each candle should open within the previous candle's body
            c1_body_high = max(o1, c1_close)
            c1_body_low = min(o1, c1_close)
            c2_body_high = max(o2, c2_close)
            c2_body_low = min(o2, c2_close)

            within_body_12 = o2 >= c1_body_low && o2 <= c1_body_high
            within_body_23 = o3 >= c2_body_low && o3 <= c2_body_high

            # Calculate progression (how much each close advances)
            progress_12 = (c2_close - c1_close) / body1
            progress_23 = (c3_close - c2_close) / body2

            min_prog = min(progress_12, progress_23)

            if min_prog >= ind.min_progress
                # Calculate confidence based on body progression and opening position
                progression_confidence = min(min_prog, one(S))
                body_position_confidence =
                    (within_body_12 ? 0.5 : 0.0) + (within_body_23 ? 0.5 : 0.0)
                confidence = (progression_confidence + body_position_confidence) / 2

                return ThreeCandlePatternVal(
                    ThreeCandlePatternType.THREE_WHITE_SOLDIERS,
                    confidence,
                    PatternDirection.BULLISH,
                )
            end
        end
    elseif all_bearish
        # Three Black Crows
        # Each candle should close lower than the previous
        if c2_close < c1_close && c3_close < c2_close
            # Each candle should open within the previous candle's body
            c1_body_high = max(o1, c1_close)
            c1_body_low = min(o1, c1_close)
            c2_body_high = max(o2, c2_close)
            c2_body_low = min(o2, c2_close)

            within_body_12 = o2 >= c1_body_low && o2 <= c1_body_high
            within_body_23 = o3 >= c2_body_low && o3 <= c2_body_high

            # Calculate progression (how much each close declines)
            progress_12 = (c1_close - c2_close) / body1
            progress_23 = (c2_close - c3_close) / body2

            min_prog = min(progress_12, progress_23)

            if min_prog >= ind.min_progress
                # Calculate confidence based on body progression and opening position
                progression_confidence = min(min_prog, one(S))
                body_position_confidence =
                    (within_body_12 ? 0.5 : 0.0) + (within_body_23 ? 0.5 : 0.0)
                confidence = (progression_confidence + body_position_confidence) / 2

                return ThreeCandlePatternVal(
                    ThreeCandlePatternType.THREE_BLACK_CROWS,
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
