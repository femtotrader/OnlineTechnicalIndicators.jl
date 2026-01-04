const RSI_PERIOD = 3

"""
    RSI{T}(; period = RSI_PERIOD, input_modifier_return_type = T)

The `RSI` type implements a Relative Strength Index indicator.

RSI is a momentum oscillator that measures the speed and magnitude of recent price changes
to evaluate overbought or oversold conditions. Developed by J. Welles Wilder Jr.

# Parameters
- `period::Integer = $RSI_PERIOD`: The lookback period for calculating average gains and losses
- `input_modifier_return_type::Type = T`: Output value type (defaults to input type)

# Formula
```
RS = Average Gain / Average Loss
RSI = 100 - (100 / (1 + RS))
```
where Average Gain and Average Loss are calculated using SMMA (Smoothed Moving Average).

# Returns
`Union{Missing,T}` - RSI value between 0 and 100, or `missing` during the warm-up period.
Values above 70 typically indicate overbought conditions, below 30 indicate oversold.

See also: [`SMMA`](@ref)
"""
mutable struct RSI{Tval,IN,T2} <: TechnicalIndicatorSingleOutput{Tval}
    value::Union{Missing,T2}
    n::Int

    period::Integer

    gains::SMMA
    losses::SMMA

    input_values::CircBuff

    function RSI{Tval}(;
        period = RSI_PERIOD,
        input_modifier_return_type = Tval,
    ) where {Tval}
        T2 = input_modifier_return_type
        input_values = CircBuff(T2, 2, rev = false)
        value = missing
        gains = SMMA{T2}(period = period)
        losses = SMMA{T2}(period = period)
        new{Tval,false,T2}(missing, 0, period, gains, losses, input_values)
    end
end

function RSI(; period = RSI_PERIOD, input_modifier_return_type = Float64)
    RSI{input_modifier_return_type}(;
        period = period,
        input_modifier_return_type = input_modifier_return_type,
    )
end

function _calculate_new_value(ind::RSI{T,IN,S}) where {T,IN,S}
    if ind.n > 1
        change = ind.input_values[end] - ind.input_values[end-1]

        gain = change > 0 ? change : zero(S)
        loss = change < 0 ? -change : zero(S)

        fit!(ind.gains, gain)
        fit!(ind.losses, loss)

        _losses = value(ind.losses)
        if ismissing(_losses)
            return missing
        end

        if _losses == 0
            rsi = 100 * one(S)
        else
            rs = value(ind.gains) / _losses
            rsi = 100 * one(S) - 100 * one(S) / (one(S) + rs)
        end
        return rsi
    else
        return missing
    end
end
