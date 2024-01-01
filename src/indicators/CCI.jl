const CCI_PERIOD = 3

"""
    CCI{Tohlcv,S}(; period=CCI_PERIOD, input_filter = always_true, input_modifier = identity, input_modifier_return_type = Tohlcv)

The `CCI` type implements a Commodity Channel Index.
"""
mutable struct CCI{Tohlcv,S} <: TechnicalIndicator{Tohlcv}
    value::Union{Missing,S}
    n::Int

    output_listeners::Series

    period::Integer

    mean_dev::MeanDev{S}

    input_modifier::Function
    input_filter::Function
    input_indicator::Union{Missing,TechnicalIndicator}

    function CCI{Tohlcv,S}(;
        period = CCI_PERIOD,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv,S}
        mean_dev = MeanDev{S}(period = period)
        output_listeners = Series()
        input_indicator = missing
        new{Tohlcv,S}(
            missing,
            0,
            output_listeners,
            period,
            mean_dev,
            input_modifier,
            input_filter,
            input_indicator,
        )
    end
end

function _calculate_new_value_only_from_incoming_data(ind::CCI, candle)
    typical_price = (candle.high + candle.low + candle.close) / 3.0
    fit!(ind.mean_dev, typical_price)
    return has_output_value(ind.mean_dev) ?
           (typical_price - value(ind.mean_dev.ma)) / (0.015 * value(ind.mean_dev)) :
           missing
end
