const AO_FAST_PERIOD = 3
const AO_SLOW_PERIOD = 21

"""
    AO{Tohlcv}(; fast_period = AO_FAST_PERIOD, slow_period = AO_SLOW_PERIOD, fast_ma = SMA, slow_ma = SMA, input_modifier_return_type = Tohlcv)

The `AO` type implements an Awesome Oscillator indicator.

The Awesome Oscillator measures market momentum by comparing short-term momentum to
long-term momentum. It uses the median price (high + low) / 2 and calculates the
difference between a fast and slow moving average of this median price.

# Parameters
- `fast_period::Integer = $AO_FAST_PERIOD`: The period for the fast moving average
- `slow_period::Integer = $AO_SLOW_PERIOD`: The period for the slow moving average
- `fast_ma::Type = SMA`: The moving average type for the fast period
- `slow_ma::Type = SMA`: The moving average type for the slow period
- `input_modifier_return_type::Type = Tohlcv`: Input OHLCV type

# Formula
```
Median Price = (high + low) / 2
AO = SMA(Median Price, fast_period) - SMA(Median Price, slow_period)
```

# Input
Requires OHLCV data with `high` and `low` fields.

# Returns
`Union{Missing,T}` - The awesome oscillator value. Positive values indicate bullish momentum,
negative values indicate bearish momentum. Returns `missing` during warm-up.

See also: [`MACD`](@ref), [`RSI`](@ref)
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
        _fast_ma = MovingAverage(S)(fast_ma, period = fast_period)
        _slow_ma = MovingAverage(S)(slow_ma, period = slow_period)
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
