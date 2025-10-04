const SMA_PERIOD = 3


"""
    SMA{T1}(; period = SMA_PERIOD, input_modifier_return_type = T2)

The `SMA` type implements a Simple Moving Average indicator.

`fit!(o, val)` with `o` of type `SMA` will catch `val` of type `T1`

`input_modifier_return_type` is the type `T2` of return of the `input_modifier` function it's also type of indicator value

by default `T2 = T1`

IN = false means that indicator is of "single input" type
IN = true means that indicator is of "multiple input" (candle) type
"""
mutable struct SMA{T1,IN,T2} <: MovingAverageIndicator{T1}
    value::Union{Missing,T2}
    n::Int

    period::Int
    rolling::Bool

    input_values::CircBuff

    function SMA{T1}(; period = SMA_PERIOD, input_modifier_return_type = T1) where {T1}
        T2 = input_modifier_return_type
        input_values = CircBuff(T2, period + 1, rev = false)
        new{T1,false,T2}(missing, 0, period, false, input_values)
    end
end

function SMA(; period = SMA_PERIOD, input_modifier_return_type = Float64)
    SMA{input_modifier_return_type}(;
        period = period,
        input_modifier_return_type = input_modifier_return_type,
    )
end

function _calculate_new_value(ind::SMA)
    if ind.rolling  # CircBuff is full and rolling
        return value(ind) - (ind.input_values[1] - ind.input_values[end]) / ind.period
    else
        if ind.n == ind.period  # CircBuff is full but not rolling
            ind.rolling = true
            _values = ind.input_values.value
            return sum(_values) / length(_values)
        else  # CircBuff is filling up
            return missing
        end
    end
end
