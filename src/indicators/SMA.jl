const SMA_PERIOD = 3

"""
    SMA{T}(; period = SMA_PERIOD)

The `SMA` type implements a Simple Moving Average indicator.
"""
mutable struct SMA{Tval} <: MovingAverageIndicator{Tval}
    value::Union{Missing,Tval}
    n::Int

    period::Int
    input_values::CircBuff{Tval}

    function SMA{Tval}(; period = SMA_PERIOD) where {Tval}
        input = CircBuff(Tval, period, rev = false)
        new{Tval}(missing, 0, period, input)
    end
end

function OnlineStatsBase._fit!(ind::SMA, data)
    if ind.n < ind.period
        ind.n += 1
    end
    fit!(ind.input_values, data)
    # values = value(ind.input_values)
    values = ind.input_values.value
    ind.value = sum(values) / length(values)  # mean(values)
end
