"""
    TrueRange{Tohlcv}(; input_filter = always_true, input_modifier = identity, input_modifier_return_type = Tohlcv)

The `TrueRange` type implements a True Range indicator.
"""
mutable struct TrueRange{Tohlcv,IN,S} <: TechnicalIndicatorSingleOutput{Tohlcv}
    value::Union{Missing,S}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    input_modifier::Function
    input_filter::Function
    input_values::CircBuff

    function TrueRange{Tohlcv}(;
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        if hasfield(T2, :close)
            S = fieldtype(T2, :close)
        else
            S = Float64
        end
        input_values = CircBuff(T2, 2, rev = false)
        new{Tohlcv,true,S}(
            initialize_indicator_common_fields()...,
            input_modifier,
            input_filter,
            input_values,
        )
    end
end

function _calculate_new_value(ind::TrueRange)
    candle = ind.input_values[end]
    candle_range = candle.high - candle.low

    if ind.n == 1
        return candle_range
    else
        close2 = ind.input_values[end-1].close
        return max(candle_range, abs(candle.high - close2), abs(candle.low - close2))
    end

end
