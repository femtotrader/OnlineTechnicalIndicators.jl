const BOP_MEMORY = 3

"""
    BOP{T}(; memory=BOP_MEMORY)

The BOP type implements a Balance Of Power indicator.
"""
mutable struct BOP{T} <: AbstractIncTAIndicator
    memory::Integer

    output::CircularBuffer{Union{T, Missing}}

    function BOP{T}(; memory=BOP_MEMORY) where {T}
        output = CircularBuffer{Union{T, Missing}}(memory)
        new{T}(memory, output)
    end
end

function Base.push!(ind::BOP, value::OHLCV)
    if value.high != value.low
        out_val = (value.close - value.open) / (value.high - value.low)
    else
        if length(ind.output) > 0
            out_val = ind.output[end]
        else
            out_val = missing
        end
    end
    push!(ind.output, out_val)
    return out_val
end