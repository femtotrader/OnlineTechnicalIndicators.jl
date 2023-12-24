const ChaikinOsc_FAST_PERIOD = 5
const ChaikinOsc_SLOW_PERIOD = 7

"""
    ChaikinOsc{T}(; fast_period = ChaikinOsc_FAST_PERIOD, slow_period = ChaikinOsc_SLOW_PERIOD)

The ChaikinOsc type implements a Chaikin Oscillator.
"""
mutable struct ChaikinOsc{Tval} <: AbstractIncTAIndicator
    accu_dist::AccuDist{Tval}
    fast_ema::EMA{Tval}
    slow_ema::EMA{Tval}

    value::CircularBuffer{Union{Tval,Missing}}

    function ChaikinOsc{Tval}(;
        fast_period = ChaikinOsc_FAST_PERIOD,
        slow_period = ChaikinOsc_SLOW_PERIOD,
    ) where {Tval}
        accu_dist = AccuDist{Tval}(memory = fast_period)
        fast_ema = EMA{Tval}(period = fast_period)
        slow_ema = EMA{Tval}(period = slow_period)
        value = CircularBuffer{Union{Tval,Missing}}(fast_period)
        new{Tval}(accu_dist, fast_ema, slow_ema, value)
    end
end

function Base.push!(ind::ChaikinOsc, candle::OHLCV)
    push!(ind.accu_dist, candle)

    if !has_output_value(ind.accu_dist)
        out_val = missing
        push!(ind.value, out_val)
        return out_val
    end

    val = ind.accu_dist.value[end]
    push!(ind.fast_ema, val)
    push!(ind.slow_ema, val)

    if !has_output_value(ind.fast_ema) || !has_output_value(ind.slow_ema)
        out_val = missing
        push!(ind.value, out_val)
        return out_val
    end

    out_val = ind.fast_ema.value[end] - ind.slow_ema.value[end]
    push!(ind.value, out_val)
    return out_val
end
