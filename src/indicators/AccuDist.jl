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

function _calculate_new_value_from_incoming_data(ind::AccuDist, candle)
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

function OnlineStatsBase._fit!(ind::AccuDist, data)
    T = typeof(ind)
    has_input_values = :input_values in fieldnames(T)
    if has_input_values
        fit!(ind.input_values, data)
    end
    if :sub_indicators in fieldnames(T)
        fit!(ind.sub_indicators, data)
    end
    ind.n += 1
    ind.value = has_input_values ? _calculate_new_value(ind) : _calculate_new_value_from_incoming_data(ind, data)
    fit_listeners!(ind)
end
