const StdDev_PERIOD = 3

"""
    StdDev{T}(; period = StdDev_PERIOD)

The `StdDev` type implements a Standard Deviation indicator.
"""
mutable struct StdDev{Tval} <: TechnicalIndicator{Tval}
    value::Union{Missing,Tval}
    n::Int

    period::Integer

    input_values::CircBuff{Tval}

    function StdDev{Tval}(; period = StdDev_PERIOD) where {Tval}
        input_values = CircBuff(Tval, period, rev = false)
        new{Tval}(missing, 0, period, input_values)
    end
end

function _calculate_new_value(ind::StdDev)
    _mean = sum(value(ind.input_values)) / ind.period
    return sqrt(sum([(item - _mean)^2 for item in value(ind.input_values)]) / ind.period)
end
