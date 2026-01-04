const ChaikinOsc_FAST_PERIOD = 5
const ChaikinOsc_SLOW_PERIOD = 7

"""
    ChaikinOsc{Tohlcv}(; fast_period = ChaikinOsc_FAST_PERIOD, slow_period = ChaikinOsc_SLOW_PERIOD, fast_ma = EMA, slow_ma = EMA, input_modifier_return_type = Tohlcv)

The `ChaikinOsc` type implements a Chaikin Oscillator.

The Chaikin Oscillator measures the momentum of the Accumulation/Distribution Line (ADL)
by calculating the difference between fast and slow moving averages of the ADL. It helps
identify buying or selling pressure in the market. Positive values suggest accumulation,
negative values suggest distribution.

# Parameters
- `fast_period::Integer = $ChaikinOsc_FAST_PERIOD`: Period for the fast moving average
- `slow_period::Integer = $ChaikinOsc_SLOW_PERIOD`: Period for the slow moving average
- `fast_ma::Type = EMA`: Moving average type for the fast period
- `slow_ma::Type = EMA`: Moving average type for the slow period
- `input_modifier_return_type::Type = Tohlcv`: Input OHLCV type

# Formula
```
ChaikinOsc = EMA(AccuDist, fast_period) - EMA(AccuDist, slow_period)
```

# Input
Requires OHLCV data with `high`, `low`, `close`, and `volume` fields.

# Returns
`Union{Missing,T}` - The Chaikin Oscillator value, or `missing` during warm-up.

See also: [`AccuDist`](@ref), [`OBV`](@ref), [`KVO`](@ref), [`MFI`](@ref)
"""
mutable struct ChaikinOsc{Tohlcv,IN,S} <: TechnicalIndicatorSingleOutput{Tohlcv}
    value::Union{Missing,S}
    n::Int

    sub_indicators::Series
    accu_dist::AccuDist

    fast_ma::MovingAverageIndicator  # EMA by default
    slow_ma::MovingAverageIndicator  # EMA by default

    function ChaikinOsc{Tohlcv}(;
        fast_period = ChaikinOsc_FAST_PERIOD,
        slow_period = ChaikinOsc_SLOW_PERIOD,
        fast_ma = EMA,
        slow_ma = EMA,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        S = fieldtype(T2, :close)
        accu_dist = AccuDist{T2}()
        sub_indicators = Series(accu_dist)
        _fast_ma = MovingAverage(S)(fast_ma, period = fast_period)
        _slow_ma = MovingAverage(S)(slow_ma, period = slow_period)
        new{Tohlcv,true,S}(missing, 0, sub_indicators, accu_dist, _fast_ma, _slow_ma)
    end
end

function ChaikinOsc(;
    fast_period = ChaikinOsc_FAST_PERIOD,
    slow_period = ChaikinOsc_SLOW_PERIOD,
    fast_ma = EMA,
    slow_ma = EMA,
    input_modifier_return_type = OHLCV{Missing,Float64,Float64},
)
    ChaikinOsc{input_modifier_return_type}(;
        fast_period = fast_period,
        slow_period = slow_period,
        fast_ma = fast_ma,
        slow_ma = slow_ma,
        input_modifier_return_type = input_modifier_return_type,
    )
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
