const DEMA_PERIOD = 20

"""
    DEMA{T}(; period = DEMA_PERIOD)

The DEMA type implements a Double Exponential Moving Average indicator.
"""
mutable struct DEMA{Tval} <: OnlineStat{Tval}
    value::Union{Missing,Tval}
    n::Int

    period::Integer

    ma  # EMA
    ma_ma  # EMA

    function DEMA{Tval}(; period = DEMA_PERIOD, ma = EMA) where {Tval}
        # _ma = EMA{Tval}(period = period)
        _ma = MAFactory(Tval)(ma, period)
        # _ma_ma = EMA{Tval}(period = period)
        _ma_ma = MAFactory(Tval)(ma, period)
        new{Tval}(missing, 0, period, _ma, _ma_ma)
    end
end

function OnlineStatsBase._fit!(ind::DEMA, data)
    fit!(ind.ma, data)
    if ind.n != ind.period
        ind.n += 1
    end
    if has_output_value(ind.ma)
        fit!(ind.ma_ma, ind.ma.value[end])
        if has_output_value(ind.ma_ma)
            ind.value = 2.0 * ind.ma.value[end] - ind.ma_ma.value[end]
        else
            ind.value = missing
        end
    else
        ind.value = missing
    end
end
