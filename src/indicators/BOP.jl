const BOP_MEMORY = 3

"""
    BOP{T}(; memory = BOP_MEMORY)

The BOP type implements a Balance Of Power indicator.
"""
mutable struct BOP{T} <: AbstractIncTAIndicator
    memory::Integer

    value::CircularBuffer{Union{T,Missing}}

    function BOP{T}(; memory = BOP_MEMORY) where {T}
        value = CircularBuffer{Union{T,Missing}}(memory)
        new{T}(memory, value)
    end
end

function Base.push!(ind::BOP, value::OHLCV)
    if value.high != value.low
        out_val = (value.close - value.open) / (value.high - value.low)
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
