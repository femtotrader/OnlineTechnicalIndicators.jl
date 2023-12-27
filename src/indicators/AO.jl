const AO_FAST_PERIOD = 3
const AO_SLOW_PERIOD = 21

"""
    AO{Tohlcv,S}(; fast_period = AO_FAST_PERIOD, slow_period = AO_SLOW_PERIOD)

The AO type implements an Awesome Oscillator indicator.
"""
mutable struct AO{Tohlcv,S} <: OnlineStat{Tohlcv}
    value::Union{Missing,S}
    n::Int

    sma_fast::SMA{S}
    sma_slow::SMA{S}

    function AO{Tohlcv,S}(;
        fast_period = AO_FAST_PERIOD,
        slow_period = AO_SLOW_PERIOD,
    ) where {Tohlcv,S}
        @assert fast_period < slow_period "slow_period must be greater than fast_period"
        sma_fast = SMA{S}(period = fast_period)
        sma_slow = SMA{S}(period = slow_period)
        new{Tohlcv,S}(missing, 0, sma_fast, sma_slow)
    end
end

function OnlineStatsBase._fit!(ind::AO, candle)
    ind.n += 1
    median = (candle.high + candle.low) / 2.0
    fit!(ind.sma_fast, median)
    fit!(ind.sma_slow, median)
    if has_output_value(ind.sma_fast) && has_output_value(ind.sma_slow)
        ind.value = value(ind.sma_fast) - value(ind.sma_slow)
    else
        ind.value = missing
    end
end

