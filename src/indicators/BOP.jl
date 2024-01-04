"""
    BOP{Tohlcv,S}(input_filter = always_true, input_modifier = identity, input_modifier_return_type = Tohlcv)

The `BOP` type implements a Balance Of Power indicator.
"""
mutable struct BOP{Tohlcv,S} <: TechnicalIndicator{Tohlcv}
    value::Union{Missing,S}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    input_modifier::Function
    input_filter::Function

    function BOP{Tohlcv}(;
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}        
        S = fieldtype(input_modifier_return_type, :close)
        new{Tohlcv,S}(initialize_indicator_common_fields()..., input_modifier, input_filter)
    end
end

function _calculate_new_value_only_from_incoming_data(ind::BOP, candle)
    return candle.high != candle.low ?
           (candle.close - candle.open) / (candle.high - candle.low) : value(ind)
end
