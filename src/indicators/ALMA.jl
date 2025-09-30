const ALMA_PERIOD = 9
const ALMA_OFFSET = 0.85
const ALMA_SIGMA = 6.0


"""
    ALMA{T}(; period = ALMA_PERIOD, offset = ALMA_OFFSET, sigma = ALMA_SIGMA, input_filter = always_true, input_modifier = identity, input_modifier_return_type = T)

The `ALMA` type implements an Arnaud Legoux Moving Average indicator.
"""
mutable struct ALMA{Tval,IN,T2} <: MovingAverageIndicator{Tval}
    value::Union{Missing,T2}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    period::Integer
    offset::T2
    sigma::T2

    w::Vector
    w_sum::T2

    input_modifier::Function
    input_filter::Function
    input_values::CircBuff

    function ALMA{Tval}(;
        period = ALMA_PERIOD,
        offset = ALMA_OFFSET,
        sigma = ALMA_SIGMA,
        input_filter = always_true,
        input_modifier = identity,
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
        new{Tval,false,T2}(
            initialize_indicator_common_fields()...,
            period,
            offset,
            sigma,
            w,
            w_sum,
            input_modifier,
            input_filter,
            input_values,
        )
    end
end

function ALMA(;
    period = ALMA_PERIOD,
    offset = ALMA_OFFSET,
    sigma = ALMA_SIGMA,
    input_filter = always_true,
    input_modifier = identity,
    input_modifier_return_type = Float64,
)
    ALMA{input_modifier_return_type}(;
        period=period,
        offset=offset,
        sigma=sigma,
        input_filter=input_filter,
        input_modifier=input_modifier,
        input_modifier_return_type=input_modifier_return_type)
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

