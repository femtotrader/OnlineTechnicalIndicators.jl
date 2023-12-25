"""
    AccuDist{Tohlcv}()

The AccuDist type implements an Accumulation and Distribution indicator.
"""
mutable struct AccuDist{Tohlcv} <: OnlineStat{Tohlcv}
    value::Union{Missing,Float64}
    n::Int

    function AccuDist{Tohlcv}() where {Tohlcv}
        new{Tohlcv}(missing, 0)
    end
end

#= 
# I'd like value type be defined more generally (ie not Float64) 
mutable struct AccuDist{T, S} <: OnlineStat{T, S}
    value::Union{Missing, S}
    n::Int

    function AccuDist{T, S}() where {T, S}
        new{T, S}(missing, 0)
    end
end
=#

function OnlineStatsBase._fit!(ind::AccuDist, candle::OHLCV)
    ind.n += 1
    if candle.high != candle.low
        # Calculate MFI and MFV
        mfi =
            ((candle.close - candle.low) - (candle.high - candle.close)) /
            (candle.high - candle.low)
        mfv = mfi * candle.volume
    else
        # In case high and low are equal (division by zero), return previous value if exists, otherwise return missing
        ind.value = value(ind)
        return
    end
    if !has_output_value(ind)
        ind.value = mfv
    else
        ind.value = value(ind) + mfv
    end
end
