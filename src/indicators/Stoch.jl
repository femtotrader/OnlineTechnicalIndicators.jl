const STOCH_PERIOD = 14
const STOCH_SMOOTHING_PERIOD = 3

"""
    StochVal{Tprice}

Return value type for Stochastic oscillator indicator.

# Fields
- `k::Tprice`: %K line (fast stochastic)
- `d::Union{Missing,Tprice}`: %D line (slow stochastic, smoothed %K)

See also: [`Stoch`](@ref)
"""
struct StochVal{Tprice}
    k::Tprice
    d::Union{Missing,Tprice}
end

function is_valid(stoch_val::StochVal)
    return !ismissing(stoch_val.k) && !ismissing(stoch_val.d)
end

"""
    Stoch{Tohlcv}(; period = STOCH_PERIOD, smoothing_period = STOCH_SMOOTHING_PERIOD, ma = SMA, input_modifier_return_type = Tohlcv)

The `Stoch` type implements the Stochastic Oscillator indicator.

The Stochastic Oscillator compares a security's closing price to its price range over
a given period. It generates values between 0 and 100, where readings above 80 indicate
overbought conditions and below 20 indicate oversold conditions.

# Parameters
- `period::Integer = $STOCH_PERIOD`: The lookback period for high/low range
- `smoothing_period::Integer = $STOCH_SMOOTHING_PERIOD`: Period for %D line smoothing
- `ma::Type = SMA`: Moving average type for %D smoothing
- `input_modifier_return_type::Type = Tohlcv`: Input OHLCV type

# Formula
```
%K = 100 × (close - lowest_low) / (highest_high - lowest_low)
%D = SMA(%K, smoothing_period)
```

# Input
Requires OHLCV data with `high`, `low`, and `close` fields.

# Output
- [`StochVal`](@ref): Contains `k` (%K fast line) and `d` (%D slow line) values

# Returns
`Union{Missing,StochVal}` - The stochastic values, available from the first observation
(%D becomes available after `smoothing_period` observations).

See also: [`StochRSI`](@ref), [`RSI`](@ref), [`UO`](@ref)
"""
mutable struct Stoch{Tohlcv,IN,S} <: TechnicalIndicatorMultiOutput{Tohlcv}
    value::Union{Missing,StochVal}
    n::Int

    period::Integer
    smoothing_period::Integer

    values_d::SMA
    input_values::CircBuff

    function Stoch{Tohlcv}(;
        period = STOCH_PERIOD,
        smoothing_period = STOCH_SMOOTHING_PERIOD,
        ma = SMA,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        S = fieldtype(T2, :close)
        values_d = MovingAverage(S)(ma, period = smoothing_period)
        input_values = CircBuff(T2, period, rev = false)
        new{Tohlcv,true,S}(missing, 0, period, smoothing_period, values_d, input_values)
    end
end

function Stoch(;
    period = STOCH_PERIOD,
    smoothing_period = STOCH_SMOOTHING_PERIOD,
    ma = SMA,
    input_modifier_return_type = OHLCV{Missing,Float64,Float64},
)
    Stoch{input_modifier_return_type}(;
        period = period,
        smoothing_period = smoothing_period,
        ma = ma,
        input_modifier_return_type = input_modifier_return_type,
    )
end

function _calculate_new_value(ind::Stoch{T,IN,S}) where {T,IN,S}
    # get latest received candle
    candle = ind.input_values[end]
    # get max high and min low
    max_high = max((cdl.high for cdl in value(ind.input_values))...)
    min_low = min((cdl.low for cdl in value(ind.input_values))...)
    # calculate k
    if max_high == min_low
        k = 100 * one(S)
    else
        k = 100 * one(S) * (candle.close - min_low) / (max_high - min_low)
    end
    # calculate d
    fit!(ind.values_d, k)
    d = value(ind.values_d)
    return StochVal(k, d)
end
