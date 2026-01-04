const TWEEZER_TOLERANCE = 0.001

"""
    Tweezer{Tohlcv}(; tolerance = TWEEZER_TOLERANCE, input_modifier_return_type = Tohlcv)

The `Tweezer` type implements Tweezer Top and Tweezer Bottom candlestick pattern detectors.

- Tweezer Top: Two consecutive candles with matching highs, indicating resistance
- Tweezer Bottom: Two consecutive candles with matching lows, indicating support

# Parameters
- `tolerance`: Maximum relative difference between prices to be considered matching (default: 0.001 = 0.1%)

# Output
- [`TwoCandlePatternVal`](@ref): Pattern value with TWEEZER_TOP or TWEEZER_BOTTOM
"""
mutable struct Tweezer{Tohlcv,IN,S} <: TechnicalIndicatorSingleOutput{Tohlcv}
    value::Union{Missing,TwoCandlePatternVal}
    n::Int

    tolerance::S

    input_values::CircBuff

    function Tweezer{Tohlcv}(;
        tolerance = TWEEZER_TOLERANCE,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        S = hasfield(T2, :close) ? fieldtype(T2, :close) : Float64
        input_values = CircBuff(T2, 2, rev = false)
        new{Tohlcv,true,S}(missing, 0, tolerance, input_values)
    end
end

function _calculate_new_value(ind::Tweezer{T,IN,S}) where {T,IN,S}
    # Need at least 2 candles
    if ind.n < 2
        return missing
    end

    prev_candle = ind.input_values[end-1]
    curr_candle = ind.input_values[end]

    prev_h = prev_candle.high
    prev_l = prev_candle.low
    curr_h = curr_candle.high
    curr_l = curr_candle.low

    # Calculate relative differences
    avg_high = (prev_h + curr_h) / 2
    avg_low = (prev_l + curr_l) / 2

    high_diff = abs(prev_h - curr_h) / avg_high
    low_diff = abs(prev_l - curr_l) / avg_low

    # Check for Tweezer Top (matching highs)
    if high_diff <= ind.tolerance
        # Calculate confidence (smaller difference = higher confidence)
        confidence = one(S) - (high_diff / ind.tolerance)

        return TwoCandlePatternVal(
            TwoCandlePatternType.TWEEZER_TOP,
            confidence,
            PatternDirection.BEARISH,
        )
    end

    # Check for Tweezer Bottom (matching lows)
    if low_diff <= ind.tolerance
        # Calculate confidence (smaller difference = higher confidence)
        confidence = one(S) - (low_diff / ind.tolerance)

        return TwoCandlePatternVal(
            TwoCandlePatternType.TWEEZER_BOTTOM,
            confidence,
            PatternDirection.BULLISH,
        )
    end

    return TwoCandlePatternVal(TwoCandlePatternType.NONE, zero(S), PatternDirection.NEUTRAL)
end
