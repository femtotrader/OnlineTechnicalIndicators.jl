"""
    OBV{Tohlcv}(input_filter = always_true, input_modifier = identity, input_modifier_return_type = Tohlcv)

The `OBV` type implements On Balance Volume indicator.
"""
mutable struct OBV{Tohlcv,IN,S} <: TechnicalIndicatorSingleOutput{Tohlcv}
    value::Union{Missing,S}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    input_modifier::Function
    input_filter::Function
    input_values::CircBuff

    function OBV{Tohlcv}(;
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        S = fieldtype(T2, :close)
        input_values = CircBuff(T2, 2, rev = false)
        new{Tohlcv,true,S}(
            initialize_indicator_common_fields()...,
            input_modifier,
            input_filter,
            input_values,
        )
    end
end

function OBV(;
    input_filter = always_true,
    input_modifier = identity,
    input_modifier_return_type = OHLCV{Missing,Float64,Float64},
)
    OBV{input_modifier_return_type}(;
        input_filter=input_filter,
        input_modifier=input_modifier,
        input_modifier_return_type=input_modifier_return_type)
end

function _calculate_new_value(ind::OBV)
    candle = ind.input_values[end]
    if ind.n != 1
        candle_prev = ind.input_values[end-1]
        if candle.close == candle_prev.close
            return value(ind)
        elseif candle.close > candle_prev.close
            return value(ind) + candle.volume
        else
            return value(ind) - candle.volume
        end
    else
        return candle.volume
    end
end
