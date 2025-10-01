const HARAMI_MAX_BODY_RATIO = 0.5

"""
    Harami{Tohlcv}(; max_body_ratio = HARAMI_MAX_BODY_RATIO, input_filter = always_true, input_modifier = identity, input_modifier_return_type = Tohlcv)

The `Harami` type implements Bullish and Bearish Harami candlestick pattern detector.

A Harami pattern occurs when a small candle's body is contained within the previous candle's body.
- Bullish Harami: Down candle followed by small up candle contained within it
- Bearish Harami: Up candle followed by small down candle contained within it

# Parameters
- `max_body_ratio`: Maximum ratio of current body to previous body (default: 0.5)

# Output
- [`TwoCandlePatternVal`](@ref): Pattern value with BULLISH_HARAMI or BEARISH_HARAMI
"""
mutable struct Harami{Tohlcv,IN,S} <: TechnicalIndicatorSingleOutput{Tohlcv}
    value::Union{Missing,TwoCandlePatternVal}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    max_body_ratio::S

    input_modifier::Function
    input_filter::Function
    input_values::CircBuff

    function Harami{Tohlcv}(;
        max_body_ratio = HARAMI_MAX_BODY_RATIO,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        S = hasfield(T2, :close) ? fieldtype(T2, :close) : Float64
        input_values = CircBuff(T2, 2, rev = false)
        new{Tohlcv,true,S}(
            initialize_indicator_common_fields()...,
            max_body_ratio,
            input_modifier,
            input_filter,
            input_values,
        )
    end
end

function _calculate_new_value(ind::Harami{T,IN,S}) where {T,IN,S}
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

    # Check if current body is smaller than previous
    body_ratio = curr_body / prev_body
    if body_ratio > ind.max_body_ratio
        return TwoCandlePatternVal(
            TwoCandlePatternType.NONE,
            zero(S),
            PatternDirection.NEUTRAL,
        )
    end

    # Determine if previous candle is bearish or bullish
    prev_is_bearish = prev_c < prev_o

    # Get body ranges
    prev_body_high = max(prev_o, prev_c)
    prev_body_low = min(prev_o, prev_c)
    curr_body_high = max(curr_o, curr_c)
    curr_body_low = min(curr_o, curr_c)

    # Bullish Harami: prev bearish, curr bullish (or neutral), curr contained in prev
    if prev_is_bearish
        # Check if current candle is contained within previous
        if curr_body_low >= prev_body_low && curr_body_high <= prev_body_high
            # Smaller body = higher confidence
            confidence = one(S) - (body_ratio / ind.max_body_ratio)
            return TwoCandlePatternVal(
                TwoCandlePatternType.BULLISH_HARAMI,
                confidence,
                PatternDirection.BULLISH,
            )
        end
    end

    # Bearish Harami: prev bullish, curr bearish (or neutral), curr contained in prev
    if !prev_is_bearish
        # Check if current candle is contained within previous
        if curr_body_low >= prev_body_low && curr_body_high <= prev_body_high
            # Smaller body = higher confidence
            confidence = one(S) - (body_ratio / ind.max_body_ratio)
            return TwoCandlePatternVal(
                TwoCandlePatternType.BEARISH_HARAMI,
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
