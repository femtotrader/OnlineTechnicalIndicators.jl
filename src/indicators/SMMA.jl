const SMMA_PERIOD = 3

"""
    SMMA{T}(; period = SMMA_PERIOD, input_modifier_return_type = T)

The `SMMA` type implements a Smoothed Moving Average indicator.

SMMA (also known as Wilder's Moving Average or Modified Moving Average) applies more
smoothing than EMA, making it less reactive to price changes. It's commonly used in
indicators like RSI and ATR.

# Parameters
- `period::Integer = $SMMA_PERIOD`: The number of periods for the smoothed average
- `input_modifier_return_type::Type = T`: Output value type (defaults to input type)

# Formula
```
SMMA = (SMMA_prev * (period - 1) + price) / period
```
The first SMMA value is calculated as a simple average of the first `period` prices.

# Returns
`Union{Missing,T}` - The smoothed moving average value, or `missing` during the warm-up period
(first `period - 1` observations).

See also: [`SMA`](@ref), [`EMA`](@ref), [`RSI`](@ref), [`ATR`](@ref)
"""
mutable struct SMMA{Tval,IN,T2} <: MovingAverageIndicator{Tval}
    value::Union{Missing,T2}
    n::Int

    period::Integer

    rolling::Bool

    input_values::CircBuff

    function SMMA{Tval}(;
        period = SMMA_PERIOD,
        input_modifier_return_type = Tval,
    ) where {Tval}
        T2 = input_modifier_return_type
        value = missing
        rolling = false
        input_values = CircBuff(T2, period, rev = false)
        new{Tval,false,T2}(missing, 0, period, rolling, input_values)
    end
end

function SMMA(; period = SMMA_PERIOD, input_modifier_return_type = Float64)
    SMMA{input_modifier_return_type}(;
        period = period,
        input_modifier_return_type = input_modifier_return_type,
    )
end

function _calculate_new_value(ind::SMMA)
    if ind.rolling  # CircBuff is full and rolling
        data = ind.input_values[end]
        return (ind.value * (ind.period - 1) + data) / ind.period
    else
        if ind.n == ind.period # CircBuff is full but not rolling
            ind.rolling = true
            return sum(ind.input_values.value) / ind.period
        else  # CircBuff is filling up
            return missing
        end
    end
end
