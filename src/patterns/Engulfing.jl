const ENGULFING_MIN_BODY_RATIO = 1.1

"""
    Engulfing{Tohlcv}(; min_body_ratio = ENGULFING_MIN_BODY_RATIO, input_filter = always_true, input_modifier = identity, input_modifier_return_type = Tohlcv)

The `Engulfing` type implements Bullish and Bearish Engulfing candlestick pattern detector.

An Engulfing pattern occurs when a candle's body completely engulfs the previous candle's body.
- Bullish Engulfing: Down candle followed by up candle that engulfs it
- Bearish Engulfing: Up candle followed by down candle that engulfs it

# Parameters
- `min_body_ratio`: Minimum ratio of current body to previous body (default: 1.1)

# Output
- [`TwoCandlePatternVal`](@ref): Pattern value with BULLISH_ENGULFING or BEARISH_ENGULFING
"""
mutable struct Engulfing{Tohlcv,IN,S} <: TechnicalIndicatorSingleOutput{Tohlcv}
    value::Union{Missing,TwoCandlePatternVal}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    min_body_ratio::S

    input_modifier::Function
    input_filter::Function
    input_values::CircBuff

    function Engulfing{Tohlcv}(;
        min_body_ratio = ENGULFING_MIN_BODY_RATIO,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        S = hasfield(T2, :close) ? fieldtype(T2, :close) : Float64
        input_values = CircBuff(T2, 2, rev = false)
        new{Tohlcv,true,S}(
            initialize_indicator_common_fields()...,
            min_body_ratio,
            input_modifier,
            input_filter,
            input_values,
        )
    end
end

function _calculate_new_value(ind::Engulfing{T,IN,S}) where {T,IN,S}
    # Need at least 2 candles
    if ind.n < 2
        return missing
    end

    prev_candle = ind.input_values[end-1]
    curr_candle = ind.input_values[end]

    prev_o = prev_candle.open
    prev_c = prev_candle.close
    curr_o = curr_candle.open
    curr_c = curr_candle.close

    prev_body = abs(prev_c - prev_o)
    curr_body = abs(curr_c - curr_o)

    # Avoid division by zero
    if prev_body == 0 || curr_body == 0
        return TwoCandlePatternVal(
            TwoCandlePatternType.NONE,
            zero(S),
            PatternDirection.NEUTRAL,
        )
    end

    # Check if current body is larger than previous
    body_ratio = curr_body / prev_body
    if body_ratio < ind.min_body_ratio
        return TwoCandlePatternVal(
            TwoCandlePatternType.NONE,
            zero(S),
            PatternDirection.NEUTRAL,
        )
    end

    # Determine if previous candle is bearish or bullish
    prev_is_bearish = prev_c < prev_o
    curr_is_bullish = curr_c > curr_o

    # Bullish Engulfing: prev bearish, curr bullish, curr engulfs prev
    if prev_is_bearish && curr_is_bullish
        # Check engulfing: curr_o <= prev_c and curr_c >= prev_o
        if curr_o <= prev_c && curr_c >= prev_o
            confidence = min(body_ratio / 2, one(S))
            return TwoCandlePatternVal(
                TwoCandlePatternType.BULLISH_ENGULFING,
                confidence,
                PatternDirection.BULLISH,
            )
        end
    end

    # Bearish Engulfing: prev bullish, curr bearish, curr engulfs prev
    if !prev_is_bearish && !curr_is_bullish
        # Check engulfing: curr_o >= prev_c and curr_c <= prev_o
        if curr_o >= prev_c && curr_c <= prev_o
            confidence = min(body_ratio / 2, one(S))
            return TwoCandlePatternVal(
                TwoCandlePatternType.BEARISH_ENGULFING,
                confidence,
                PatternDirection.BEARISH,
            )
        end
    end

    return TwoCandlePatternVal(
        TwoCandlePatternType.NONE,
        zero(S),
        PatternDirection.NEUTRAL,
    )
end
