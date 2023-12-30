const DPO_PERIOD = 20

"""
    DPO{T}(; period = DPO_PERIOD)

The `DPO` type implements a Detrended Price Oscillator indicator.
"""
mutable struct DPO{Tval} <: TechnicalIndicator{Tval}
    value::Union{Missing,Tval}
    n::Int

    period::Integer

    sub_indicators::Series
    ma::MovingAverageIndicator # SMA

    input_values::CircBuff{Tval}

    function DPO{Tval}(; period = DPO_PERIOD, ma = SMA) where {Tval}
        input_values = CircBuff(Tval, period, rev = false)
        _ma = MAFactory(Tval)(ma, period)
        sub_indicators = Series(_ma)
        new{Tval}(missing, 0, period, sub_indicators, _ma, input_values)
    end
end

function OnlineStatsBase._fit!(ind::DPO, data)
    fit!(ind.input_values, data)
    fit!(ind.sub_indicators, data)
    #ma, = ind.sub_indicators.stats
    if ind.n != ind.period
        ind.n += 1
    end
    semi_period = floor(Int, ind.period / 2)
    if length(ind.input_values) >= semi_period + 2 && length(ind.ma.input_values) >= 1
        ind.value = ind.input_values[end-semi_period-1] - value(ind.ma)
    else
        ind.value = missing
    end
end
