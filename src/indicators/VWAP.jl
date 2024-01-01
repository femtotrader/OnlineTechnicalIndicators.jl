const VWAP_MEMORY = 3

"""
    VWAP{Tohlcv,S}(input_filter = always_true, input_modifier = identity, input_modifier_return_type = T)

The `VWAP` type implements a Volume Weighted Moving Average indicator.
"""
mutable struct VWAP{Tohlcv,S} <: TechnicalIndicator{Tohlcv}
    value::Union{Missing,S}
    n::Int

    output_listeners::Series

    sum_price_vol::S
    sum_vol::S

    input_modifier::Function
    input_filter::Function
    input_indicator::Union{Missing,TechnicalIndicator}

    function VWAP{Tohlcv,S}(;
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv,S}
        #T2 = input_modifier_return_type
        sum_price_vol = zero(S)
        sum_vol = zero(S)
        output_listeners = Series()
        input_indicator = missing
        new{Tohlcv,S}(
            missing,
            0,
            output_listeners,
            sum_price_vol,
            sum_vol,
            input_modifier,
            input_filter,
            input_indicator,
        )
    end
end


function _calculate_new_value_only_from_incoming_data(ind::VWAP, candle)
    typical_price = (candle.high + candle.low + candle.close) / 3.0

    ind.sum_price_vol = ind.sum_price_vol + candle.volume * typical_price
    ind.sum_vol = ind.sum_vol + candle.volume

    if ind.sum_vol != 0
        return ind.sum_price_vol / ind.sum_vol
    else
        return missing
    end
end
