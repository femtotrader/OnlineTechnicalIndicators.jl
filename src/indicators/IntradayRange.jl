"""
    IntradayRange{Tohlcv}(; input_modifier_return_type = Tohlcv)

The `IntradayRange` type implements an Intraday Range indicator.

Intraday Range measures the absolute price range within a single bar, calculated as
the difference between the high and low prices. Unlike True Range, it does not
consider gaps from the previous close, making it ideal for intraday analysis where
overnight gaps are not relevant.

# Parameters
- `input_modifier_return_type::Type = Tohlcv`: Input OHLCV type (must have `high` and `low` fields)

# Formula
```
IntradayRange = High - Low
```

# Input
Requires OHLCV data with `high` and `low` fields.

# Returns
`Union{Missing,T}` - The absolute bar range. Available from the first observation (no warm-up).

See also: [`RelativeIntradayRange`](@ref), [`ADR`](@ref), [`TrueRange`](@ref), [`ATR`](@ref)
"""
mutable struct IntradayRange{Tohlcv,IN,S} <: TechnicalIndicatorSingleOutput{Tohlcv}
    value::Union{Missing,S}
    n::Int

    function IntradayRange{Tohlcv}(; input_modifier_return_type = Tohlcv) where {Tohlcv}
        T2 = input_modifier_return_type
        S = fieldtype(T2, :close)
        new{Tohlcv,true,S}(missing, 0)
    end
end

function IntradayRange(; input_modifier_return_type = OHLCV{Missing,Float64,Float64})
    IntradayRange{input_modifier_return_type}(;
        input_modifier_return_type = input_modifier_return_type,
    )
end

function _calculate_new_value_only_from_incoming_data(ind::IntradayRange, candle)
    return candle.high - candle.low
end
