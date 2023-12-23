const KAMA_PERIOD = 14
const FAST_EMA_CONSTANT_PERIOD = 2
const SLOW_EMA_CONSTANT_PERIOD = 30

"""
    KAMA{T}(; period = KAMA_PERIOD)

The KAMA type implements a Kaufman's Adaptive Moving Average indicator.
"""
mutable struct KAMA{Tval} <: AbstractIncTAIndicator
    period::Integer

    fast_smoothing_constant::Tval
    slow_smoothing_constant::Tval

    volatilities::CircularBuffer{Tval}

    input::CircularBuffer{Tval}
    output::CircularBuffer{Union{Missing,Tval}}

    function KAMA{Tval}(;
        period = KAMA_PERIOD,
        fast_ema_constant_period = FAST_EMA_CONSTANT_PERIOD,
        slow_ema_constant_period = SLOW_EMA_CONSTANT_PERIOD,
    ) where {Tval}
        fast_smoothing_constant = 2.0 / (fast_ema_constant_period + 1)
        slow_smoothing_constant = 2.0 / (slow_ema_constant_period + 1)

        volatilities = CircularBuffer{Tval}(period)

        input = CircularBuffer{Tval}(period)
        output = CircularBuffer{Union{Missing,Tval}}(period)

        new{Tval}(
            period,
            fast_smoothing_constant,
            slow_smoothing_constant,
            volatilities,
            input,
            output,
        )
    end
end


function Base.push!(ind::KAMA{Tval}, val::Tval) where {Tval}
    push!(ind.input, val)

    if length(ind.input) < 2
        out_val = missing
        push!(ind.output, out_val)
        return out_val
    end

    push!(ind.volatilities, abs(ind.input[end] - ind.input[end-1]))

    if length(ind.volatilities) < ind.period
        out_val = missing
        push!(ind.output, out_val)
        return out_val
    end

    volatility = sum(ind.volatilities)
    change = abs(ind.input[end] - ind.input[1])

    if volatility != 0
        efficiency_ratio = change / volatility
    else
        efficiency_ratio = 0
    end

    smoothing_constant =
        (
            efficiency_ratio * (ind.fast_smoothing_constant - ind.slow_smoothing_constant) +
            ind.slow_smoothing_constant
        )^2

    # if !has_output_value(ind)  # tofix!!!!
    if length(ind.output) == 0  # tofix!!!!
        prev_kama = ind.input[end-1]
    else
        prev_kama = ind.output[end]
    end

    println(prev_kama)

    out_val = prev_kama + smoothing_constant * (ind.input[end] - prev_kama)
    push!(ind.output, out_val)
    return out_val
end
