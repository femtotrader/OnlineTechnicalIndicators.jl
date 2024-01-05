const ChaikinOsc_FAST_PERIOD = 5
const ChaikinOsc_SLOW_PERIOD = 7

"""
    ChaikinOsc{Tohlcv,S}(; fast_period = ChaikinOsc_FAST_PERIOD, slow_period = ChaikinOsc_SLOW_PERIOD, fast_ma = EMA, slow_ma = EMA, input_filter = always_true, input_modifier = identity, input_modifier_return_type = Tohlcv)

The `ChaikinOsc` type implements a Chaikin Oscillator.
"""
mutable struct ChaikinOsc{Tohlcv,IN,S} <: TechnicalIndicatorSingleOutput{Tohlcv}
    value::Union{Missing,S}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    sub_indicators::Series
    accu_dist::AccuDist

    fast_ma::MovingAverageIndicator  # EMA by default
    slow_ma::MovingAverageIndicator  # EMA by default

    input_modifier::Function
    input_filter::Function

    function ChaikinOsc{Tohlcv}(;
        fast_period = ChaikinOsc_FAST_PERIOD,
        slow_period = ChaikinOsc_SLOW_PERIOD,
        fast_ma = EMA,
        slow_ma = EMA,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        S = fieldtype(T2, :close)
        accu_dist = AccuDist{T2}()
        sub_indicators = Series(accu_dist)
        _fast_ma = MAFactory(S)(fast_ma, period = fast_period)
        _slow_ma = MAFactory(S)(slow_ma, period = slow_period)
        new{Tohlcv,true,S}(
            initialize_indicator_common_fields()...,
            sub_indicators,
            accu_dist,
            _fast_ma,
            _slow_ma,
            input_modifier,
            input_filter,
        )
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
