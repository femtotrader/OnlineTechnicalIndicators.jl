const VWAP_MEMORY = 3

"""
    VWAP{Tohlcv}(; input_modifier_return_type = Tohlcv)

The `VWAP` type implements a Volume Weighted Average Price indicator.

VWAP calculates the average price weighted by volume from the beginning of the trading
session. It represents the average price a security has traded at throughout the day,
and is commonly used as a trading benchmark by institutional investors.

# Parameters
- `input_modifier_return_type::Type = Tohlcv`: Input OHLCV type

# Formula
```
Typical Price = (high + low + close) / 3
VWAP = cumsum(Typical Price × volume) / cumsum(volume)
```

# Input
Requires OHLCV data with `high`, `low`, `close`, and `volume` fields.

# Returns
`Union{Missing,T}` - The cumulative VWAP value. Available from the first observation.
Returns `missing` if total volume is zero.

See also: [`VWMA`](@ref), [`SMA`](@ref)
"""
mutable struct VWAP{Tohlcv,IN,S} <: TechnicalIndicatorSingleOutput{Tohlcv}
    value::Union{Missing,S}
    n::Int

    sum_price_vol::S
    sum_vol::S

    function VWAP{Tohlcv}(; input_modifier_return_type = Tohlcv) where {Tohlcv}
        T2 = input_modifier_return_type
        S = fieldtype(T2, :close)
        sum_price_vol = zero(S)
        sum_vol = zero(S)
        new{Tohlcv,true,S}(missing, 0, sum_price_vol, sum_vol)
    end
end

function VWAP(; input_modifier_return_type = OHLCV{Missing,Float64,Float64})
    VWAP{input_modifier_return_type}(;
        input_modifier_return_type = input_modifier_return_type,
    )
end

function _calculate_new_value_only_from_incoming_data(ind::VWAP, candle)
    typical_price = (candle.high + candle.low + candle.close) / 3

    ind.sum_price_vol = ind.sum_price_vol + candle.volume * typical_price
    ind.sum_vol = ind.sum_vol + candle.volume

    if ind.sum_vol != 0
        return ind.sum_price_vol / ind.sum_vol
    else
        return missing
    end
end
