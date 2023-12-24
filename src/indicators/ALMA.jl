const ALMA_PERIOD = 9
const ALMA_OFFSET = 0.85
const ALMA_SIGMA = 6.0


"""
    ALMA{T}(; period = ALMA_PERIOD, offset = ALMA_OFFSET, sigma = ALMA_SIGMA)

The ALMA type implements an Arnaud Legoux Moving Average indicator.
"""
mutable struct ALMA{Tval} <: AbstractIncTAIndicator
    value::CircularBuffer{Union{Missing,Tval}}

    period::Integer
    offset::Tval
    sigma::Tval

    w::Vector{Tval}
    w_sum::Tval

    input::CircularBuffer{Tval}

    function ALMA{Tval}(;
        period = ALMA_PERIOD,
        offset = ALMA_OFFSET,
        sigma = ALMA_SIGMA,
    ) where {Tval}
        w = Tval[]
        w_sum = 0.0
        s = period / sigma
        m = trunc(Int, (period - 1) * offset)
        for i = 1:period
            w_val = exp(-1 * (i - 1 - m) * (i - 1 - m) / (2 * s * s))
            push!(w, w_val)
            w_sum += w_val
        end
        input = CircularBuffer{Tval}(period)
        value = CircularBuffer{Union{Missing,Tval}}(period)
        new{Tval}(value, period, offset, sigma, w, w_sum, input)
    end
end


function Base.push!(ind::ALMA{Tval}, val::Tval) where {Tval}
    push!(ind.input, val)

    if length(ind.input) < ind.period
        out_val = missing
    else
        alma = 0
        for i = 1:ind.period
            alma += ind.input[end-(ind.period-i)] * ind.w[i]
        end
        out_val = alma / ind.w_sum
    end

    push!(ind.value, out_val)
    return out_val
end
