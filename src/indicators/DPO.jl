const DPO_PERIOD = 20

"""
    DPO{T}(; period = DPO_PERIOD)

The DPO type implements a Detrended Price Oscillator indicator.
"""
mutable struct DPO{Tval} <: OnlineStat{Tval}
    value::Union{Missing,Tval}
    n::Int

    period::Integer

    ma # SMA

    input::CircBuff{Tval}

    function DPO{Tval}(; period = DPO_PERIOD, ma = SMA) where {Tval}
        input = CircBuff(Tval, period, rev = false)
        _ma = MAFactory(Tval)(ma, period)
        new{Tval}(missing, 0, period, _ma, input)
    end
end

function OnlineStatsBase._fit!(ind::DPO, data)
    fit!(ind.input, data)
    fit!(ind.ma, data)
    if ind.n != ind.period
        ind.n += 1
    end
    semi_period = floor(Int, ind.period / 2)
    if length(ind.input) >= semi_period + 2 && length(ind.ma.value) >= 1
        ind.value = ind.input[end-semi_period-1] - value(ind.ma)
    else
        ind.value = missing
    end
    return ind.value
end
