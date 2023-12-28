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
    MACD{T}(; fast_period = MACD_FAST_PERIOD, slow_period = MACD_SLOW_PERIOD, signal_period = MACD_SIGNAL_PERIOD, ma = EMA)

The MACD type implements Moving Average Convergence Divergence indicator.
"""
mutable struct MACD{Tval} <: TechnicalIndicator{Tval}
    value::Union{Missing,MACDVal{Tval}}
    n::Int

    fast_ma::EMA{Tval}
    slow_ma::EMA{Tval}
    signal_line::EMA{Tval}

    function MACD{Tval}(;
        fast_period = MACD_FAST_PERIOD,
        slow_period = MACD_SLOW_PERIOD,
        signal_period = MACD_SIGNAL_PERIOD,
        ma = EMA
    ) where {Tval}
        @warn "WIP - buggy"

        # fast_ma = EMA{Tval}(period = fast_period)
        # slow_ma = EMA{Tval}(period = slow_period)

        fast_ma = MAFactory(S)(ma, fast_period)
        slow_ma = MAFactory(S)(ma, slow_period)

        # signal_line = EMA{Tval}(period = signal_period)
        signal_line = MAFactory(S)(ma, signal_period)

        new{Tval}(missing, 0, fast_ma, slow_ma, signal_line)
    end
end

function OnlineStatsBase._fit!(ind::MACD{Tval}, data::Tval) where {Tval}
    fit!(ind.fast_ma, data)
    fit!(ind.slow_ma, data)
    ind.n += 1
    #=
    if length(ind.fast_ma) > 0 && length(ind.slow_ma) > 0
        macd = value(ind.fast_ma) - value(ind.slow_ma)
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
