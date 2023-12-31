const STC_FAST_MACD_PERIOD = 5
const STC_SLOW_MACD_PERIOD = 10
const STC_STOCH_PERIOD = 10
const STC_STOCH_SMOOTHING_PERIOD = 3


"""
    STC{T}(; fast_macd_period = STC_FAST_MACD_PERIOD, slow_macd_period = STC_SLOW_MACD_PERIOD, stoch_period = STC_STOCH_PERIOD, stoch_smoothing_period = STC_STOCH_SMOOTHING_PERIOD, ma = SMA)

The `STC` type implements a chaff Trend Cycle indicator.
"""
mutable struct STC{Tval} <: TechnicalIndicator{Tval}
    value::Union{Missing,Tval}
    n::Int

    sub_indicators::Series
    macd::MACD

    stoch_macd::Stoch
    stoch_d::Stoch

    function STC{Tval}(;
        fast_macd_period = STC_FAST_MACD_PERIOD,
        slow_macd_period = STC_SLOW_MACD_PERIOD,
        stoch_period = STC_STOCH_PERIOD,
        stoch_smoothing_period = STC_STOCH_SMOOTHING_PERIOD,
        ma = SMA,
    ) where {Tval}
        @assert fast_macd_period < slow_macd_period "fast_macd_period < slow_macd_period is not respected"
        # use slow_macd_period for signal line as signal line is not relevant here
        macd = MACD{Tval}(
            fast_period = fast_macd_period,
            slow_period = slow_macd_period,
            signal_period = slow_macd_period,
        )
        sub_indicators = Series(macd)
        #stoch_macd = Stoch{Union{Missing,MACDVal},Tval}(
        stoch_macd = Stoch{MACDVal,Tval}(
            period = stoch_period,
            smoothing_period = stoch_smoothing_period,
            ma = ma,
            #input_filter = !ismissing,
            input_modifier = macd_val -> OHLCV(macd_val.macd, macd_val.macd, macd_val.macd, macd_val.macd),
            input_modifier_return_type = OHLCV
        )
        # add_input_indicator!(stoch_macd, macd)  # <---
        #stoch_d = Stoch{Union{Missing,StochVal},Tval}(
        stoch_d = Stoch{StochVal,Tval}(
            period = stoch_period,
            smoothing_period = stoch_smoothing_period,
            ma = ma,
            #input_filter = !ismissing,
            input_modifier = stoch_val ->
                OHLCV(stoch_val.d, stoch_val.d, stoch_val.d, stoch_val.d),
            input_modifier_return_type = OHLCV,
        )
        new{Tval}(missing, 0, sub_indicators, macd, stoch_macd, stoch_d)
    end
end

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

#=
function _calculate_new_value(ind::STC)
    macd_val = value(ind.macd)
    fit!(ind.stoch_macd, macd_val)
    fit!(ind.stoch_d, value(ind.stoch_macd))
    stoch_d_val = value(ind.stoch_d)
    if !ismissing(macd_val)
        return max(min(stoch_d_val.d, 100), 0)
    else
        return missing
    end
end
=#
