"""
    BOP{Tohlcv}(input_modifier_return_type = Tohlcv)

The `BOP` type implements a Balance Of Power indicator.
"""
mutable struct BOP{Tohlcv,IN,S} <: TechnicalIndicatorSingleOutput{Tohlcv}
    value::Union{Missing,S}
    n::Int

    function BOP{Tohlcv}(; input_modifier_return_type = Tohlcv) where {Tohlcv}
        S = fieldtype(input_modifier_return_type, :close)
        new{Tohlcv,true,S}(
            missing,
            0)
    end
end

function BOP(; input_modifier_return_type = OHLCV{Missing,Float64,Float64})
    BOP{input_modifier_return_type}(;
        input_modifier_return_type=input_modifier_return_type)
end

function _calculate_new_value_only_from_incoming_data(ind::BOP, candle)
    return candle.high != candle.low ?
           (candle.close - candle.open) / (candle.high - candle.low) : value(ind)
end
