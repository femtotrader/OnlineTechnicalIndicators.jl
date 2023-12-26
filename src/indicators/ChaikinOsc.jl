const ChaikinOsc_FAST_PERIOD = 5
const ChaikinOsc_SLOW_PERIOD = 7

"""
    ChaikinOsc{Tohlcv,S}(; fast_period = ChaikinOsc_FAST_PERIOD, slow_period = ChaikinOsc_SLOW_PERIOD)

The ChaikinOsc type implements a Chaikin Oscillator.
"""
mutable struct ChaikinOsc{Tohlcv,S} <: OnlineStat{Tohlcv}
    value::Union{Missing,S}
    n::Int

    accu_dist::AccuDist{Tohlcv}
    fast_ema::EMA{S}
    slow_ema::EMA{S}

    function ChaikinOsc{Tohlcv,S}(;
        fast_period = ChaikinOsc_FAST_PERIOD,
        slow_period = ChaikinOsc_SLOW_PERIOD,
    ) where {Tohlcv,S}
        accu_dist = AccuDist{Tohlcv,S}()
        fast_ema = EMA{S}(period = fast_period)
        slow_ema = EMA{S}(period = slow_period)
        new{Tohlcv,S}(missing, 0, accu_dist, fast_ema, slow_ema)
    end
end

function OnlineStatsBase._fit!(ind::ChaikinOsc, candle::OHLCV)
    fit!(ind.accu_dist, candle)
    ind.n += 1
    if has_output_value(ind.accu_dist)
        accu_dist_value = value(ind.accu_dist)
        fit!(ind.fast_ema, accu_dist_value)
        fit!(ind.slow_ema, accu_dist_value)
        if has_output_value(ind.fast_ema) && has_output_value(ind.slow_ema)
            ind.value = value(ind.fast_ema) - value(ind.slow_ema)
        else
            ind.value = missing
        end
    else
        ind.value = missing
    end
end
