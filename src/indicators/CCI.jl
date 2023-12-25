const CCI_PERIOD = 3

"""
    CCI{Tohlcv}(; period=CCI_PERIOD)

The CCI type implements a Commodity Channel Index.
"""
mutable struct CCI{Tohlcv} <: OnlineStat{Tohlcv}
    value::Union{Missing,Float64}
    n::Int

    period::Integer

    mean_dev::MeanDev{Float64}

    function CCI{Tohlcv}(; period = CCI_PERIOD) where {Tohlcv}
        mean_dev = MeanDev{Float64}(period = period)
        new{Tohlcv}(missing, 0, period, mean_dev)
    end
end

function OnlineStatsBase._fit!(ind::CCI, candle::OHLCV)
    ind.n += 1
    typical_price = (candle.high + candle.low + candle.close) / 3.0
    fit!(ind.mean_dev, typical_price)
    if has_output_value(ind.mean_dev)
        ind.value =
            (typical_price - ind.mean_dev.sma.value[end]) /
            (0.015 * ind.mean_dev.value[end])
    else
        ind.value = missing
    end
end
