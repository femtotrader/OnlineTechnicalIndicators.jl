const ZLEMA_PERIOD = 20


"""
    ZLEMA{T}(; period=ZLEMA_PERIOD)

The `ZLEMA` type implements a Zero Lag Exponential Moving Average indicator.
"""
mutable struct ZLEMA{Tval} <: MovingAverageIndicator{Tval}
    value::Union{Missing,Tval}
    n::Int

    output_listeners::Series

    period::Int
    lag::Int
    ema::EMA

    input_indicator::Union{Missing,TechnicalIndicator}
    input_values::CircBuff{Tval}

    function ZLEMA{Tval}(; period = ZLEMA_PERIOD) where {Tval}
        lag = round(Int, (period - 1) / 2.0)
        input_values = CircBuff(Tval, lag + 1, rev = false)
        ema = EMA{Tval}(period = period)
        output_listeners = Series()
        input_indicator = missing
        new{Tval}(missing, 0, output_listeners, period, lag, ema, input_indicator, input_values)
    end
end

function _calculate_new_value(ind::ZLEMA)
    ind.n += 1
    if length(ind.input_values) >= ind.lag + 1
        fit!(ind.ema, ind.input_values[end] + (ind.input_values[end] - ind.input_values[end-ind.lag]))
        return value(ind.ema)
    else
        return missing
    end
end

function OnlineStatsBase._fit!(ind::ZLEMA, data)
    fit!(ind.input_values, data)
    ind.value = _calculate_new_value(ind)
    fit_listeners!(ind)
end
