const WMA_PERIOD = 3

"""
    WMA{T}(; period = WMA_PERIOD)

The WMA type implements a Weighted Moving Average indicator.
"""
mutable struct WMA{Tval} <: AbstractIncTAIndicator
    value::CircularBuffer{Tval}

    period::Integer

    total::Tval
    numerator::Tval
    denominator::Tval

    input::CircularBuffer{Tval}

    function WMA{Tval}(; period = WMA_PERIOD) where {Tval}
        input = CircularBuffer{Tval}(period)
        value = CircularBuffer{Tval}(period)
        total = zero(Tval)
        numerator = zero(Tval)
        denominator = period * (period + 1) / 2.0
        new{Tval}(value, period, total, numerator, denominator, input)
    end
end

function Base.push!(ind::WMA{Tval}, val::Tval) where {Tval}
    if length(ind.input) < ind.period
        losing = zero(Tval)
    else
        losing = ind.input[1]
    end
    push!(ind.input, val)
    # See https://en.wikipedia.org/wiki/Moving_average#Weighted_moving_average
    ind.numerator = ind.numerator + ind.period * val - ind.total
    ind.total = ind.total + val - losing
    out_val = ind.numerator / ind.denominator
    push!(ind.value, out_val)
    return out_val
end

#=
function output(ind::WMA)
    if length(ind.input) < ind.period
        missing
    else
        return ind.sum / ind.period
    end
end
=#
