const AO_FAST_PERIOD = 3
const AO_SLOW_PERIOD = 21

"""
    AO{Tohlcv,S}(; fast_period = AO_FAST_PERIOD, slow_period = AO_SLOW_PERIOD, fast_ma = SMA, slow_ma = SMA, input_filter = always_true, input_modifier = identity, input_modifier_return_type = Tohlcv)

The `AO` type implements an Awesome Oscillator indicator.
"""
mutable struct AO{Tohlcv,S} <: TechnicalIndicatorSingleOutput{Tohlcv}
    value::Union{Missing,S}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    fast_ma::MovingAverageIndicator  # default SMA
    slow_ma::MovingAverageIndicator  # default SMA

    input_modifier::Function
    input_filter::Function

    function AO{Tohlcv}(;
        fast_period = AO_FAST_PERIOD,
        slow_period = AO_SLOW_PERIOD,
        fast_ma = SMA,
        slow_ma = SMA,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        @assert fast_period < slow_period "slow_period must be greater than fast_period"
        S = fieldtype(input_modifier_return_type, :close)
        _fast_ma = MAFactory(S)(fast_ma, period = fast_period)
        _slow_ma = MAFactory(S)(slow_ma, period = slow_period)
        new{Tohlcv,S}(
            initialize_indicator_common_fields()...,
            _fast_ma,
            _slow_ma,
            input_modifier,
            input_filter,
        )
    end
end

function _calculate_new_value_only_from_incoming_data(ind::AO, candle)
    median = (candle.high + candle.low) / 2.0
    fit!(ind.fast_ma, median)
    fit!(ind.slow_ma, median)
    return value(ind.fast_ma) - value(ind.slow_ma)
end
