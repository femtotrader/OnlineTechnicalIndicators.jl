const MassIndex_EMA_PERIOD = 9
const MassIndex_EMA_EMA_PERIOD = 9
const MassIndex_EMA_RATIO_PERIOD = 10


"""
    MassIndex{T}(; ema_period=MassIndex_EMA_PERIOD, ema_ema_period=MassIndex_EMA_EMA_PERIOD, ema_ratio_period=MassIndex_EMA_RATIO_PERIOD)

The MassIndex type implements a Commodity Channel Index.
"""
mutable struct MassIndex{Tval} <: AbstractIncTAIndicator
    ema_ratio_period::Integer

    ema::EMA{Tval}
    ema_ema::EMA{Tval}
    ema_ratio::CircularBuffer{Tval}

    output::CircularBuffer{Union{Tval,Missing}}

    function MassIndex{Tval}(;
        ema_period = MassIndex_EMA_PERIOD,
        ema_ema_period = MassIndex_EMA_EMA_PERIOD,
        ema_ratio_period = MassIndex_EMA_RATIO_PERIOD,
    ) where {Tval}
        ema = EMA{Tval}(period = ema_period)
        ema_ema = EMA{Tval}(period = ema_ema_period)
        ema_ratio = CircularBuffer{Tval}(ema_ratio_period)
        output = CircularBuffer{Union{Tval,Missing}}(ema_period)
        new{Tval}(ema_ratio_period, ema, ema_ema, ema_ratio, output)
    end
end

function Base.push!(ind::MassIndex, candle::OHLCV)
    push!(ind.ema, candle.high - candle.low)

    if !has_output_value(ind.ema)
        out_val = missing
        push!(ind.output, out_val)
        return out_val
    end

    push!(ind.ema_ema, ind.ema.output[end])

    if !has_output_value(ind.ema_ema)
        out_val = missing
        push!(ind.output, out_val)
        return out_val
    end

    push!(ind.ema_ratio, ind.ema.output[end] / ind.ema_ema.output[end])

    if length(ind.ema_ratio) < ind.ema_ratio_period
        out_val = missing
        push!(ind.output, out_val)
        return out_val
    end

    out_val = sum(ind.ema_ratio)
    push!(ind.output, out_val)
    return out_val
end
