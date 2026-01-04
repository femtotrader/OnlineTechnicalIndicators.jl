"""
    RelativeIntradayRange{Tohlcv}(; input_modifier_return_type = Tohlcv)

The `RelativeIntradayRange` type implements a Relative Intraday Range indicator.

Relative Intraday Range measures the percentage price range within a single bar,
calculated as the absolute range divided by the open price, expressed as a percentage.
This allows comparison of volatility across assets with different price levels.

# Parameters
- `input_modifier_return_type::Type = Tohlcv`: Input OHLCV type (must have `open`, `high`, and `low` fields)

# Formula
```
RelativeIntradayRange = (High - Low) * 100 / Open
```

# Input
Requires OHLCV data with `open`, `high`, and `low` fields.

# Returns
`Union{Missing,T}` - The percentage bar range. Returns `missing` if Open is zero.
Available from the first observation (no warm-up).

See also: [`IntradayRange`](@ref), [`TrueRange`](@ref), [`ATR`](@ref), [`NATR`](@ref)
"""
mutable struct RelativeIntradayRange{Tohlcv,IN,S} <: TechnicalIndicatorSingleOutput{Tohlcv}
    value::Union{Missing,S}
    n::Int

    function RelativeIntradayRange{Tohlcv}(; input_modifier_return_type = Tohlcv) where {Tohlcv}
        T2 = input_modifier_return_type
        S = fieldtype(T2, :close)
        new{Tohlcv,true,S}(missing, 0)
    end
end

function RelativeIntradayRange(; input_modifier_return_type = OHLCV{Missing,Float64,Float64})
    RelativeIntradayRange{input_modifier_return_type}(;
        input_modifier_return_type = input_modifier_return_type,
    )
end

function _calculate_new_value_only_from_incoming_data(ind::RelativeIntradayRange, candle)
    if candle.open == 0
        return missing
    end
    return (candle.high - candle.low) * 100 / candle.open
end
