const StdDev_PERIOD = 3

"""
    StdDev{T}(; period = StdDev_PERIOD, input_filter = always_true, input_modifier = identity, input_modifier_return_type = T)

The `StdDev` type implements a Standard Deviation indicator.
"""
mutable struct StdDev{T1,T2} <: TechnicalIndicatorSingleOutput{T1}
    value::Union{Missing,T2}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    period::Integer

    input_modifier::Function
    input_filter::Function
    input_values::CircBuff

    function StdDev{T1}(;
        period = StdDev_PERIOD,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = T1,
    ) where {T1}
        T2 = input_modifier_return_type
        input_values = CircBuff(T2, period, rev = false)
        new{T1,T2}(
            initialize_indicator_common_fields()...,
            period,
            input_modifier,
            input_filter,
            input_values,
        )
    end
end

function _calculate_new_value(ind::StdDev)
    _mean = sum(value(ind.input_values)) / ind.period
    return sqrt(sum([(item - _mean)^2 for item in value(ind.input_values)]) / ind.period)
end
