const OBV_MEMORY = 3

"""
    OBV{Ttime, Tprice, Tvol}(; memory = OBV_MEMORY)

The OBV type implements On Balance Volume indicator.
"""
mutable struct OBV{Ttime,Tprice,Tvol} <: AbstractIncTAIndicator
    value::CircularBuffer{Union{Tprice,Missing}}

    period::Integer

    input::Tuple{
        Union{Missing,OHLCV{Ttime,Tprice,Tvol}},
        Union{Missing,OHLCV{Ttime,Tprice,Tvol}},
    }

    function OBV{Ttime,Tprice,Tvol}(; memory = OBV_MEMORY) where {Ttime,Tprice,Tvol}
        input = (missing, missing)
        value = CircularBuffer{Union{Tprice,Missing}}(memory)
        new{Ttime,Tprice,Tvol}(value, memory, input)
    end
end

function Base.push!(ind::OBV, candle::OHLCV)
    ind.input = (ind.input[end], candle)  # Keep a small window of input values

    if sum(ismissing.(ind.input)) >= 1
        out_val = candle.volume
    else
        value = ind.input[end]
        prev_value = ind.input[end-1]

        if value.close == prev_value.close
            out_val = ind.value[end]
        elseif value.close > prev_value.close
            out_val = ind.value[end] + value.volume
        else
            out_val = ind.value[end] - value.volume
        end

    end

    push!(ind.value, out_val)
    return out_val
end
