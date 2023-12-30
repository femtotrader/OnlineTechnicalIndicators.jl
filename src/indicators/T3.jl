const T3_PERIOD = 20


"""
    T3{T}(; period=T3_PERIOD)

The `T3` type implements a Zero Lag Exponential Moving Average indicator.
"""
mutable struct T3{Tval} <: MovingAverageIndicator{Tval}
    value::Union{Missing,Tval}
    n::Int

    output_listeners::Series

    period::Int
    ema::EMA

    input_indicator::Union{Missing,TechnicalIndicator}
    input_values::CircBuff{Tval}

    function T3{Tval}(; period = T3_PERIOD) where {Tval}
        input_values = CircBuff(Tval, 2, rev = false)
        ema1 = EMA{Tval}(period = period)
        ema2 = EMA{Tval}(period = period)
        ema3 = EMA{Tval}(period = period)
        ema4 = EMA{Tval}(period = period)
        ema5 = EMA{Tval}(period = period)
        ema6 = EMA{Tval}(period = period)
        output_listeners = Series()
        input_indicator = missing
        new{Tval}(missing, 0, output_listeners, period, ema1, ema2, ema3, ema4, ema5, ema6, input_indicator, input_values)
    end
end

function _calculate_new_value(ind::T3)
    ind.n += 1
    if length(ind.input_values) >= 1
        fit!(ind.ema, ind.input_values[end] + (ind.input_values[end] - ind.input_values[end-ind.lag]))
        return value(ind.ema)
    else
        return missing
    end
end

function OnlineStatsBase._fit!(ind::T3, data)
    fit!(ind.input_values, data)
    ind.value = _calculate_new_value(ind)
    fit_listeners!(ind)
end
