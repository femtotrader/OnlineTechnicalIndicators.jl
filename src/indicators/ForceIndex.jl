const ForceIndex_PERIOD = 3

"""
    ForceIndex{Ttime, Tprice, Tvol}(; period=ForceIndex_PERIOD)

The ForceIndex type implements a Force Index indicator.
"""
mutable struct ForceIndex{Ttime, Tprice, Tvol} <: AbstractIncTAIndicator
    period::Integer

    ema::EMA{Tprice}

    input::Tuple{Union{Missing, OHLCV{Ttime, Tprice, Tvol}}, Union{Missing, OHLCV{Ttime, Tprice, Tvol}}}
    output::CircularBuffer{Union{Tprice, Missing}}

    function ForceIndex{Ttime, Tprice, Tvol}(; period=ForceIndex_PERIOD) where {Ttime, Tprice, Tvol}
        ema = EMA{Tprice}(period=period)
        input = (missing, missing)
        output = CircularBuffer{Union{Tprice, Missing}}(period)
        new{Ttime, Tprice, Tvol}(period, ema, input, output)
    end
end

function Base.push!(ind::ForceIndex, candle::OHLCV)
    ind.input = (ind.input[end], candle)  # Keep a small window of input values

    if any(ismissing.(ind.input))  #if ismissing(ind.input[end]) || ismissing(ind.input[end - 1])
        out_val = missing
        push!(ind.output, out_val)
        return out_val    
    end

    push!(ind.ema, (ind.input[end].close - ind.input[end - 1].close) * ind.input[end].volume)

    if !has_output_value(ind.ema)
        out_val = missing
    else
        out_val = ind.ema.output[end]
    end
    push!(ind.output, out_val)
    return out_val
end
