const SMMA_PERIOD = 3

"""
    SMMA{T}(; period = SMA_PERIOD)

The SMMA type implements a SMoothed Moving Average indicator.
"""
mutable struct SMMA{Tval} <: AbstractIncTAIndicator
    value::CircularBuffer{Union{Tval,Missing}}

    period::Integer

    rolling::Bool

    input::CircularBuffer{Tval}

    function SMMA{Tval}(; period = SMMA_PERIOD) where {Tval}
        input = CircularBuffer{Tval}(period)
        value = CircularBuffer{Union{Tval,Missing}}(period)
        rolling = false
        new{Tval}(value, period, rolling, input)
    end
end

function Base.push!(ind::SMMA{Tval}, val::Tval) where {Tval}
    push!(ind.input, val)
    N = length(ind.input)

    if N < ind.period
        out_val = missing
    else
        if !ind.rolling
            ind.rolling = true
            out_val = sum(ind.input) / ind.period
        else
            out_val = (ind.value[end] * (ind.period - 1) + val) / ind.period
        end
    end
    push!(ind.value, out_val)
    return out_val
end

function output(ind::SMMA)
    try
        return ind.value[ind.period]
    catch e
        if isa(e, BoundsError)
            return missing
        end
    end
end
