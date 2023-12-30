const ChaikinOsc_FAST_PERIOD = 5
const ChaikinOsc_SLOW_PERIOD = 7

"""
    ChaikinOsc{Tohlcv,S}(; fast_period = ChaikinOsc_FAST_PERIOD, slow_period = ChaikinOsc_SLOW_PERIOD, fast_ma = EMA, slow_ma = EMA)

The `ChaikinOsc` type implements a Chaikin Oscillator.
"""
mutable struct ChaikinOsc{Tohlcv,S} <: TechnicalIndicator{Tohlcv}
    value::Union{Missing,S}
    n::Int

    sub_indicators::Series
    accu_dist::AccuDist{Tohlcv}

    fast_ma::MovingAverageIndicator  # EMA by default
    slow_ma::MovingAverageIndicator  # EMA by default

    function ChaikinOsc{Tohlcv,S}(;
        fast_period = ChaikinOsc_FAST_PERIOD,
        slow_period = ChaikinOsc_SLOW_PERIOD,
        fast_ma = EMA,
        slow_ma = EMA,
    ) where {Tohlcv,S}
        accu_dist = AccuDist{Tohlcv,S}()
        sub_indicators = Series(accu_dist)
        _fast_ma = MAFactory(S)(fast_ma, fast_period)
        _slow_ma = MAFactory(S)(slow_ma, slow_period)
        new{Tohlcv,S}(missing, 0, sub_indicators, accu_dist, _fast_ma, _slow_ma)
    end
end

function _calculate_new_value(ind::ChaikinOsc)
    if has_output_value(ind.accu_dist)
        accu_dist_value = value(ind.accu_dist)
        fit!(ind.fast_ma, accu_dist_value)
        fit!(ind.slow_ma, accu_dist_value)
        if has_output_value(ind.fast_ma) && has_output_value(ind.slow_ma)
            return value(ind.fast_ma) - value(ind.slow_ma)
        else
            return missing
        end
    else
        return missing
    end
end
