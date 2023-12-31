const SMA_PERIOD = 3

"""
    SMA{T}(; period = SMA_PERIOD, input_filter = always_true, input_modifier = identity, modifier_type = T)

The `SMA` type implements a Simple Moving Average indicator.
"""
mutable struct SMA{Tval,T2} <: MovingAverageIndicator{Tval}
    value::Union{Missing,T2}
    n::Int

    output_listeners::Series

    period::Int

    input_indicator::Union{Missing,TechnicalIndicator}
    input_values::CircBuff{T2}

    input_filter::Function
    input_modifier::Function

    function SMA{Tval}(; period = SMA_PERIOD, input_filter = always_true, input_modifier = identity, modifier_type = Tval) where {Tval}
        T2 = modifier_type
        input_values = CircBuff(T2, period, rev = false)
        output_listeners = Series()
        input_indicator = missing
        new{Tval,T2}(missing, 0, output_listeners, period, input_indicator, input_values, input_filter, input_modifier)
    end
end

function _calculate_new_value(ind::SMA)
    values = ind.input_values.value
    return sum(values) / length(values)  # mean(values)
end
