const WilderMA_PERIOD = 3


"""
    WilderMA{T1}(; period = WilderMA_PERIOD, input_filter = always_true, input_modifier = identity, input_modifier_return_type = T2)

The `WilderMA` type implements a Wilder's moving average indicator.
"""
mutable struct WilderMA{T1,IN,T2} <: MovingAverageIndicator{T1}
    value::Union{Missing,T2}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    period::Int
    rolling::Bool

    input_modifier::Function
    input_filter::Function
    input_values::CircBuff

    function WilderMA{T1}(;
        period = WilderMA_PERIOD,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = T1,
    ) where {T1}
        T2 = input_modifier_return_type
        input_values = CircBuff(T2, period + 1, rev = false)
        new{T1,false,T2}(
            initialize_indicator_common_fields()...,
            period,
            false,
            input_modifier,
            input_filter,
            input_values,
        )
    end
end

function _calculate_new_value(ind::WilderMA)
    if ind.rolling  # CircBuff is full and rolling
        return (value(ind) * (ind.period - 1) + ind.input_values[end]) / ind.period
    else
        if ind.n == ind.period  # CircBuff is full but not rolling
            ind.rolling = true
            return sum(value(ind.input_values)) / ind.period
        else  # CircBuff is filling up
            return missing
        end
    end
end
