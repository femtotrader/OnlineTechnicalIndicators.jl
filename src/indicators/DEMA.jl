const DEMA_PERIOD = 20

"""
    DEMA{T}(; period = DEMA_PERIOD)

The DEMA type implements a Double Exponential Moving Average indicator.
"""
mutable struct DEMA{Tval} <: OnlineStat{Tval}
    value::Union{Missing,Tval}
    n::Int

    period::Integer

    ema::EMA{Tval}
    ema_ema::EMA{Tval}

    function DEMA{Tval}(; period = DEMA_PERIOD) where {Tval}
        ema = EMA{Tval}(period = period)
        ema_ema = EMA{Tval}(period = period)
        new{Tval}(missing, 0, period, ema, ema_ema)
    end
end

function OnlineStatsBase._fit!(ind::DEMA, data)
    fit!(ind.ema, data)
    if ind.n != ind.period
        ind.n += 1
    end
    if has_output_value(ind.ema)
        fit!(ind.ema_ema, ind.ema.value[end])
        if has_output_value(ind.ema_ema)
            ind.value = 2.0 * ind.ema.value[end] - ind.ema_ema.value[end]
        else
            ind.value = missing
        end
    else
        ind.value = missing
    end
end
