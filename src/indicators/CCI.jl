const CCI_PERIOD = 3

"""
    CCI{T}(; period=CCI_PERIOD)

The CCI type implements a Commodity Channel Index.
"""
mutable struct CCI{Tval} <: OnlineStat{Tval}
    value::Union{Missing,Tval}
    n::Int

    period::Integer

    mean_dev::MeanDev{Tval}

    function CCI{Tval}(; period = CCI_PERIOD) where {Tval}
        mean_dev = MeanDev{Tval}(period = period)
        value = CircularBuffer{Union{Tval,Missing}}(period)
        new{Tval}(value, 0, period, mean_dev)
    end
end

function Base.push!(ind::CCI, candle::OHLCV)
    typical_price = (candle.high + candle.low + candle.close) / 3.0
    push!(ind.mean_dev, typical_price)
    if !has_output_value(ind.mean_dev)
        out_val = missing
    else
        out_val =
            (typical_price - ind.mean_dev.sma.value[end]) /
            (0.015 * ind.mean_dev.value[end])
    end
    push!(ind.value, out_val)
    return out_val
end
