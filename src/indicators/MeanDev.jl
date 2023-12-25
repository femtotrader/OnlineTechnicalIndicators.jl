const MeanDev_PERIOD = 3

"""
    MeanDev{T}(; period = MeanDev_PERIOD)

The MeanDev type implements a Mean Deviation indicator.
"""
mutable struct MeanDev{Tval} <: OnlineStat{Tval}
    value::Union{Missing,Tval}

    period::Integer
    sma::SMA{Tval}

    input::CircBuff

    function MeanDev{Tval}(; period = MeanDev_PERIOD) where {Tval}
        input = CircBuff(Tval, period, rev=false)
        value = missing
        sma = SMA{Tval}(period = period)
        new{Tval}(value, period, sma, input)
    end
end

function OnlineStatsBase._fit!(ind::MeanDev{Tval}, data::Tval) where {Tval}
    fit!(ind.input, data)
    fit!(ind.sma, data)
    _sma = value(ind.sma)
    ind.value = sum(abs.(value(ind.input) .- _sma)) / ind.period
    return ind.value
end
