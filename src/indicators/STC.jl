using OnlineStatsChains

const STC_FAST_MACD_PERIOD = 5
const STC_SLOW_MACD_PERIOD = 10
const STC_STOCH_PERIOD = 10
const STC_STOCH_SMOOTHING_PERIOD = 3

"""
    STC{T}(; fast_macd_period = STC_FAST_MACD_PERIOD, slow_macd_period = STC_SLOW_MACD_PERIOD, stoch_period = STC_STOCH_PERIOD, stoch_smoothing_period = STC_STOCH_SMOOTHING_PERIOD, ma = SMA, input_modifier_return_type = T)

The `STC` type implements a Schaff Trend Cycle indicator.

STC combines MACD with double Stochastic smoothing to identify cyclical trends.
It oscillates between 0 and 100, with values above 75 indicating overbought conditions
and below 25 indicating oversold conditions. It often leads price reversals.

# Parameters
- `fast_macd_period::Integer = $STC_FAST_MACD_PERIOD`: Fast EMA period for MACD
- `slow_macd_period::Integer = $STC_SLOW_MACD_PERIOD`: Slow EMA period for MACD
- `stoch_period::Integer = $STC_STOCH_PERIOD`: Lookback period for Stochastic
- `stoch_smoothing_period::Integer = $STC_STOCH_SMOOTHING_PERIOD`: Smoothing for Stochastic %D
- `ma::Type = SMA`: Moving average type for Stochastic smoothing
- `input_modifier_return_type::Type = T`: Output value type

# Formula
```
1. MACD = EMA(fast) - EMA(slow)
2. Stoch1 = Stochastic(MACD)
3. Stoch2 = Stochastic(Stoch1.%D)
4. STC = clamp(Stoch2.%D, 0, 100)
```

# Returns
`Union{Missing,T}` - The STC value (0-100), or `missing` during warm-up.

See also: [`MACD`](@ref), [`Stoch`](@ref), [`RSI`](@ref)
"""
mutable struct STC{Tval,IN,T2} <: TechnicalIndicatorSingleOutput{Tval}
    value::Union{Missing,T2}
    n::Int

    sub_indicators::Series

    stoch_macd::Stoch
    stoch_d::Stoch

    function STC{Tval}(;
        fast_macd_period = STC_FAST_MACD_PERIOD,
        slow_macd_period = STC_SLOW_MACD_PERIOD,
        stoch_period = STC_STOCH_PERIOD,
        stoch_smoothing_period = STC_STOCH_SMOOTHING_PERIOD,
        ma = SMA,
        input_modifier_return_type = Tval,
    ) where {Tval}
        @assert fast_macd_period < slow_macd_period "fast_macd_period < slow_macd_period is not respected"
        T2 = input_modifier_return_type

        # Create MACD (signal line period not relevant here, use slow_macd_period)
        macd = MACD{T2}(
            fast_period = fast_macd_period,
            slow_period = slow_macd_period,
            signal_period = slow_macd_period,
        )
        sub_indicators = Series(macd)

        # Create two Stochastics (manually chained)
        # Both receive OHLCV data (converted from MACD and Stoch values)
        stoch_macd = Stoch{OHLCV{Missing,Tval,Tval}}(
            period = stoch_period,
            smoothing_period = stoch_smoothing_period,
            ma = ma,
            input_modifier_return_type = OHLCV{Missing,Tval,Tval},
        )

        stoch_d = Stoch{OHLCV{Missing,Tval,Tval}}(
            period = stoch_period,
            smoothing_period = stoch_smoothing_period,
            ma = ma,
            input_modifier_return_type = OHLCV{Missing,Tval,Tval},
        )

        new{Tval,false,T2}(missing, 0, sub_indicators, stoch_macd, stoch_d)
    end
end

function STC(;
    fast_macd_period = STC_FAST_MACD_PERIOD,
    slow_macd_period = STC_SLOW_MACD_PERIOD,
    stoch_period = STC_STOCH_PERIOD,
    stoch_smoothing_period = STC_STOCH_SMOOTHING_PERIOD,
    ma = SMA,
    input_modifier_return_type = Float64,
)
    STC{input_modifier_return_type}(;
        fast_macd_period = fast_macd_period,
        slow_macd_period = slow_macd_period,
        stoch_period = stoch_period,
        stoch_smoothing_period = stoch_smoothing_period,
        ma = ma,
        input_modifier_return_type = input_modifier_return_type,
    )
end

function _calculate_new_value(ind::STC)
    # Get MACD value and feed to first Stochastic
    macd_val = value(ind.sub_indicators.stats[1])
    if !ismissing(macd_val)
        # Convert MACD to OHLCV and feed to stoch_macd
        ohlcv_macd = OHLCV(
            macd_val.macd,
            macd_val.macd,
            macd_val.macd,
            macd_val.macd,
            volume = zero(typeof(macd_val.macd)),
        )
        fit!(ind.stoch_macd, ohlcv_macd)

        # Get stoch_macd result and feed to second Stochastic
        stoch_macd_val = value(ind.stoch_macd)
        if !ismissing(stoch_macd_val) && !ismissing(stoch_macd_val.d)
            # Convert Stoch.d to OHLCV and feed to stoch_d
            ohlcv_d = OHLCV(
                stoch_macd_val.d,
                stoch_macd_val.d,
                stoch_macd_val.d,
                stoch_macd_val.d,
                volume = zero(typeof(stoch_macd_val.d)),
            )
            fit!(ind.stoch_d, ohlcv_d)

            # Get final result
            stoch_d_val = value(ind.stoch_d)
            if !ismissing(stoch_d_val) && !ismissing(stoch_d_val.d)
                return max(min(stoch_d_val.d, 100), 0)
            end
        end
    end
    return missing
end
