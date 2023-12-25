const SMA_PERIOD = 3

"""
    SMA{T}(; period = SMA_PERIOD)

The SMA type implements a Simple Moving Average indicator.
"""
mutable struct SMA{Tval} <: OnlineStat{Tval}
    value::Union{Missing,Tval}
    n::Int

    period::Int
    input::CircBuff{Tval}

    function SMA{Tval}(; period = SMA_PERIOD) where {Tval}
        input = CircBuff(Tval, period, rev = false)
        new{Tval}(missing, 0, period, input)
    end
end

function OnlineStatsBase._fit!(ind::SMA, data)
    if ind.n < length(value(ind.input))
        ind.n += 1
    end
    fit!(ind.input, data)
    values = value(ind.input)
    ind.value = sum(values) / length(values)  # mean(values)
end
