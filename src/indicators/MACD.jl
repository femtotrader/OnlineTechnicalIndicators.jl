const MACD_FAST_PERIOD = 5
const MACD_SLOW_PERIOD = 5
const MACD_SIGNAL_PERIOD = 5

struct MACDVal{Tval}
    macd::Tval
    signal::Tval
    histogram::Tval
end

"""
    MACD{T}(; fast_period=MACD_FAST_PERIOD, slow_period=MACD_SLOW_PERIOD, signal_period=MACD_SIGNAL_PERIOD)

The MACD type implements Moving Average Convergence Divergence indicator.
"""
mutable struct MACD{Tval} <: AbstractIncTAIndicator
    ema_fast::EMA{Tval}
    ema_slow::EMA{Tval}
    signal_line::EMA{Tval}

    output::CircularBuffer{Union{Missing, MACDVal{Tval}}}

    function MACD{Tval}(; fast_period=MACD_FAST_PERIOD, slow_period=MACD_SLOW_PERIOD, signal_period=MACD_SIGNAL_PERIOD) where {Tval}
        ema_fast = EMA{Tval}(period=fast_period)
        ema_slow = EMA{Tval}(period=slow_period)
        signal_line = EMA{Tval}(period=signal_period)
    
        output = CircularBuffer{Union{Missing, MACDVal{Tval}}}(fast_period)
        new{Tval}(ema_fast, ema_slow, signal_line, output)
    end
end

function Base.push!(ind::MACD{Tval}, val::Tval) where {Tval}
    push!(ind.ema_fast, val)
    push!(ind.ema_slow, val)

    macd, signal, histogram = 0.0, 0.0, 0.0

    out_val = MACDVal{Tval}(macd, signal, histogram)
    push!(ind.output, out_val)
    return out_val
end
