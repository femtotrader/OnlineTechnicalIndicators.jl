const ALMA_PERIOD = 9
const ALMA_OFFSET = 0.85
const ALMA_SIGMA = 6.0


"""
    ALMA{T}(; period = ALMA_PERIOD, offset = ALMA_OFFSET, sigma = ALMA_SIGMA, input_modifier_return_type = T)

The `ALMA` type implements an Arnaud Legoux Moving Average indicator.

ALMA uses a Gaussian distribution to weight prices, providing a smooth moving average
that can be tuned to emphasize either recent or older data. The offset parameter controls
where the curve peaks (1 = recent, 0 = older), and sigma controls the width.

# Parameters
- `period::Integer = $ALMA_PERIOD`: The number of periods for the moving average
- `offset::Number = $ALMA_OFFSET`: Controls the Gaussian peak location (0 to 1, higher = more recent)
- `sigma::Number = $ALMA_SIGMA`: Controls the Gaussian curve width (higher = smoother)
- `input_modifier_return_type::Type = T`: Output value type (defaults to input type)

# Formula
```
m = floor((period - 1) × offset)
s = period / sigma
w[i] = exp(-((i - 1 - m)²) / (2 × s²))
ALMA = sum(price[i] × w[i]) / sum(w)
```

# Returns
`Union{Missing,T}` - The ALMA value, or `missing` during the warm-up period
(first `period - 1` observations).

See also: [`SMA`](@ref), [`EMA`](@ref), [`WMA`](@ref)
"""
mutable struct ALMA{Tval,IN,T2} <: MovingAverageIndicator{Tval}
    value::Union{Missing,T2}
    n::Int

    period::Integer
    offset::T2
    sigma::T2

    w::Vector
    w_sum::T2
    input_values::CircBuff

    function ALMA{Tval}(;
        period = ALMA_PERIOD,
        offset = ALMA_OFFSET,
        sigma = ALMA_SIGMA,
        input_modifier_return_type = Tval,
    ) where {Tval}
        T2 = input_modifier_return_type
        w = T2[]
        w_sum = zero(T2)
        s = period / sigma
        m = trunc(Int, (period - 1) * offset)
        for i = 1:period
            w_val = exp(-1 * (i - 1 - m) * (i - 1 - m) / (2 * s * s))
            push!(w, w_val)
            w_sum += w_val
        end
        input_values = CircBuff(T2, period, rev = false)
        new{Tval,false,T2}(missing, 0, period, offset, sigma, w, w_sum, input_values)
    end
end

function ALMA(;
    period = ALMA_PERIOD,
    offset = ALMA_OFFSET,
    sigma = ALMA_SIGMA,
    input_modifier_return_type = Float64,
)
    ALMA{input_modifier_return_type}(;
        period = period,
        offset = offset,
        sigma = sigma,
        input_modifier_return_type = input_modifier_return_type,
    )
end

function _calculate_new_value(ind::ALMA{T,IN,S}) where {T,IN,S}
    if ind.n >= ind.period
        alma = zero(S)
        for i = 1:ind.period
            alma += ind.input_values[end-(ind.period-i)] * ind.w[i]
        end
        return alma / ind.w_sum
    else
        return missing
    end
end

