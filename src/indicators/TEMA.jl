const TEMA_PERIOD = 20

"""
    TEMA{T}(; period = TEMA_PERIOD)

The TEMA type implements a Double Exponential Moving Average indicator.
"""
mutable struct TEMA{Tval} <: OnlineStat{Tval}
    value::Union{Missing,Tval}
    n::Int

    period::Integer

    ema::EMA{Tval}
    ema_ema::EMA{Tval}
    ema_ema_ema::EMA{Tval}

    function TEMA{Tval}(; period = TEMA_PERIOD) where {Tval}
        ema = EMA{Tval}(period = period)
        ema_ema = EMA{Tval}(period = period)
        ema_ema_ema = EMA{Tval}(period = period)
        new{Tval}(missing, 0, period, ema, ema_ema, ema_ema_ema)
    end
end

function OnlineStatsBase._fit!(ind::TEMA, data)
    fit!(ind.ema, data)
    if ind.n != ind.period
        ind.n += 1
    end
    if has_output_value(ind.ema)
        fit!(ind.ema_ema, ind.ema.value[end])
        if has_output_value(ind.ema_ema)
            fit!(ind.ema_ema_ema, ind.ema_ema.value[end])
            if has_output_value(ind.ema_ema_ema)
                ind.value =
                    3.0 * ind.ema.value[end] - 3.0 * ind.ema_ema.value[end] +
                    ind.ema_ema_ema.value[end]
            else
                ind.value = missing
            end
        else
            ind.value = missing
        end
    else
        ind.value = missing
    end
end
