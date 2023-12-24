const MACD_FAST_PERIOD = 5
const MACD_SLOW_PERIOD = 5
const MACD_SIGNAL_PERIOD = 5

struct MACDVal{Tval}
    macd::Tval
    signal::Tval
    histogram::Tval
end

"""
    MACD{T}(; fast_period = MACD_FAST_PERIOD, slow_period = MACD_SLOW_PERIOD, signal_period = MACD_SIGNAL_PERIOD)

The MACD type implements Moving Average Convergence Divergence indicator.
"""
mutable struct MACD{Tval} <: AbstractIncTAIndicator
    ema_fast::EMA{Tval}
    ema_slow::EMA{Tval}
    signal_line::EMA{Tval}

    value::CircularBuffer{Union{Missing,MACDVal{Tval}}}

    function MACD{Tval}(;
        fast_period = MACD_FAST_PERIOD,
        slow_period = MACD_SLOW_PERIOD,
        signal_period = MACD_SIGNAL_PERIOD,
    ) where {Tval}
        @warn "WIP - buggy"

        ema_fast = EMA{Tval}(period = fast_period)
        ema_slow = EMA{Tval}(period = slow_period)
        signal_line = EMA{Tval}(period = signal_period)

        value = CircularBuffer{Union{Missing,MACDVal{Tval}}}(fast_period)
        new{Tval}(ema_fast, ema_slow, signal_line, value)
    end
end

function Base.push!(ind::MACD{Tval}, val::Tval) where {Tval}
    push!(ind.ema_fast, val)
    push!(ind.ema_slow, val)

    if length(ind.ema_fast.value) > 0 && length(ind.ema_slow.value) > 0
        macd = ind.ema_fast.output[end] - ind.ema_slow.output[end]
        push!(ind.signal_line, macd)

        if length(ind.signal_line.value) > 0
            signal = ind.signal_line.output[end]
        else
            signal = missing
        end

        histogram = missing
        if (!ismissing(macd)) && (!ismissing(signal))
            histogram = macd - signal
        end

        # macd, signal, histogram = 0.0, 0.0, 0.0
        out_val = MACDVal{Tval}(macd, signal, histogram)
        push!(ind.value, out_val)
        println(out_val)
        return out_val
    else
        out_val = missing
        push!(ind.value, out_val)
        println(out_val)
        return out_val
    end
end
