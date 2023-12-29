"""
    AccuDist{Tohlcv,S}()

The `AccuDist` type implements an Accumulation and Distribution indicator.
"""
mutable struct AccuDist{Tohlcv,S} <: TechnicalIndicator{Tohlcv}
    value::Union{Missing,S}
    n::Int

    function AccuDist{Tohlcv,S}() where {Tohlcv,S}
        new{Tohlcv,S}(missing, 0)
    end
end

function OnlineStatsBase._fit!(ind::AccuDist, candle)
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
    if has_output_value(ind)
        ind.value = value(ind) + mfv
    else
        ind.value = mfv
    end
end
