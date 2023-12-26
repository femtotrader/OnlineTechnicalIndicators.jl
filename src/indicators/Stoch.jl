const STOCH_PERIOD = 14
const STOCH_SMOOTHING_PERIOD = 3

struct StochVal{Tprice}
    k::Tprice
    d::Tprice
end

"""
    Stoch{Tohlcv,S}(; period = STOCH_PERIOD, smoothing_period = STOCH_SMOOTHING_PERIOD)

The Stoch type implements the Stochastic indicator.
"""
mutable struct Stoch{Tohlcv,S} <: OnlineStat{Tohlcv}
    value::Union{Missing,StochVal{S}}  # Tprice
    n::Int

    period::Integer
    smoothing_period::Integer

    values_d::SMA{S}
    input::CircBuff{Tohlcv}

    function Stoch{Tohlcv,S}(;
        period = STOCH_PERIOD,
        smoothing_period = STOCH_SMOOTHING_PERIOD,
    ) where {Tohlcv,S}
        values_d = SMA{S}(; period = smoothing_period)
        input = CircBuff(Tohlcv, period, rev = false)
        new{Tohlcv,S}(missing, 0, period, smoothing_period, values_d, input)
    end
end

function OnlineStatsBase._fit!(ind::Stoch, candle::OHLCV)
    # load candles until i have enough data
    fit!(ind.input, candle)
    # increment ind.n
    ind.n += 1
    # get max high and min low
    max_high = max([cdl.high for cdl in value(ind.input)]...)
    min_low = min([cdl.low for cdl in value(ind.input)]...)
    # calculate k
    if max_high == min_low
        k = 100.0
    else
        k = 100.0 * (ind.input[end].close - min_low) / (max_high - min_low)
    end
    # calculate d
    fit!(ind.values_d, k)
    if length(ind.values_d.value) > 0
        d = value(ind.values_d)
    else
        d = missing
    end
    ind.value = StochVal(k, d)
end
