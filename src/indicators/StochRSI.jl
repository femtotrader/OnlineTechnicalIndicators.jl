const StochRSI_RSI_PERIOD = 14
const StochRSI_STOCH_PERIOD = 14
const StochRSI_K_SMOOTHING_PERIOD = 3
const StochRSI_D_SMOOTHING_PERIOD = 3

struct StochRSIVal{Tval}
    k::Tval
    d::Union{Missing,Tval}
end

"""
    StochRSI{T}(; fast_period = StochRSI_FAST_PERIOD, slow_period = StochRSI_SLOW_PERIOD, signal_period = StochRSI_SIGNAL_PERIOD, ma = EMA, input_filter = always_true, input_modifier = identity, input_modifier_return_type = T)

The `StochRSI` type implements Moving Average Convergence Divergence indicator.
"""
mutable struct StochRSI{Tval,IN,T2} <: TechnicalIndicatorMultiOutput{Tval}
    value::Union{Missing,StochRSIVal}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    stoch_period::Int

    sub_indicators::Series
    rsi::RSI
    recent_rsi::CircBuff  # historical values of rsi (most recent at end)

    smoothed_k::MovingAverageIndicator
    values_d::MovingAverageIndicator

    input_modifier::Function
    input_filter::Function

    function StochRSI{Tval}(;
        rsi_period = StochRSI_RSI_PERIOD,
        stoch_period = StochRSI_STOCH_PERIOD,
        k_smoothing_period = StochRSI_K_SMOOTHING_PERIOD,
        d_smoothing_period = StochRSI_D_SMOOTHING_PERIOD,
        ma = SMA,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tval,
    ) where {Tval}
        T2 = input_modifier_return_type
        rsi = RSI{T2}(period = rsi_period)
        smoothed_k =
            MAFactory(T2)(ma, period = k_smoothing_period, input_filter = !ismissing)
        values_d = MAFactory(Union{Missing,T2})(
            ma,
            period = d_smoothing_period,
            input_filter = !ismissing,
        )
        sub_indicators = Series(rsi)
        recent_rsi = CircBuff(Union{Missing,T2}, stoch_period, rev = false)
        new{Tval,false,T2}(
            initialize_indicator_common_fields()...,
            stoch_period,
            sub_indicators,
            rsi,
            recent_rsi,
            smoothed_k,
            values_d,
            input_modifier,
            input_filter,
        )
    end
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

        fit!(ind.smoothed_k, k)
        _smoothed_k = value(ind.smoothed_k)
        fit!(ind.values_d, _smoothed_k)

        return StochRSIVal(_smoothed_k, value(ind.values_d))
    else
        return missing
    end
end
