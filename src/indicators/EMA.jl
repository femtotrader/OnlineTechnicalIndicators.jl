const EMA_PERIOD = 3

"""
    EMA{T}(; period=EMA_PERIOD)

The EMA type implements an Exponential Moving Average indicator.
"""
struct EMA{Tval<:Number} <: AbstractIncTAIndicator
    period::Integer

    input::CircularBuffer{Tval}
    value::CircularBuffer{Tval}

    function EMA{Tval}(; period = EMA_PERIOD) where {Tval}
        input = CircularBuffer{Tval}(period)
        value = CircularBuffer{Tval}(period)
        new{Tval}(period, input, value)
    end
end

function Base.push!(ind::EMA{Tval}, val) where {Tval}
    push!(ind.input, val)
    if isfull(ind.value)  # length(ind.value) == capacity(ind.value)
        mult = 2.0 / (ind.period + 1.0)
        new_val = mult * ind.input[end] + (1.0 - mult) * ind.value[end]
    else
        new_val = sum(ind.input) / ind.period
    end
    push!(ind.value, new_val)
    #ind.value[end]
    return output(ind)
end

function output(ind::EMA)
    try
        return ind.value[ind.period]
    catch e
        if isa(e, BoundsError)
            return missing
        end
    end
end
