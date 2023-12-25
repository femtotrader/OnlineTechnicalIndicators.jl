"""
    BOP{Tohlcv}()

The BOP type implements a Balance Of Power indicator.
"""
mutable struct BOP{Tohlcv} <: OnlineStat{Tohlcv}
    value::Union{Missing,Float64}
    n::Int

    function BOP{Tohlcv}() where {Tohlcv}
        new{Tohlcv}(missing, 0)
    end
end

function OnlineStatsBase._fit!(ind::BOP, candle::OHLCV)
    ind.n += 1
    if candle.high != candle.low
        ind.value = (candle.close - candle.open) / (candle.high - candle.low)
    else
        if ind.n > 0
            ind.value = value(ind)
        else
            ind.value = missing
        end
    end
end
