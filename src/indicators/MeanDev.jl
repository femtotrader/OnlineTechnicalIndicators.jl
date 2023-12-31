const MeanDev_PERIOD = 3

"""
    MeanDev{T}(; period = MeanDev_PERIOD, ma = SMA, input_filter = always_true, input_modifier = identity, input_modifier_return_type = T)

The `MeanDev` type implements a Mean Deviation indicator.
"""
mutable struct MeanDev{Tval} <: TechnicalIndicator{Tval}
    value::Union{Missing,Tval}
    n::Int

    period::Integer

    sub_indicators::Series  # field ma needs to be available for CCI calculation
    ma::MovingAverageIndicator  # SMA

    input_values::CircBuff

    function MeanDev{Tval}(;
        period = MeanDev_PERIOD,
        ma = SMA,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tval,
    ) where {Tval}
        input_values = CircBuff(Tval, period, rev = false)
        #_ma = SMA{Tval}(period = period)
        _ma = MAFactory(Tval)(ma, period = period)
        sub_indicators = Series(_ma)
        new{Tval}(missing, 0, period, sub_indicators, _ma, input_values)
    end
end

function _calculate_new_value(ind::MeanDev)
    _ma = value(ind.ma)
    return sum(abs.(value(ind.input_values) .- _ma)) / ind.period
end
