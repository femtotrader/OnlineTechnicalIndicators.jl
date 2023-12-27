const MeanDev_PERIOD = 3

"""
    MeanDev{T}(; period = MeanDev_PERIOD, ma = SMA)

The MeanDev type implements a Mean Deviation indicator.
"""
mutable struct MeanDev{Tval} <: OnlineStat{Tval}
    value::Union{Missing,Tval}
    n::Int

    period::Integer
    sma  # SMA

    input::CircBuff

    function MeanDev{Tval}(; period = MeanDev_PERIOD, ma = SMA) where {Tval}
        input = CircBuff(Tval, period, rev = false)
        #sma = SMA{Tval}(period = period)
        _ma = MAFactory(Tval)(ma, period)
        new{Tval}(missing, 0, period, _ma, input)
    end
end

function OnlineStatsBase._fit!(ind::MeanDev, data)
    fit!(ind.input, data)
    fit!(ind.sma, data)
    if ind.n < ind.period
        ind.n += 1
    end
    _sma = value(ind.sma)
    ind.value = sum(abs.(value(ind.input) .- _sma)) / ind.period
    return ind.value
end
