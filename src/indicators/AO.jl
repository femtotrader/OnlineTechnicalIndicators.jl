const AO_FAST_PERIOD = 3
const AO_SLOW_PERIOD = 21

"""
    AO{Tohlcv,S}(; fast_period = AO_FAST_PERIOD, slow_period = AO_SLOW_PERIOD)

The AO type implements an Awesome Oscillator indicator.
"""
mutable struct AO{Tohlcv,S} <: OnlineStat{Tohlcv}
    value::Union{Missing,S}
    n::Int

    ma_fast  # default SMA
    ma_slow  # default SMA

    function AO{Tohlcv,S}(;
        fast_period = AO_FAST_PERIOD,
        slow_period = AO_SLOW_PERIOD,
        ma_fast = SMA,
        ma_slow = SMA
    ) where {Tohlcv,S}
        @assert fast_period < slow_period "slow_period must be greater than fast_period"
        #_ma_fast = ma_fast{S}(period = fast_period)
        #_ma_slow = ma_slow{S}(period = slow_period)
        _ma_fast = MAFactory(ma_fast, S, fast_period)
        _ma_slow = MAFactory(ma_slow, S, slow_period)
        new{Tohlcv,S}(missing, 0, _ma_fast, _ma_slow)
    end
end

function OnlineStatsBase._fit!(ind::AO, candle)
    ind.n += 1
    median = (candle.high + candle.low) / 2.0
    fit!(ind.ma_fast, median)
    fit!(ind.ma_slow, median)
    if has_output_value(ind.ma_fast) && has_output_value(ind.ma_slow)
        ind.value = value(ind.ma_fast) - value(ind.ma_slow)
    else
        ind.value = missing
    end
end

