const SMA_PERIOD = 3

"""
    SMA{T1}(; period = SMA_PERIOD, input_filter = always_true, input_modifier = identity, input_modifier_return_type = T2)

The `SMA` type implements a Simple Moving Average indicator.

`fit!(o, val)` with `o` of type `SMA` will catch `val` of type `T1`

input `val` will be filtered using `input_filter` function (`true` means that val will be provided to `o`)

input `val` will be modified/transformed using `input_modifier` function (default is `identity` function which means that `val` won't be modified)

`input_modifier_return_type` is the type `T2` of return of the `input_modifier` function it's also type of indicator value

by default `T1 = T2`
"""
mutable struct SMA{T1,T2} <: MovingAverageIndicator{T1}
    value::Union{Missing,T2}
    n::Int

    output_listeners::Series

    period::Int

    input_indicator::Union{Missing,TechnicalIndicator}
    input_values::CircBuff{T2}

    input_filter::Function
    input_modifier::Function

    function SMA{T1}(; period = SMA_PERIOD, input_filter = always_true, input_modifier = identity, input_modifier_return_type = T1) where {T1}
        T2 = input_modifier_return_type
        input_values = CircBuff(T2, period, rev = false)
        output_listeners = Series()
        input_indicator = missing
        new{T1,T2}(missing, 0, output_listeners, period, input_indicator, input_values, input_filter, input_modifier)
    end
end

function _calculate_new_value(ind::SMA)
    values = ind.input_values.value
    return sum(values) / length(values)  # mean(values)
end
