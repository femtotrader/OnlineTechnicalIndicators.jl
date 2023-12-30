const KAMA_PERIOD = 14
const KAMA_FAST_EMA_CONSTANT_PERIOD = 2
const KAMA_SLOW_EMA_CONSTANT_PERIOD = 30

"""
    KAMA{T}(; period = KAMA_PERIOD, fast_ema_constant_period = KAMA_FAST_EMA_CONSTANT_PERIOD, slow_ema_constant_period = KAMA_SLOW_EMA_CONSTANT_PERIOD)

The `KAMA` type implements a Kaufman's Adaptive Moving Average indicator.
"""
mutable struct KAMA{Tval} <: MovingAverageIndicator{Tval}
    value::Union{Missing,Tval}
    n::Int

    period::Integer

    fast_smoothing_constant::Tval
    slow_smoothing_constant::Tval

    volatilities::CircBuff{Tval}

    input_values::CircBuff{Tval}

    function KAMA{Tval}(;
        period = KAMA_PERIOD,
        fast_ema_constant_period = KAMA_FAST_EMA_CONSTANT_PERIOD,
        slow_ema_constant_period = KAMA_SLOW_EMA_CONSTANT_PERIOD,
    ) where {Tval}
        @warn "WIP - buggy"

        fast_smoothing_constant = 2.0 / (fast_ema_constant_period + 1)
        slow_smoothing_constant = 2.0 / (slow_ema_constant_period + 1)

        volatilities = CircBuff(Tval, period, rev = false)

        input_values = CircBuff(Tval, period, rev = false)

        new{Tval}(
            missing,
            0,
            period,
            fast_smoothing_constant,
            slow_smoothing_constant,
            volatilities,
            input_values,
        )
    end
end

function OnlineStatsBase._fit!(ind::KAMA, data)
    fit!(ind.input_values, data)
    if ind.n != ind.period
        ind.n += 1
    end

    if ind.n >= 2
        fit!(ind.volatilities, abs(ind.input_values[end] - ind.input_values[end-1]))

        if length(ind.volatilities) < ind.period
            ind.value = missing
            return
        end

        volatility = sum(value(ind.volatilities))
        change = abs(ind.input_values[end] - ind.input_values[1])

        if volatility != 0
            efficiency_ratio = change / volatility
        else
            efficiency_ratio = 0
        end

        smoothing_constant =
            (
                efficiency_ratio *
                (ind.fast_smoothing_constant - ind.slow_smoothing_constant) +
                ind.slow_smoothing_constant
            )^2

        if !has_output_value(ind)  # tofix!!!!
            #if length(ind.value) == 0  # tofix!!!!
            prev_kama = ind.input_values[end-1]
        else
            prev_kama = ind.value[end]
        end

        ind.value = prev_kama + smoothing_constant * (ind.input_values[end] - prev_kama)
    end

end
