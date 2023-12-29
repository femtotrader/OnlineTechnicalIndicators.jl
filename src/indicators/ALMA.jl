const ALMA_PERIOD = 9
const ALMA_OFFSET = 0.85
const ALMA_SIGMA = 6.0


"""
    ALMA{T}(; period = ALMA_PERIOD, offset = ALMA_OFFSET, sigma = ALMA_SIGMA)

The `ALMA` type implements an Arnaud Legoux Moving Average indicator.
"""
mutable struct ALMA{Tval} <: MovingAverageIndicator{Tval}
    value::Union{Missing,Tval}
    n::Int

    period::Integer
    offset::Tval
    sigma::Tval

    w::Vector{Tval}
    w_sum::Tval

    input_values::CircBuff{Tval}

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
        input = CircBuff(Tval, period, rev = false)
        new{Tval}(missing, 0, period, offset, sigma, w, w_sum, input)
    end
end

function OnlineStatsBase._fit!(ind::ALMA, data)
    fit!(ind.input_values, data)
    if ind.n == ind.period
        alma = 0
        for i = 1:ind.period
            alma += ind.input_values[end-(ind.period-i)] * ind.w[i]
        end
        ind.value = alma / ind.w_sum
    else
        ind.n += 1
        ind.value = missing
    end
end

#=

function Base.push!(ind::ALMA{Tval}, val::Tval) where {Tval}
    push!(ind.input_values, val)

    if length(ind.input_values) < ind.period
        out_val = missing
    else
        alma = 0
        for i = 1:ind.period
            alma += ind.input_values[end-(ind.period-i)] * ind.w[i]
        end
        out_val = alma / ind.w_sum
    end

    push!(ind.value, out_val)
    return out_val
end
=#
