const ADR_PERIOD = 14

"""
    ADR{Tohlcv}(; period = ADR_PERIOD, ma = SMA, input_modifier_return_type = Tohlcv)

The `ADR` type implements an Average Day Range indicator.

ADR measures the average absolute price range by calculating the moving average of
IntradayRange (High - Low) over a specified period. Unlike ATR, ADR ignores gaps
from the previous close, making it ideal for intraday volatility analysis.

# Parameters
- `period::Integer = $ADR_PERIOD`: The number of periods for averaging the Intraday Range
- `ma::Type = SMA`: The moving average type to use (default: Simple Moving Average)
- `input_modifier_return_type::Type = Tohlcv`: Input type (must be OHLCV-compatible)

# Input
[`OHLCV`](@ref) candlestick data with `high` and `low` fields.

# Formula
```
IntradayRange = High - Low
ADR = MA(IntradayRange, period)
```

# Returns
`Union{Missing,T}` - The average day range value, or `missing` during the warm-up period.

See also: [`ARDR`](@ref), [`IntradayRange`](@ref), [`ATR`](@ref), [`TrueRange`](@ref), [`OHLCV`](@ref)
"""
mutable struct ADR{Tohlcv,IN,S} <: TechnicalIndicatorSingleOutput{Tohlcv}
    value::Union{Missing,S}
    n::Int

    period::Number

    ir::IntradayRange
    ir_average::MovingAverageIndicator

    input_values::CircBuff

    function ADR{Tohlcv}(;
        period = ADR_PERIOD,
        ma = SMA,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        if hasfield(T2, :close)
            S = fieldtype(T2, :close)
        else
            S = Float64
        end
        ir = IntradayRange{input_modifier_return_type}()
        ir_average = MAFactory(S)(ma, period = period)
        input_values = CircBuff(T2, 1, rev = false)
        new{Tohlcv,true,S}(missing, 0, period, ir, ir_average, input_values)
    end
end

function ADR(;
    period = ADR_PERIOD,
    ma = SMA,
    input_modifier_return_type = OHLCV{Missing,Float64,Float64},
)
    ADR{input_modifier_return_type}(;
        period = period,
        ma = ma,
        input_modifier_return_type = input_modifier_return_type,
    )
end

function _calculate_new_value(ind::ADR)
    candle = ind.input_values[end]
    fit!(ind.ir, candle)
    fit!(ind.ir_average, value(ind.ir))
    return value(ind.ir_average)
end
