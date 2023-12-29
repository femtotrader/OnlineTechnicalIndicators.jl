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
        stoch_macd = Stoch{OHLCV{Missing,Float64,Missing},Tval}(
            period = stoch_period,
            smoothing_period = stoch_smoothing_period,
            ma = ma,
        )
        stoch_d = Stoch{OHLCV{Missing,Float64,Missing},Tval}(
            period = stoch_period,
            smoothing_period = stoch_smoothing_period,
            ma = ma,
        )
        # Float64 ->(macd)-> MACDVal -> (macd_to_ohlcv) -> OHLCV -> (stoch_macd) -> stoch_val -> (stoch_d_to_ohlcv) -> OHLCV -> Stoch
        new{Tval}(missing, 0, macd, stoch_macd, stoch_d)
    end
end


function OnlineStatsBase._fit!(ind::STC, val)
    ind.n += 1

    fit!(ind.macd, val)
    macd_val = value(ind.macd)
    if !ismissing(macd_val)
        candle = OHLCV(macd_val.macd, macd_val.macd, macd_val.macd, macd_val.macd)
        fit!(ind.stoch_macd, candle)
        stoch_macd_val = value(ind.stoch_macd)
        candle =
            OHLCV(stoch_macd_val.d, stoch_macd_val.d, stoch_macd_val.d, stoch_macd_val.d)
        fit!(ind.stoch_d, candle)
        stoch_d_val = value(ind.stoch_d)
        ind.value = max(min(stoch_d_val.d, 100), 0)
    end

end
