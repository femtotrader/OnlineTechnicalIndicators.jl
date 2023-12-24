const BOP_MEMORY = 3

"""
    BOP{T}(; memory = BOP_MEMORY)

The BOP type implements a Balance Of Power indicator.
"""
mutable struct BOP{T} <: AbstractIncTAIndicator
    value::CircularBuffer{Union{T,Missing}}

    memory::Integer

    function BOP{T}(; memory = BOP_MEMORY) where {T}
        value = CircularBuffer{Union{T,Missing}}(memory)
        new{T}(value, memory)
    end
end

function Base.push!(ind::BOP, candle::OHLCV)
    if candle.high != candle.low
        out_val = (candle.close - candle.open) / (candle.high - candle.low)
    else
        if length(ind.value) > 0
            out_val = ind.value[end]
        else
            out_val = missing
        end
    end
    push!(ind.value, out_val)
    return out_val
end
