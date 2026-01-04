const ZLEMA_PERIOD = 20


"""
    ZLEMA{T}(; period = ZLEMA_PERIOD, input_modifier_return_type = T)

The `ZLEMA` type implements a Zero Lag Exponential Moving Average indicator.

ZLEMA reduces the lag inherent in traditional moving averages by adding a momentum term
that compensates for the lag. This makes it more responsive to recent price changes
while still providing smoothing.

# Parameters
- `period::Integer = $ZLEMA_PERIOD`: The number of periods for the ZLEMA calculation
- `input_modifier_return_type::Type = T`: Output value type (defaults to input type)

# Formula
```
lag = (period - 1) / 2
adjusted_price = price + (price - price[lag])
ZLEMA = EMA(adjusted_price, period)
```

# Returns
`Union{Missing,T}` - The zero lag exponential moving average value, or `missing` during
the warm-up period (first `lag` observations).

See also: [`EMA`](@ref), [`DEMA`](@ref), [`TEMA`](@ref)
"""
mutable struct ZLEMA{Tval,IN,T2} <: MovingAverageIndicator{Tval}
    value::Union{Missing,T2}
    n::Int

    period::Int
    lag::Int
    ema::EMA
    input_values::CircBuff

    function ZLEMA{Tval}(;
        period = ZLEMA_PERIOD,
        input_modifier_return_type = Tval,
    ) where {Tval}
        T2 = input_modifier_return_type
        lag = round(Int, (period - 1) / 2.0)
        input_values = CircBuff(T2, lag + 1, rev = false)
        ema = EMA{T2}(period = period)

        new{Tval,false,T2}(missing, 0, period, lag, ema, input_values)
    end
end

function ZLEMA(; period = ZLEMA_PERIOD, input_modifier_return_type = Float64)
    ZLEMA{input_modifier_return_type}(;
        period = period,
        input_modifier_return_type = input_modifier_return_type,
    )
end

function _calculate_new_value(ind::ZLEMA)
    if length(ind.input_values) >= ind.lag + 1
        fit!(
            ind.ema,
            ind.input_values[end] + (ind.input_values[end] - ind.input_values[end-ind.lag]),
        )
        return value(ind.ema)
    else
        return missing
    end
end
