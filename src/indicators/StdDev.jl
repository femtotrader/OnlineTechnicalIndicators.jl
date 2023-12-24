const StdDev_PERIOD = 3

"""
    StdDev{T}(; period = StdDev_PERIOD)

The StdDev type implements a Standard Deviation indicator.
"""
mutable struct StdDev{Tval} <: AbstractIncTAIndicator
    value::CircularBuffer{Union{Tval,Missing}}

    period::Integer

    input::CircularBuffer{Tval}

    function StdDev{Tval}(; period = StdDev_PERIOD) where {Tval}
        input = CircularBuffer{Tval}(period)
        value = CircularBuffer{Union{Tval,Missing}}(period)
        new{Tval}(value, period, input)
    end
end

function Base.push!(ind::StdDev{Tval}, val::Tval) where {Tval}
    push!(ind.input, val)
    _mean = sum(ind.input) / ind.period
    out_val = sqrt(sum([(item - _mean)^2 for item in ind.input]) / ind.period)
    push!(ind.value, out_val)
    return out_val
end

function output(ind::StdDev)
    return ind.value[end]
end
