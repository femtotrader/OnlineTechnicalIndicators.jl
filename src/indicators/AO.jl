const AO_FAST_PERIOD = 3
const AO_SLOW_PERIOD = 21

"""
    AO{Tohlcv}(; fast_period = AO_FAST_PERIOD, slow_period = AO_SLOW_PERIOD, fast_ma = SMA, slow_ma = SMA, input_modifier_return_type = Tohlcv)

The `AO` type implements an Awesome Oscillator indicator.
"""
mutable struct AO{Tohlcv,IN,S} <: TechnicalIndicatorSingleOutput{Tohlcv}
    value::Union{Missing,S}
    n::Int

    fast_ma::MovingAverageIndicator  # default SMA
    slow_ma::MovingAverageIndicator  # default SMA

    function AO{Tohlcv}(;
        fast_period = AO_FAST_PERIOD,
        slow_period = AO_SLOW_PERIOD,
        fast_ma = SMA,
        slow_ma = SMA,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        @assert fast_period < slow_period "slow_period must be greater than fast_period"
        S = fieldtype(input_modifier_return_type, :close)
        _fast_ma = MAFactory(S)(fast_ma, period = fast_period)
        _slow_ma = MAFactory(S)(slow_ma, period = slow_period)
        new{Tohlcv,true,S}(missing, 0, _fast_ma, _slow_ma)
    end
end

function AO(;
    fast_period = AO_FAST_PERIOD,
    slow_period = AO_SLOW_PERIOD,
    fast_ma = SMA,
    slow_ma = SMA,
    input_modifier_return_type = OHLCV{Missing,Float64,Float64},
)
    AO{input_modifier_return_type}(;
        fast_period = fast_period,
        slow_period = slow_period,
        fast_ma = fast_ma,
        slow_ma = slow_ma,
        input_modifier_return_type = input_modifier_return_type,
    )
end

function _calculate_new_value_only_from_incoming_data(ind::AO, candle)
    median = (candle.high + candle.low) / 2
    fit!(ind.fast_ma, median)
    fit!(ind.slow_ma, median)
    return value(ind.fast_ma) - value(ind.slow_ma)
end
