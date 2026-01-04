"""
    TrueRange{Tohlcv}(; input_modifier_return_type = Tohlcv)

The `TrueRange` type implements a True Range indicator.

True Range measures the greatest of the following:
- Current high minus current low
- Absolute value of current high minus previous close
- Absolute value of current low minus previous close

This captures the full range of price movement including any gaps from the previous close.
True Range is the building block for the Average True Range (ATR) indicator.

# Parameters
- `input_modifier_return_type::Type = Tohlcv`: Input OHLCV type (must have `high`, `low`, `close` fields)

# Formula
```
TR = max(high - low, |high - close_prev|, |low - close_prev|)
```
For the first observation, TR = high - low (no previous close available).

# Input
Requires OHLCV data with `high`, `low`, and `close` fields.

# Returns
`Union{Missing,T}` - The true range value. Available from the first observation.

See also: [`ATR`](@ref), [`NATR`](@ref)
"""
mutable struct TrueRange{Tohlcv,IN,S} <: TechnicalIndicatorSingleOutput{Tohlcv}
    value::Union{Missing,S}
    n::Int
    input_values::CircBuff

    function TrueRange{Tohlcv}(; input_modifier_return_type = Tohlcv) where {Tohlcv}
        T2 = input_modifier_return_type
        if hasfield(T2, :close)
            S = fieldtype(T2, :close)
        else
            S = Float64
        end
        input_values = CircBuff(T2, 2, rev = false)
        new{Tohlcv,true,S}(missing, 0, input_values)
    end
end

function TrueRange(; input_modifier_return_type = OHLCV{Missing,Float64,Float64})
    TrueRange{input_modifier_return_type}(;
        input_modifier_return_type = input_modifier_return_type,
    )
end

function _calculate_new_value(ind::TrueRange)
    candle = ind.input_values[end]
    candle_range = candle.high - candle.low

    if ind.n != 1
        close2 = ind.input_values[end-1].close
        return max(candle_range, abs(candle.high - close2), abs(candle.low - close2))
    else
        return candle_range
    end

end
