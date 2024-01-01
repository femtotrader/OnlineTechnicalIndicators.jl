const ZLEMA_PERIOD = 20


"""
    ZLEMA{T}(; period=ZLEMA_PERIOD, input_filter = always_true, input_modifier = identity, input_modifier_return_type = T)

The `ZLEMA` type implements a Zero Lag Exponential Moving Average indicator.
"""
mutable struct ZLEMA{Tval,T2} <: MovingAverageIndicator{Tval}
    value::Union{Missing,T2}
    n::Int

    output_listeners::Series

    period::Int
    lag::Int
    ema::EMA

    input_modifier::Function
    input_filter::Function
    input_indicator::Union{Missing,TechnicalIndicator}
    input_values::CircBuff

    function ZLEMA{Tval}(;
        period = ZLEMA_PERIOD,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tval,
    ) where {Tval}
        T2 = input_modifier_return_type
        lag = round(Int, (period - 1) / 2.0)
        input_values = CircBuff(T2, lag + 1, rev = false)
        ema = EMA{T2}(period = period)
        output_listeners = Series()
        input_indicator = missing
        new{Tval,T2}(
            missing,
            0,
            output_listeners,
            period,
            lag,
            ema,
            input_modifier,
            input_filter,
            input_indicator,
            input_values,
        )
    end
end

function _calculate_new_value(ind::ZLEMA)
    if length(ind.input_values) >= ind.lag + 1
        fit!(
            ind.ema,
            ind.input_values[end] + (ind.input_values[end] - ind.input_values[end-ind.lag]),
        )
        return value(ind.ema)
    else
        return missing
    end
end
