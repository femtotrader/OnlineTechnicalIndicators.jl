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
        input_values = CircBuff(Tval, period, rev = false)
        new{Tval}(missing, 0, period, offset, sigma, w, w_sum, input_values)
    end
end

function _calculate_new_value(ind::ALMA)
    if ind.n >= ind.period
        alma = 0
        for i = 1:ind.period
            alma += ind.input_values[end-(ind.period-i)] * ind.w[i]
        end
        return alma / ind.w_sum
    else
        return missing
    end
end

