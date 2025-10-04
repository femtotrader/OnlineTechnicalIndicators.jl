using OnlineStatsChains

const StochRSI_RSI_PERIOD = 14
const StochRSI_STOCH_PERIOD = 14
const StochRSI_K_SMOOTHING_PERIOD = 3
const StochRSI_D_SMOOTHING_PERIOD = 3

"""
    StochRSIVal{Tval}

Return value type for Stochastic RSI indicator.

# Fields
- `k::Tval`: %K line (stochastic of RSI)
- `d::Union{Missing,Tval}`: %D line (smoothed %K)

See also: [`StochRSI`](@ref)
"""
struct StochRSIVal{Tval}
    k::Tval
    d::Union{Missing,Tval}
end

"""
    StochRSI{T}(; rsi_period = StochRSI_RSI_PERIOD, stoch_period = StochRSI_STOCH_PERIOD, k_smoothing_period = StochRSI_K_SMOOTHING_PERIOD, d_smoothing_period = StochRSI_D_SMOOTHING_PERIOD, ma = SMA, input_modifier_return_type = Tval)

The `StochRSI` type implements Stochastic RSI indicator using OnlineStatsChains with filtered edges.

# Implementation Details
Uses OnlineStatsChains.StatDAG with filtered edges to organize the smoothing chain:
smoothed_k → values_d

The RSI is computed separately and the stochastic oscillator is applied to it,
then the result goes through a 2-stage smoothing process.

# Formula
RSI = RSI(price, rsi_period)
K = 100 * (RSI - min(RSI, stoch_period)) / (max(RSI, stoch_period) - min(RSI, stoch_period))
smoothed_K = MA(K, k_smoothing_period)
D = MA(smoothed_K, d_smoothing_period)

# Output
- [`StochRSIVal`](@ref): A value containing `k` and `d` values
"""
mutable struct StochRSI{Tval,IN,T2} <: TechnicalIndicatorMultiOutput{Tval}
    value::Union{Missing,StochRSIVal}
    n::Int

    stoch_period::Int

    sub_indicators::Series
    rsi::RSI
    recent_rsi::CircBuff  # historical values of rsi (most recent at end)

    smoothed_k::MovingAverageIndicator
    values_d::MovingAverageIndicator

    function StochRSI{Tval}(;
        rsi_period = StochRSI_RSI_PERIOD,
        stoch_period = StochRSI_STOCH_PERIOD,
        k_smoothing_period = StochRSI_K_SMOOTHING_PERIOD,
        d_smoothing_period = StochRSI_D_SMOOTHING_PERIOD,
        ma = SMA,
        input_modifier_return_type = Tval,
    ) where {Tval}
        T2 = input_modifier_return_type
        rsi = RSI{T2}(period = rsi_period)
        sub_indicators = Series(rsi)
        recent_rsi = CircBuff(Union{Missing,T2}, stoch_period, rev = false)

        # Create smoothing MAs
        smoothed_k = MAFactory(T2)(ma, period = k_smoothing_period)
        values_d = MAFactory(T2)(ma, period = d_smoothing_period)

        new{Tval,false,T2}(
            missing,
            0,
            stoch_period,
            sub_indicators,
            rsi,
            recent_rsi,
            smoothed_k,
            values_d,
        )
    end
end

function StochRSI(;
    rsi_period = StochRSI_RSI_PERIOD,
    stoch_period = StochRSI_STOCH_PERIOD,
    k_smoothing_period = StochRSI_K_SMOOTHING_PERIOD,
    d_smoothing_period = StochRSI_D_SMOOTHING_PERIOD,
    ma = SMA,
    input_modifier_return_type = Float64,
)
    StochRSI{input_modifier_return_type}(;
        rsi_period = rsi_period,
        stoch_period = stoch_period,
        k_smoothing_period = k_smoothing_period,
        d_smoothing_period = d_smoothing_period,
        ma = ma,
        input_modifier_return_type = input_modifier_return_type,
    )
end

expected_return_type(ind::StochRSI) = StochRSIVal{typeof(ind).parameters[end]}

function _calculate_new_value(ind::StochRSI{T,IN,S}) where {T,IN,S}
    fit!(ind.recent_rsi, value(ind.rsi))
    if has_valid_values(ind.recent_rsi, ind.stoch_period)
        max_high = max(ind.recent_rsi.value...)
        min_low = min(ind.recent_rsi.value...)

        if max_high == min_low
            k = 100 * one(S)
        else
            k = 100 * (value(ind.rsi) - min_low) / (max_high - min_low)
        end

        # Feed k into smoothing chain
        fit!(ind.smoothed_k, k)
        _smoothed_k = value(ind.smoothed_k)

        if !ismissing(_smoothed_k)
            fit!(ind.values_d, _smoothed_k)
        end

        return StochRSIVal(_smoothed_k, value(ind.values_d))
    else
        return missing
    end
end
