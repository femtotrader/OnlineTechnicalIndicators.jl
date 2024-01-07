const STC_FAST_MACD_PERIOD = 5
const STC_SLOW_MACD_PERIOD = 10
const STC_STOCH_PERIOD = 10
const STC_STOCH_SMOOTHING_PERIOD = 3

function macd_to_ohlcv(macd_val::MACDVal{S}) where {S}
    return OHLCV(
        macd_val.macd,
        macd_val.macd,
        macd_val.macd,
        macd_val.macd,
        volume = zero(S),
    )
end

function stoch_d_to_ohlcv(stoch_val::StochVal{S}) where {S}
    return OHLCV(stoch_val.d, stoch_val.d, stoch_val.d, stoch_val.d, volume = zero(S))
end

"""
    STC{T}(; fast_macd_period = STC_FAST_MACD_PERIOD, slow_macd_period = STC_SLOW_MACD_PERIOD, stoch_period = STC_STOCH_PERIOD, stoch_smoothing_period = STC_STOCH_SMOOTHING_PERIOD, ma = SMA, , input_filter = always_true, input_modifier = identity, input_modifier_return_type = T)

The `STC` type implements a Schaff Trend Cycle indicator.
"""
mutable struct STC{Tval,IN,T2} <: TechnicalIndicatorSingleOutput{Tval}
    value::Union{Missing,T2}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    sub_indicators::Series
    macd::MACD

    stoch_macd::Stoch
    stoch_d::Stoch

    input_modifier::Function
    input_filter::Function

    function STC{Tval}(;
        fast_macd_period = STC_FAST_MACD_PERIOD,
        slow_macd_period = STC_SLOW_MACD_PERIOD,
        stoch_period = STC_STOCH_PERIOD,
        stoch_smoothing_period = STC_STOCH_SMOOTHING_PERIOD,
        ma = SMA,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tval,
    ) where {Tval}
        @assert fast_macd_period < slow_macd_period "fast_macd_period < slow_macd_period is not respected"
        T2 = input_modifier_return_type
        #S = fieldtype(T2, :close)
        # use slow_macd_period for signal line as signal line is not relevant here
        macd = MACD{T2}(
            fast_period = fast_macd_period,
            slow_period = slow_macd_period,
            signal_period = slow_macd_period,
        )
        sub_indicators = Series(macd)
        #stoch_macd = Stoch{MACDVal,T2}(
        stoch_macd = Stoch{MACDVal}(
            period = stoch_period,
            smoothing_period = stoch_smoothing_period,
            ma = ma,
            input_filter = is_valid,
            input_modifier = macd_to_ohlcv,
            input_modifier_return_type = OHLCV{Missing,Tval,Tval},
        )
        add_input_indicator!(stoch_macd, macd)  # <---
        #stoch_d = Stoch{StochVal,T2}(
        stoch_d = Stoch{StochVal}(
            period = stoch_period,
            smoothing_period = stoch_smoothing_period,
            ma = ma,
            input_filter = is_valid,
            input_modifier = stoch_d_to_ohlcv,
            input_modifier_return_type = OHLCV{Missing,Tval,Tval},
        )
        add_input_indicator!(stoch_d, stoch_macd)  # <---
        new{Tval,false,T2}(
            initialize_indicator_common_fields()...,
            sub_indicators,
            macd,
            stoch_macd,
            stoch_d,
            input_modifier,
            input_filter,
        )
    end
end

function _calculate_new_value(ind::STC)
    stoch_d_val = value(ind.stoch_d)
    if !ismissing(stoch_d_val)
        if !ismissing(stoch_d_val.d)
            return max(min(stoch_d_val.d, 100), 0)
        else
            return missing
        end
    else
        return missing
    end
end

#=
function _calculate_new_value(ind::STC)
    macd_val = value(ind.macd)
    if !ismissing(macd_val)
        fit!(ind.stoch_macd, macd_val)
        fit!(ind.stoch_d, value(ind.stoch_macd))
        stoch_d_val = value(ind.stoch_d)
        return max(min(stoch_d_val.d, 100), 0)
    else
        return missing
    end
end
=#

#=
function _calculate_new_value(ind::STC)
    macd_val = value(ind.macd)
    fit!(ind.stoch_macd, macd_val)
    fit!(ind.stoch_d, value(ind.stoch_macd))
    stoch_d_val = value(ind.stoch_d)
    if !ismissing(stoch_d_val)
        return max(min(stoch_d_val.d, 100), 0)
    else
        return missing
    end
end
=#
