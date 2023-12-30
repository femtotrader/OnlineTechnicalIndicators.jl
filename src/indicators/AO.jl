const AO_FAST_PERIOD = 3
const AO_SLOW_PERIOD = 21

"""
    AO{Tohlcv,S}(; fast_period = AO_FAST_PERIOD, slow_period = AO_SLOW_PERIOD, fast_ma = SMA, slow_ma = SMA)

The `AO` type implements an Awesome Oscillator indicator.
"""
mutable struct AO{Tohlcv,S} <: TechnicalIndicator{Tohlcv}
    value::Union{Missing,S}
    n::Int

    fast_ma::Any  # default SMA
    slow_ma::Any  # default SMA

    function AO{Tohlcv,S}(;
        fast_period = AO_FAST_PERIOD,
        slow_period = AO_SLOW_PERIOD,
        fast_ma = SMA,
        slow_ma = SMA,
    ) where {Tohlcv,S}
        @assert fast_period < slow_period "slow_period must be greater than fast_period"
        _fast_ma = MAFactory(S)(fast_ma, fast_period)
        _slow_ma = MAFactory(S)(slow_ma, slow_period)
        new{Tohlcv,S}(missing, 0, _fast_ma, _slow_ma)
    end
end

function _calculate_new_value_only_from_incoming_data(ind::AO, candle)
    median = (candle.high + candle.low) / 2.0
    fit!(ind.fast_ma, median)
    fit!(ind.slow_ma, median)
    return value(ind.fast_ma) - value(ind.slow_ma)
end
