const EMA_PERIOD = 3


"""
    EMA{T}(; period = EMA_PERIOD, input_filter = always_true, input_modifier = identity, input_modifier_return_type = T)

The `EMA` type implements an Exponential Moving Average indicator.
"""
mutable struct EMA{T1,T2} <: MovingAverageIndicator{T1}
    value::Union{Missing,T2}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    period::Int
    mult::T2
    mult_complement::T2

    rolling::Bool

    input_modifier::Function
    input_filter::Function
    input_values::CircBuff

    function EMA{T1}(;
        period = EMA_PERIOD,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = T1,
    ) where {T1}
        T2 = input_modifier_return_type
        input_values = CircBuff(T2, period, rev = false)
        mult = 2 * one(T2) / (period + one(T2))
        mult_complement = one(T2) - mult
        new{T1,input_modifier_return_type}(
            initialize_indicator_common_fields()...,
            period,
            mult,
            mult_complement,
            false,
            input_modifier,
            input_filter,
            input_values,
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
