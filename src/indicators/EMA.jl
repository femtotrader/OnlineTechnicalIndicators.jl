const EMA_PERIOD = 3


"""
    EMA{T}(; period = EMA_PERIOD, input_modifier_return_type = T)

The `EMA` type implements an Exponential Moving Average indicator.
"""
mutable struct EMA{T1,IN,T2} <: MovingAverageIndicator{T1}
    value::Union{Missing,T2}
    n::Int

    period::Int
    mult::T2
    mult_complement::T2

    rolling::Bool

    input_values::CircBuff

    function EMA{T1}(;
        period = EMA_PERIOD,
        input_modifier_return_type = T1,
    ) where {T1}
        T2 = input_modifier_return_type
        input_values = CircBuff(T2, period, rev = false)
        mult = 2 * one(T2) / (period + one(T2))
        mult_complement = one(T2) - mult
        new{T1,false,T2}(
            missing,
            0,
            period,
            mult,
            mult_complement,
            false,
            input_values,
        )
    end
end

function EMA(;
    period = EMA_PERIOD,
    input_modifier_return_type = Float64,
)
    EMA{input_modifier_return_type}(;
        period=period,
        input_modifier_return_type=input_modifier_return_type)
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
