"""
    AccuDist{Tohlcv,S}(input_filter = always_true, input_modifier = identity)

The `AccuDist` type implements an Accumulation and Distribution indicator.
"""
mutable struct AccuDist{Tohlcv,S} <: TechnicalIndicator{Tohlcv}
    value::Union{Missing,S}
    n::Int

    output_listeners::Series

    input_modifier::Function
    input_filter::Function
    input_indicator::Union{Missing,TechnicalIndicator}


    function AccuDist{Tohlcv,S}(;
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tohlcv  # not necessary but here to unify interface
    ) where {Tohlcv,S}
        output_listeners = Series()
        input_indicator = missing
        new{Tohlcv,S}(
            missing,
            0,
            output_listeners,
            input_modifier,
            input_filter,
            input_indicator,
        )
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
