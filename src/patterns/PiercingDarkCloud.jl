const PIERCING_MIN_PENETRATION = 0.5

"""
    PiercingDarkCloud{Tohlcv}(; min_penetration = PIERCING_MIN_PENETRATION, input_modifier_return_type = Tohlcv)

The `PiercingDarkCloud` type implements Piercing Line and Dark Cloud Cover candlestick pattern detectors.

- Piercing Line: Bullish reversal where a down candle is followed by an up candle that closes
  above the midpoint of the first candle's body
- Dark Cloud Cover: Bearish reversal where an up candle is followed by a down candle that closes
  below the midpoint of the first candle's body

# Parameters
- `min_penetration`: Minimum penetration ratio into previous candle's body (default: 0.5 = 50%)

# Output
- [`TwoCandlePatternVal`](@ref): Pattern value with PIERCING_LINE or DARK_CLOUD_COVER
"""
mutable struct PiercingDarkCloud{Tohlcv,IN,S} <: TechnicalIndicatorSingleOutput{Tohlcv}
    value::Union{Missing,TwoCandlePatternVal}
    n::Int

    min_penetration::S

    input_values::CircBuff

    function PiercingDarkCloud{Tohlcv}(;
        min_penetration = PIERCING_MIN_PENETRATION,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        S = hasfield(T2, :close) ? fieldtype(T2, :close) : Float64
        input_values = CircBuff(T2, 2, rev = false)
        new{Tohlcv,true,S}(missing, 0, min_penetration, input_values)
    end
end

function _calculate_new_value(ind::PiercingDarkCloud{T,IN,S}) where {T,IN,S}
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

    # Avoid division by zero
    if prev_body == 0
        return TwoCandlePatternVal(
            TwoCandlePatternType.NONE,
            zero(S),
            PatternDirection.NEUTRAL,
        )
    end

    prev_is_bearish = prev_c < prev_o
    curr_is_bullish = curr_c > curr_o

    # Piercing Line: prev bearish, curr bullish
    if prev_is_bearish && curr_is_bullish
        # Calculate midpoint of previous body
        prev_midpoint = (prev_o + prev_c) / 2

        # Current must open below prev low and close above midpoint
        if curr_o < prev_c && curr_c > prev_midpoint
            # Calculate penetration depth
            penetration = (curr_c - prev_c) / prev_body

            # Check if penetration meets minimum requirement
            if penetration >= ind.min_penetration
                confidence = min(penetration, one(S))
                return TwoCandlePatternVal(
                    TwoCandlePatternType.PIERCING_LINE,
                    confidence,
                    PatternDirection.BULLISH,
                )
            end
        end
    end

    # Dark Cloud Cover: prev bullish, curr bearish
    if !prev_is_bearish && !curr_is_bullish
        # Calculate midpoint of previous body
        prev_midpoint = (prev_o + prev_c) / 2

        # Current must open above prev high and close below midpoint
        if curr_o > prev_c && curr_c < prev_midpoint
            # Calculate penetration depth
            penetration = (prev_c - curr_c) / prev_body

            # Check if penetration meets minimum requirement
            if penetration >= ind.min_penetration
                confidence = min(penetration, one(S))
                return TwoCandlePatternVal(
                    TwoCandlePatternType.DARK_CLOUD_COVER,
                    confidence,
                    PatternDirection.BEARISH,
                )
            end
        end
    end

    return TwoCandlePatternVal(TwoCandlePatternType.NONE, zero(S), PatternDirection.NEUTRAL)
end
