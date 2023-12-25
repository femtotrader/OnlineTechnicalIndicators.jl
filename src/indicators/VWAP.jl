const VWAP_MEMORY = 3

"""
    VWAP{Tohlcv}()

The VWAP type implements a Volume Weighted Moving Average indicator.
"""
mutable struct VWAP{Tohlcv} <: OnlineStat{Tohlcv}
    value::Union{Missing,Float64}
    n::Int

    sum_price_vol::Float64
    sum_vol::Float64

    function VWAP{Tohlcv}() where {Tohlcv}
        Tprice, Tvol = Float64, Float64
        sum_price_vol = zero(Tprice)
        sum_vol = zero(Tvol)
        new{Tohlcv}(missing, 0, sum_price_vol, sum_vol)
    end
end

function OnlineStatsBase._fit!(ind::VWAP, candle::OHLCV)
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
