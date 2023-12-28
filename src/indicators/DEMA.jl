const DEMA_PERIOD = 20

"""
    DEMA{T}(; period = DEMA_PERIOD)

The `DEMA` type implements a Double Exponential Moving Average indicator.
"""
mutable struct DEMA{Tval} <: MovingAverageIndicator{Tval}
    value::Union{Missing,Tval}
    n::Int

    period::Integer

    sub_indicators::Series
    # ma  # EMA
    ma_ma::MovingAverageIndicator  # EMA

    function DEMA{Tval}(; period = DEMA_PERIOD, ma = EMA) where {Tval}
        # _ma = EMA{Tval}(period = period)
        _ma = MAFactory(Tval)(ma, period)
        # _ma_ma = EMA{Tval}(period = period)
        _ma_ma = MAFactory(Tval)(ma, period)
        sub_indicators = Series(_ma)
        new{Tval}(missing, 0, period, sub_indicators, _ma_ma)
    end
end

function OnlineStatsBase._fit!(ind::DEMA, data)
    fit!(ind.sub_indicators, data)
    ma, = ind.sub_indicators.stats
    if ind.n != ind.period
        ind.n += 1
    end
    if has_output_value(ma)
        fit!(ind.ma_ma, value(ma))
        if has_output_value(ind.ma_ma)
            ind.value = 2.0 * value(ma) - value(ind.ma_ma)
        else
            ind.value = missing
        end
    else
        ind.value = missing
    end
end
