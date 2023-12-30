const MeanDev_PERIOD = 3

"""
    MeanDev{T}(; period = MeanDev_PERIOD, ma = SMA)

The `MeanDev` type implements a Mean Deviation indicator.
"""
mutable struct MeanDev{Tval} <: TechnicalIndicator{Tval}
    value::Union{Missing,Tval}
    n::Int

    period::Integer

    sub_indicators::Series  # field ma needs to be available for CCI calculation
    ma::MovingAverageIndicator  # SMA

    input_values::CircBuff

    function MeanDev{Tval}(; period = MeanDev_PERIOD, ma = SMA) where {Tval}
        input_values = CircBuff(Tval, period, rev = false)
        #ma = SMA{Tval}(period = period)
        _ma = MAFactory(Tval)(ma, period)
        sub_indicators = Series(_ma)
        new{Tval}(missing, 0, period, sub_indicators, _ma, input_values)
    end
end

function OnlineStatsBase._fit!(ind::MeanDev, data)
    fit!(ind.input_values, data)
    fit!(ind.sub_indicators, data)
    if ind.n < ind.period
        ind.n += 1
    end
    _ma = value(ind.ma)
    ind.value = sum(abs.(value(ind.input_values) .- _ma)) / ind.period
    return ind.value
end
