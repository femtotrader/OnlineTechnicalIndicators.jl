const AccuDist_MEMORY = 3

"""
    AccuDist{T}(; memory = AccuDist_MEMORY)

The AccuDist type implements an Accumulation and Distribution indicator.
"""
mutable struct AccuDist{T} <: AbstractIncTAIndicator
    memory::Integer

    value::CircularBuffer{Union{T,Missing}}

    function AccuDist{T}(; memory = AccuDist_MEMORY) where {T}
        value = CircularBuffer{Union{T,Missing}}(memory)
        new{T}(memory, value)
    end
end

function has_output_value(ind::AccuDist)
    if length(ind.value) == 0
        return false
    else
        if ismissing(ind.value[end])
            return false
        else
            return true
        end
    end
end

function Base.push!(ind::AccuDist, value::OHLCV)
    if value.high != value.low
        # Calculate MFI and MFV
        mfi =
            ((value.close - value.low) - (value.high - value.close)) /
            (value.high - value.low)
        mfv = mfi * value.volume
    else
        # In case high and low are equal (division by zero), return previous value if exists, otherwise return None
        if has_output_value(ind)
            out_val = ind.value[end]
        else
            out_val = missing
        end
    end

    if !has_output_value(ind)
        out_val = mfv
    else
        out_val = ind.value[end] + mfv
    end

    push!(ind.value, out_val)
    return out_val
end
