const MACD_FAST_PERIOD = 5
const MACD_SLOW_PERIOD = 5
const MACD_SIGNAL_PERIOD = 5

struct MACDVal{Tval}
    macd::Union{Missing,Tval}
    signal::Union{Missing,Tval}
    histogram::Union{Missing,Tval}
end

#=
struct MACDVal{Tval}
    macd::Tval
    signal::Tval
    histogram::Tval
end
=#

"""
    MACD{T}(; fast_period = MACD_FAST_PERIOD, slow_period = MACD_SLOW_PERIOD, signal_period = MACD_SIGNAL_PERIOD)

The MACD type implements Moving Average Convergence Divergence indicator.
"""
mutable struct MACD{Tval} <: OnlineStat{Tval}
    value::Union{Missing,MACDVal{Tval}}
    n::Int

    ema_fast::EMA{Tval}
    ema_slow::EMA{Tval}
    signal_line::EMA{Tval}

    function MACD{Tval}(;
        fast_period = MACD_FAST_PERIOD,
        slow_period = MACD_SLOW_PERIOD,
        signal_period = MACD_SIGNAL_PERIOD,
    ) where {Tval}
        @warn "WIP - buggy"

        ema_fast = EMA{Tval}(period = fast_period)
        ema_slow = EMA{Tval}(period = slow_period)
        signal_line = EMA{Tval}(period = signal_period)

        new{Tval}(missing, 0, ema_fast, ema_slow, signal_line)
    end
end

function OnlineStatsBase._fit!(ind::MACD{Tval}, data::Tval) where {Tval}
    fit!(ind.ema_fast, data)
    fit!(ind.ema_slow, data)
    ind.n += 1
    #=
    if length(ind.ema_fast) > 0 && length(ind.ema_slow) > 0
        macd = value(ind.ema_fast) - value(ind.ema_slow)
        push!(ind.signal_line, macd)

        if length(ind.signal_line.value) > 0
            signal = value(ind.signal_line)
        else
            signal = missing
        end

        histogram = missing
        if (!ismissing(macd)) && (!ismissing(signal))
            histogram = macd - signal
        end

        # macd, signal, histogram = 0.0, 0.0, 0.0
        ind.value = MACDVal{Tval}(macd, signal, histogram)
    else
        ind.value = missing
    end
    =#
    macd, signal, histogram = missing, missing, missing
    ind.value = MACDVal{Tval}(macd, signal, histogram)
end
