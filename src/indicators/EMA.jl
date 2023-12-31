const EMA_PERIOD = 3


"""
    EMA{T}(; period = EMA_PERIOD, input_filter = always_true, input_modifier = identity, input_modifier_return_type = T2)

The `EMA` type implements an Exponential Moving Average indicator.
"""
mutable struct EMA{T1,T2} <: MovingAverageIndicator{T1}
    value::Union{Missing,T2}
    n::Int

    output_listeners::Series

    period::Int
    mult::T2
    mult_complement::T2

    rolling::Bool
    input_indicator::Union{Missing,TechnicalIndicator}
    input_values::CircBuff

    input_filter::Function
    input_modifier::Function

    function EMA{T1}(; period = EMA_PERIOD, input_filter = always_true, input_modifier = identity, input_modifier_return_type = T1) where {T1}
        T2 = input_modifier_return_type
        input_values = CircBuff(T2, period, rev = false)
        mult = T2(2) / (period + T2(1))
        mult_complement = T2(1) - mult
        output_listeners = Series()
        input_indicator = missing
        new{T1,input_modifier_return_type}(
            missing,
            0,
            output_listeners,
            period,
            mult,
            mult_complement,
            false,
            input_indicator,
            input_values,
            input_filter,
            input_modifier,
        )
    end
end

function _calculate_new_value(ind::EMA)
    if ind.rolling  # CircBuff is full and rolling
        return ind.mult * ind.input_values[end] + ind.mult_complement * ind.value
    else
        if ind.n == ind.period # CircBuff is full but not rolling
            ind.rolling = true
            return sum(ind.input_values.value) / ind.period
        else  # CircBuff is filling up
            return missing
        end
    end
end