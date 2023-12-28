const CCI_PERIOD = 3

"""
    CCI{Tohlcv,S}(; period=CCI_PERIOD)

The `CCI` type implements a Commodity Channel Index.
"""
mutable struct CCI{Tohlcv,S} <: TechnicalIndicator{Tohlcv}
    value::Union{Missing,S}
    n::Int

    period::Integer

    mean_dev::MeanDev{S}

    function CCI{Tohlcv,S}(; period = CCI_PERIOD) where {Tohlcv,S}
        mean_dev = MeanDev{S}(period = period)
        new{Tohlcv,S}(missing, 0, period, mean_dev)
    end
end

function OnlineStatsBase._fit!(ind::CCI, candle)
    ind.n += 1
    typical_price = (candle.high + candle.low + candle.close) / 3.0
    fit!(ind.mean_dev, typical_price)
    if has_output_value(ind.mean_dev)
        ind.value = (typical_price - value(ind.mean_dev.ma)) / (0.015 * value(ind.mean_dev))
    else
        ind.value = missing
    end
end
