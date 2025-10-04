const CCI_PERIOD = 3

"""
    CCI{Tohlcv}(; period=CCI_PERIOD, input_modifier_return_type = Tohlcv)

The `CCI` type implements a Commodity Channel Index.
"""
mutable struct CCI{Tohlcv,IN,S} <: TechnicalIndicatorSingleOutput{Tohlcv}
    value::Union{Missing,S}
    n::Int

    period::Integer

    mean_dev::MeanDev

    function CCI{Tohlcv}(;
        period = CCI_PERIOD,
        input_modifier_return_type = Tohlcv) where {Tohlcv}
        T2 = input_modifier_return_type
        S = fieldtype(T2, :close)
        mean_dev = MeanDev{S}(period = period)
        new{Tohlcv,true,S}(
            missing,
            0,
            period,
            mean_dev)
    end
end

function CCI(;
    period = CCI_PERIOD,
    input_modifier_return_type = OHLCV{Missing,Float64,Float64})
    CCI{input_modifier_return_type}(;
        period=period,
        input_modifier_return_type=input_modifier_return_type)
end

function _calculate_new_value_only_from_incoming_data(ind::CCI, candle)
    typical_price = (candle.high + candle.low + candle.close) / 3.0
    fit!(ind.mean_dev, typical_price)
    return has_output_value(ind.mean_dev) ?
           (typical_price - value(ind.mean_dev.ma)) / (0.015 * value(ind.mean_dev)) :
           missing
end
