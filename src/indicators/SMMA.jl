const SMMA_PERIOD = 3

"""
    SMMA{T}(; period = SMMA_PERIOD)

The `SMMA` type implements a SMoothed Moving Average indicator.
"""
mutable struct SMMA{Tval} <: MovingAverageIndicator{Tval}
    value::Union{Missing,Tval}
    n::Int

    period::Integer

    rolling::Bool

    input_values::CircBuff{Tval}

    function SMMA{Tval}(; period = SMMA_PERIOD) where {Tval}
        value = missing
        rolling = false
        input = CircBuff(Tval, period, rev = false)
        new{Tval}(value, 0, period, rolling, input)
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
