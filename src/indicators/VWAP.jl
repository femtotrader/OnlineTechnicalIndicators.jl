const VWAP_MEMORY = 3

"""
    VWAP{Tohlcv,S}()

The VWAP type implements a Volume Weighted Moving Average indicator.
"""
mutable struct VWAP{Tohlcv,S} <: OnlineStat{Tohlcv}
    value::Union{Missing,S}
    n::Int

    sum_price_vol::S
    sum_vol::S

    function VWAP{Tohlcv,S}() where {Tohlcv,S}
        sum_price_vol = zero(S)
        sum_vol = zero(S)
        new{Tohlcv,S}(missing, 0, sum_price_vol, sum_vol)
    end
end

function OnlineStatsBase._fit!(ind::VWAP, candle)
    ind.n += 1
    typical_price = (candle.high + candle.low + candle.close) / 3.0

    ind.sum_price_vol = ind.sum_price_vol + candle.volume * typical_price
    ind.sum_vol = ind.sum_vol + candle.volume

    if ind.sum_vol != 0
        ind.value = ind.sum_price_vol / ind.sum_vol
    else
        ind.value = missing
    end
end
