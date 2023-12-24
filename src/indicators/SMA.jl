const SMA_PERIOD = 3

"""
    SMA{T}(; period = SMA_PERIOD)

The SMA type implements a Simple Moving Average indicator.
"""
mutable struct SMA{Tval} <: AbstractIncTAIndicator
    value::CircularBuffer{Tval}

    period::Integer

    sum::Tval

    input::CircularBuffer{Tval}

    function SMA{Tval}(; period = SMA_PERIOD) where {Tval}
        input = CircularBuffer{Tval}(period)
        value = CircularBuffer{Tval}(period)
        sum = zero(Tval)
        new{Tval}(value, period, sum, input)
    end
end

function Base.push!(ind::SMA{Tval}, val::Tval) where {Tval}
    if length(ind.input) < ind.period
        losing = zero(Tval)
    else
        losing = ind.input[1]
    end
    ind.sum = ind.sum - losing + val
    push!(ind.input, val)
    out_val = output(ind)
    push!(ind.value, ind.sum / ind.period)
    return out_val
end

function output(ind::SMA)
    if length(ind.input) < ind.period
        missing
    else
        return ind.sum / ind.period
    end
end

# ===

"""
    SMA_v02{T}(; period=SMA_PERIOD)

The SMA_v02 type implements a Simple Moving Average indicator.
This is just an other implementation.
"""
mutable struct SMA_v02{Tval} <: AbstractIncTAIndicator
    value::CircularBuffer{Tval}

    period::Integer

    input::CircularBuffer{Tval}

    function SMA_v02{Tval}(; period = SMA_PERIOD) where {Tval}
        input = CircularBuffer{Tval}(period)
        value = CircularBuffer{Tval}(period)
        new{Tval}(value, period, input)
    end
end

function Base.push!(ind::SMA_v02{Tval}, val::Tval) where {Tval}
    push!(ind.input, val)
    push!(ind.value, sum(ind.input) / ind.period)
    out_val = output(ind)
    return out_val
end

function output(ind::SMA_v02)
    try
        return ind.value[ind.period]
    catch e
        if isa(e, BoundsError)
            return missing
        end
    end
end

#=

"""
    SMA_v03{T}(; period=SMA_PERIOD)

The SMA_v03 type implements a Simple Moving Average indicator.
This is just an other implementation.
"""
mutable struct SMA_v03{Tval} <: AbstractIncTAIndicator
    value::MovingWindow{Tval}
    input::MovingWindow{Tval}

    function SMA_v03{Tval}(; period = SMA_PERIOD) where {Tval}
        input = MovingWindow(period, Tval)
        output = MovingWindow(period, Tval)

        new{Tval}(value, input)
    end
end

function Base.push!(ind::SMA_v03{Tval}, val::Tval) where {Tval}
    fit!(ind.input, val)
    out_val = mean(value(ind.input))
    fit!(ind.value, out_val)
    return out_val
end

function output(ind::SMA_v03)
    try
        return ind.value[ind.period]
    catch e
        if isa(e, BoundsError)
            return missing
        end
    end
end

=#
