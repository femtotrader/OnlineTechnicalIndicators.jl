"""
    AccuDist{Tohlcv,S}(input_filter = always_true, input_modifier = identity)

The `AccuDist` type implements an Accumulation and Distribution indicator.
"""
mutable struct AccuDist{Tohlcv,IN,S} <: TechnicalIndicatorSingleOutput{Tohlcv}
    value::Union{Missing,S}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    input_modifier::Function
    input_filter::Function

    function AccuDist{Tohlcv}(;
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        S = fieldtype(T2, :close)
        new{Tohlcv,true,S}(initialize_indicator_common_fields()..., input_modifier, input_filter)
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
