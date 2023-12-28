const StdDev_PERIOD = 3

"""
    StdDev{T}(; period = StdDev_PERIOD)

The `StdDev` type implements a Standard Deviation indicator.
"""
mutable struct StdDev{Tval} <: TechnicalIndicator{Tval}
    value::Union{Missing,Tval}
    n::Int

    period::Integer

    input::CircBuff{Tval}

    function StdDev{Tval}(; period = StdDev_PERIOD) where {Tval}
        input = CircBuff(Tval, period, rev = false)
        new{Tval}(missing, 0, period, input)
    end
end

function OnlineStatsBase._fit!(ind::StdDev, data)
    fit!(ind.input, data)
    if ind.n < ind.period
        ind.n += 1
    end
    _mean = sum(value(ind.input)) / ind.period
    ind.value = sqrt(sum([(item - _mean)^2 for item in value(ind.input)]) / ind.period)
    return ind.value
end
