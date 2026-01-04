const WMA_PERIOD = 3

"""
    WMA{T}(; period = WMA_PERIOD, input_modifier_return_type = T)

The `WMA` type implements a Weighted Moving Average indicator.

WMA assigns linearly increasing weights to more recent data points, giving them greater
influence on the average. The most recent observation has weight `period`, the second
most recent has weight `period - 1`, and so on.

# Parameters
- `period::Integer = $WMA_PERIOD`: The number of periods for the weighted average
- `input_modifier_return_type::Type = T`: Output value type (defaults to input type)

# Formula
`WMA = Σ(weight_i * price_i) / Σ(weight_i)`

where `weight_i = period - i + 1` for i from 1 to period, and the denominator
equals `period * (period + 1) / 2`.

# Returns
`Union{Missing,T}` - The weighted moving average value. Returns values immediately
as this indicator has no warm-up period.

See also: [`SMA`](@ref), [`EMA`](@ref), [`HMA`](@ref)
"""
mutable struct WMA{Tval,IN,T2} <: MovingAverageIndicator{Tval}
    value::Union{Missing,T2}
    n::Int

    period::Integer

    total::T2
    numerator::T2
    denominator::T2
    input_values::CircBuff

    function WMA{Tval}(;
        period = WMA_PERIOD,
        input_modifier_return_type = Tval,
    ) where {Tval}
        T2 = input_modifier_return_type
        input_values = CircBuff(T2, period + 1, rev = false)
        total = zero(T2)
        numerator = zero(T2)
        denominator = period * (period + one(T2)) / (2 * one(T2))

        new{Tval,false,T2}(missing, 0, period, total, numerator, denominator, input_values)
    end
end

function WMA(; period = WMA_PERIOD, input_modifier_return_type = Float64)
    WMA{input_modifier_return_type}(;
        period = period,
        input_modifier_return_type = input_modifier_return_type,
    )
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
