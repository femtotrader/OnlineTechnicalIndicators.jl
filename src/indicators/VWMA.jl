const VWMA_PERIOD = 3

"""
    VWMA{Tohlcv,S}(; period = VWMA_PERIOD)

The `VWMA` type implements a Volume Weighted Moving Average indicator.
"""
mutable struct VWMA{Tohlcv,S} <: MovingAverageIndicator{Tohlcv}
    value::Union{Missing,S}
    n::Int

    period::Integer

    input::CircBuff

    function VWMA{Tohlcv,S}(; period = VWMA_PERIOD) where {Tohlcv,S}
        input = CircBuff(Tohlcv, period, rev = false)
        new{Tohlcv,S}(missing, 0, period, input)
    end
end

function OnlineStatsBase._fit!(ind::VWMA, candle)
    fit!(ind.input, candle)
    ind.n += 1
    if ind.n >= ind.period
        s = 0
        v = 0
        for candle_prev in value(ind.input)
            s += candle_prev.close * candle_prev.volume
            v += candle_prev.volume
        end
        ind.value = s / v
    else
        ind.value = missing
    end
end
#=

function Base.push!(
    ind::VWMA{Ttime,Tprice,Tvol},
    ohlcv::OHLCV{Ttime,Tprice,Tvol},
) where {Ttime,Tprice,Tvol}
    push!(ind.input, ohlcv)
    if length(ind.input) < ind.period
        out_val = missing
    else
        s = zero(Tprice)
        v = zero(Tvol)
        for candle in ind.input
            s += candle.close * candle.volume
            v += candle.volume
        end
        out_val = s / v
    end
    push!(ind.value, out_val)
    return out_val
end
=#
