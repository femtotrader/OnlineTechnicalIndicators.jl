#const ATR_PERIOD = 3

"""
    NATR{Tohlcv}(; period = ATR_PERIOD, ma = SMMA, input_modifier_return_type = Tohlcv)

The `NATR` type implements a Normalized Average True Range indicator.

NATR expresses the Average True Range as a percentage of the closing price, making it
easier to compare volatility across different securities regardless of their price levels.
Higher NATR values indicate higher volatility relative to the price.

# Parameters
- `period::Integer = $ATR_PERIOD`: The number of periods for the ATR calculation
- `ma::Type = SMMA`: The moving average type used for smoothing (default is Wilder's SMMA)
- `input_modifier_return_type::Type = Tohlcv`: Input OHLCV type (must have `high`, `low`, `close` fields)

# Formula
```
NATR = (ATR / close) × 100
```

# Input
Requires OHLCV data with `high`, `low`, and `close` fields.

# Returns
`Union{Missing,T}` - The normalized ATR as a percentage, or `missing` during the warm-up
period (first `period - 1` observations). Returns `missing` if close price is zero.

See also: [`ATR`](@ref), [`TrueRange`](@ref)
"""
mutable struct NATR{Tohlcv,IN,S} <: TechnicalIndicatorSingleOutput{Tohlcv}
    value::Union{Missing,S}
    n::Int

    period::Number

    atr::ATR
    input_values::CircBuff

    function NATR{Tohlcv}(;
        period = ATR_PERIOD,
        ma = SMMA,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        if hasfield(T2, :close)
            S = fieldtype(T2, :close)
        else
            S = Float64
        end
        atr = ATR{input_modifier_return_type}(period = period, ma = ma)
        input_values = CircBuff(T2, 2, rev = false)
        new{Tohlcv,true,S}(missing, 0, period, atr, input_values)
    end
end

function NATR(;
    period = ATR_PERIOD,
    ma = SMMA,
    input_modifier_return_type = OHLCV{Missing,Float64,Float64},
)
    NATR{input_modifier_return_type}(;
        period = period,
        ma = ma,
        input_modifier_return_type = input_modifier_return_type,
    )
end

function _calculate_new_value(ind::NATR)
    candle = ind.input_values[end]
    fit!(ind.atr, candle)
    if ind.input_values[end].close == 0
        return missing
    end
    return 100.0 * value(ind.atr) / ind.input_values[end].close
end
