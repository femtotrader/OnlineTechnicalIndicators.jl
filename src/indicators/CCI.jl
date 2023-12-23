const CCI_PERIOD = 3

"""
    CCI{T}(; period=CCI_PERIOD)

The CCI type implements a Commodity Channel Index.
"""
mutable struct CCI{Tval} <: AbstractIncTAIndicator
    period::Integer

    mean_dev::MeanDev{Tval}

    output::CircularBuffer{Union{Tval,Missing}}

    function CCI{Tval}(; period = CCI_PERIOD) where {Tval}
        mean_dev = MeanDev{Tval}(period = period)
        output = CircularBuffer{Union{Tval,Missing}}(period)
        new{Tval}(period, mean_dev, output)
    end
end

function Base.push!(ind::CCI, candle::OHLCV)
    typical_price = (candle.high + candle.low + candle.close) / 3.0
    push!(ind.mean_dev, typical_price)
    if !has_output_value(ind.mean_dev)
        out_val = missing
    else
        out_val =
            (typical_price - ind.mean_dev.sma.output[end]) /
            (0.015 * ind.mean_dev.output[end])
    end
    push!(ind.output, out_val)
    return out_val
end
