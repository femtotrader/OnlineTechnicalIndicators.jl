const StdDev_PERIOD = 3

"""
    StdDev{T}(; period = StdDev_PERIOD, input_filter = always_true, input_modifier = identity, input_modifier_return_type = T)

The `StdDev` type implements a Standard Deviation indicator.
"""
mutable struct StdDev{T1,T2} <: TechnicalIndicator{T1}
    value::Union{Missing,T2}
    n::Int

    period::Integer

    input_values::CircBuff
    input_filter::Function
    input_modifier::Function

    function StdDev{T1}(;
        period = StdDev_PERIOD,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = T1,
    ) where {T1}
        T2 = input_modifier_return_type
        input_values = CircBuff(T2, period, rev = false)
        new{T1,T2}(missing, 0, period, input_values, input_filter, input_modifier)
    end
end

function _calculate_new_value(ind::StdDev)
    _mean = sum(value(ind.input_values)) / ind.period
    return sqrt(sum([(item - _mean)^2 for item in value(ind.input_values)]) / ind.period)
end
