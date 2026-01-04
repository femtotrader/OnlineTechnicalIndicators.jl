const SMA_PERIOD = 3


"""
    SMA{T}(; period = SMA_PERIOD, input_modifier_return_type = T)

The `SMA` type implements a Simple Moving Average indicator.

SMA calculates the arithmetic mean of prices over a specified period. It gives equal
weight to all prices in the period, providing a smooth representation of price trends.

# Parameters
- `period::Integer = $SMA_PERIOD`: The number of periods for the moving average
- `input_modifier_return_type::Type = T`: Output value type (defaults to input type)

# Formula
`SMA = (P1 + P2 + ... + Pn) / n`

where n is the period and P1...Pn are the prices in the window.

# Returns
`Union{Missing,T}` - The simple moving average value, or `missing` during the warm-up period
(first `period - 1` observations).

See also: [`EMA`](@ref), [`WMA`](@ref), [`SMMA`](@ref)
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
