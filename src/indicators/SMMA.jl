const SMMA_PERIOD = 3

"""
    SMMA{T}(; period = SMA_PERIOD)

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


function OnlineStatsBase._fit!(ind::SMMA, data)
    fit!(ind.input_values, data)
    if ind.rolling  # CircBuff is full and rolling
        ind.value = (ind.value * (ind.period - 1) + data) / ind.period
    else
        if ind.n + 1 == ind.period # CircBuff is full but not rolling
            ind.rolling = true
            ind.n += 1
            ind.value = sum(ind.input_values.value) / ind.period
        else  # CircBuff is filling up
            ind.n += 1
            ind.value = missing
        end
    end
end
