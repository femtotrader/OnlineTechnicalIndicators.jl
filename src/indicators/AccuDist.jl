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

function _calculate_new_value_only_from_incoming_data(ind::AccuDist, candle)
    if candle.high != candle.low
        # Calculate MFI and MFV
        mfi =
            ((candle.close - candle.low) - (candle.high - candle.close)) /
            (candle.high - candle.low)
        mfv = mfi * candle.volume
    else
        # In case high and low are equal (division by zero), return previous value if exists, otherwise return missing
        return value(ind)
    end
        return has_output_value(ind) ? value(ind) + mfv : mfv
end
