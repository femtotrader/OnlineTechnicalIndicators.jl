"""
    BOP{Tohlcv,S}()

The BOP type implements a Balance Of Power indicator.
"""
mutable struct BOP{Tohlcv,S} <: TechnicalIndicator{Tohlcv}
    value::Union{Missing,S}
    n::Int

    function BOP{Tohlcv,S}() where {Tohlcv,S}
        new{Tohlcv,S}(missing, 0)
    end
end

function OnlineStatsBase._fit!(ind::BOP, candle)
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
