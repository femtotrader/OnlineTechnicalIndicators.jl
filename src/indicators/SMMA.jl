const SMMA_PERIOD = 3

"""
    SMMA{T}(; period = SMMA_PERIOD, input_filter = always_true, input_modifier = identity, input_modifier_return_type = T)

The `SMMA` type implements a SMoothed Moving Average indicator.
"""
mutable struct SMMA{Tval,IN,T2} <: MovingAverageIndicator{Tval}
    value::Union{Missing,T2}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    period::Integer

    rolling::Bool

    input_modifier::Function
    input_filter::Function
    input_values::CircBuff

    function SMMA{Tval}(;
        period = SMMA_PERIOD,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tval,
    ) where {Tval}
        T2 = input_modifier_return_type
        value = missing
        rolling = false
        input_values = CircBuff(T2, period, rev = false)
        new{Tval,false,T2}(
            initialize_indicator_common_fields()...,
            period,
            rolling,
            input_modifier,
            input_filter,
            input_values,
        )
    end
end

function _calculate_new_value(ind::SMMA)
    if ind.rolling  # CircBuff is full and rolling
        data = ind.input_values[end]
        return (ind.value * (ind.period - 1) + data) / ind.period
    else
        if ind.n == ind.period # CircBuff is full but not rolling
            ind.rolling = true
            return sum(ind.input_values.value) / ind.period
        else  # CircBuff is filling up
            return missing
        end
    end
end
