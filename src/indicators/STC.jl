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

    stoch_macd::FilterTransform  # Stoch
    stoch_d::FilterTransform  # Stoch

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
        stoch_macd = Stoch{OHLCV{Missing,Float64,Missing},Tval}(
            period = stoch_period,
            smoothing_period = stoch_smoothing_period,
            ma = ma,
        )
        stoch_macd = FilterTransform(
            stoch_macd,
            MACDVal,  # type of input
            transform = macd_val ->
                OHLCV(macd_val.macd, macd_val.macd, macd_val.macd, macd_val.macd),
        )
        # add_input_indicator!(stoch_macd, macd)  # <---
        stoch_d = Stoch{OHLCV{Missing,Float64,Missing},Tval}(
            period = stoch_period,
            smoothing_period = stoch_smoothing_period,
            ma = ma,
        )
        stoch_d = FilterTransform(
            stoch_d,
            StochVal,  # type of input
            transform = stoch_val ->
                OHLCV(stoch_val.d, stoch_val.d, stoch_val.d, stoch_val.d),
        )
        new{Tval}(missing, 0, sub_indicators, macd, stoch_macd, stoch_d)
    end
end


function OnlineStatsBase._fit!(ind::STC, val)
    fit!(ind.sub_indicators, val)
    ind.n += 1
    macd_val = value(ind.macd)
    if !ismissing(macd_val)
        fit!(ind.stoch_macd, macd_val)
        fit!(ind.stoch_d, value(ind.stoch_macd))
        ind.value = max(min(value(ind.stoch_d).d, 100), 0)
    end

end
