const WMA_PERIOD = 3

"""
    WMA{T}(; period = WMA_PERIOD, input_filter = always_true, input_modifier = identity, input_modifier_return_type = T)

The `WMA` type implements a Weighted Moving Average indicator.
"""
mutable struct WMA{Tval,IN,T2} <: MovingAverageIndicator{Tval}
    value::Union{Missing,T2}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    period::Integer

    total::T2
    numerator::T2
    denominator::T2

    input_modifier::Function
    input_filter::Function
    input_values::CircBuff

    function WMA{Tval}(;
        period = WMA_PERIOD,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tval,
    ) where {Tval}
        T2 = input_modifier_return_type
        input_values = CircBuff(T2, period + 1, rev = false)
        total = zero(T2)
        numerator = zero(T2)
        denominator = period * (period + one(T2)) / (2 * one(T2))

        new{Tval,false,T2}(
            initialize_indicator_common_fields()...,
            period,
            total,
            numerator,
            denominator,
            input_modifier,
            input_filter,
            input_values,
        )
    end
end

function WMA(;
    period = WMA_PERIOD,
    input_filter = always_true,
    input_modifier = identity,
    input_modifier_return_type = Float64,
)
    WMA{input_modifier_return_type}(;
        period=period,
        input_filter=input_filter,
        input_modifier=input_modifier,
        input_modifier_return_type=input_modifier_return_type)
end

function _calculate_new_value(ind::WMA)
    if ind.n > ind.period
        losing = ind.input_values[1]
    else
        losing = 0
    end
    data = ind.input_values[end]
    # See https://en.wikipedia.org/wiki/Moving_average#Weighted_moving_average
    ind.numerator = ind.numerator + ind.period * data - ind.total
    ind.total = ind.total + data - losing
    return ind.numerator / ind.denominator
end
