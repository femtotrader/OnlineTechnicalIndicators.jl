const ROC_PERIOD = 3

"""
    ROC{T}(; period = ROC_PERIOD)

The ROC type implements a Rate Of Change indicator.
"""
mutable struct ROC{Tval} <: AbstractIncTAIndicator
    period::Integer

    input::CircularBuffer{Tval}
    output::CircularBuffer{Union{Tval,Missing}}

    function ROC{Tval}(; period = ROC_PERIOD) where {Tval}
        input = CircularBuffer{Tval}(period + 1)
        output = CircularBuffer{Union{Tval,Missing}}(period + 1)
        new{Tval}(period, input, output)
    end
end

function Base.push!(ind::ROC{Tval}, val::Tval) where {Tval}
    push!(ind.input, val)
    if length(ind.input) - ind.period < 1
        out_val = missing
    else
        out_val =
            100.0 * (ind.input[end] - ind.input[end-ind.period]) / ind.input[end-ind.period]
    end
    push!(ind.output, out_val)
    return out_val
end

function output(ind::ROC)
    return ind.output[end]
end
