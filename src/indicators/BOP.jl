"""
    BOP{Tohlcv}(; input_modifier_return_type = Tohlcv)

The `BOP` type implements a Balance Of Power indicator.

Balance of Power measures the strength of buyers vs sellers by comparing the close
relative to the open within the high-low range. Values near +1 indicate strong buying
pressure (close near high), while values near -1 indicate strong selling pressure
(close near low).

# Parameters
- `input_modifier_return_type::Type = Tohlcv`: Input OHLCV type

# Formula
```
BOP = (close - open) / (high - low)
```
Returns the previous value if high equals low (division by zero).

# Input
Requires OHLCV data with `open`, `high`, `low`, and `close` fields.

# Returns
`Union{Missing,T}` - The balance of power value in range [-1, 1]. Available from the first
observation.

See also: [`RSI`](@ref), [`OBV`](@ref)
"""
mutable struct BOP{Tohlcv,IN,S} <: TechnicalIndicatorSingleOutput{Tohlcv}
    value::Union{Missing,S}
    n::Int

    function BOP{Tohlcv}(; input_modifier_return_type = Tohlcv) where {Tohlcv}
        S = fieldtype(input_modifier_return_type, :close)
        new{Tohlcv,true,S}(missing, 0)
    end
end

function BOP(; input_modifier_return_type = OHLCV{Missing,Float64,Float64})
    BOP{input_modifier_return_type}(;
        input_modifier_return_type = input_modifier_return_type,
    )
end

function _calculate_new_value_only_from_incoming_data(ind::BOP, candle)
    return candle.high != candle.low ?
           (candle.close - candle.open) / (candle.high - candle.low) : value(ind)
end
