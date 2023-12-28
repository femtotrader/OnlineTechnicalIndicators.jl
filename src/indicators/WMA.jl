const WMA_PERIOD = 3

"""
    WMA{T}(; period = WMA_PERIOD)

The WMA type implements a Weighted Moving Average indicator.
"""
mutable struct WMA{Tval} <: MovingAverageIndicator{Tval}
    value::Union{Missing,Tval}
    n::Int

    period::Integer

    total::Tval
    numerator::Tval
    denominator::Tval

    input::CircBuff{Tval}

    function WMA{Tval}(; period = WMA_PERIOD) where {Tval}
        input = CircBuff(Tval, period, rev = false)
        total = zero(Tval)
        numerator = zero(Tval)
        denominator = period * (period + 1) / 2.0
        new{Tval}(missing, 0, period, total, numerator, denominator, input)
    end
end

function OnlineStatsBase._fit!(ind::WMA{Tval}, data::Tval) where {Tval}
    if ind.n == ind.period
        losing = ind.input[1]
    else
        losing = zero(Tval)
        ind.n += 1
    end
    fit!(ind.input, data)
    # See https://en.wikipedia.org/wiki/Moving_average#Weighted_moving_average
    ind.numerator = ind.numerator + ind.period * data - ind.total
    ind.total = ind.total + data - losing
    ind.value = ind.numerator / ind.denominator
    return ind.value
end
