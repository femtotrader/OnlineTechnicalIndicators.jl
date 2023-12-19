const OBV_MEMORY = 3

"""
    OBV{Ttime, Tprice, Tvol}(; period=ForceIndex_PERIOD)

The OBV type implements On Balance Volume indicator.
"""
mutable struct OBV{Ttime, Tprice, Tvol} <: AbstractIncTAIndicator
    period::Integer

    input::Tuple{Union{Missing, OHLCV{Ttime, Tprice, Tvol}}, Union{Missing, OHLCV{Ttime, Tprice, Tvol}}}
    output::CircularBuffer{Union{Tprice, Missing}}

    function OBV{Ttime, Tprice, Tvol}(; memory=OBV_MEMORY) where {Ttime, Tprice, Tvol}
        input = (missing, missing)
        output = CircularBuffer{Union{Tprice, Missing}}(memory)
        new{Ttime, Tprice, Tvol}(memory, input, output)
    end
end

function Base.push!(ind::OBV, candle::OHLCV)
    ind.input = (ind.input[end], candle)  # Keep a small window of input values

    if sum(ismissing.(ind.input)) >= 1
        out_val = candle.volume
    else
        value = ind.input[end]
        prev_value = ind.input[end - 1]
   
        if value.close == prev_value.close
            out_val = ind.output[end]
        elseif value.close > prev_value.close
            out_val = ind.output[end] + value.volume
        else
            out_val = ind.output[end] - value.volume
        end

    end

    push!(ind.output, out_val)
    return out_val
end
