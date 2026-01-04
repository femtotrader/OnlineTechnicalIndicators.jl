const Aroon_PERIOD = 10

"""
    AroonVal{Tval}

Return value type for Aroon indicator.

# Fields
- `up::Tval`: Aroon Up (time since highest high)
- `down::Tval`: Aroon Down (time since lowest low)

See also: [`Aroon`](@ref)
"""
struct AroonVal{Tval}
    up::Tval
    down::Tval
end

"""
    Aroon{Tohlcv}(; period = Aroon_PERIOD, input_modifier_return_type = Tohlcv)

The `Aroon` type implements an Aroon indicator.

The Aroon indicator measures the time since the most recent high and low within a period.
It helps identify trend strength and potential reversals. Aroon Up near 100 indicates a
strong uptrend (recent high), while Aroon Down near 100 indicates a strong downtrend.

# Parameters
- `period::Integer = $Aroon_PERIOD`: The lookback period for the calculation
- `input_modifier_return_type::Type = Tohlcv`: Input OHLCV type

# Formula
```
Aroon Up = 100 × (period - days_since_high) / period
Aroon Down = 100 × (period - days_since_low) / period
```

# Input
Requires OHLCV data with `high` and `low` fields.

# Output
- [`AroonVal`](@ref): Contains `up` and `down` values (0-100 scale)

# Returns
`Union{Missing,AroonVal}` - The Aroon values, or `missing` during warm-up
(first `period` observations).

See also: [`ADX`](@ref), [`VTX`](@ref), [`MACD`](@ref)
"""
mutable struct Aroon{Tohlcv,IN,S} <: TechnicalIndicatorMultiOutput{Tohlcv}
    value::Union{Missing,AroonVal}
    n::Int

    period::Integer
    input_values::CircBuff

    function Aroon{Tohlcv}(;
        period = Aroon_PERIOD,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        S = fieldtype(T2, :close)
        input_values = CircBuff(T2, period + 1, rev = false)
        new{Tohlcv,true,S}(missing, 0, period, input_values)
    end
end

function Aroon(;
    period = Aroon_PERIOD,
    input_modifier_return_type = OHLCV{Missing,Float64,Float64},
)
    Aroon{input_modifier_return_type}(;
        period = period,
        input_modifier_return_type = input_modifier_return_type,
    )
end

function _calculate_new_value(ind::Aroon)
    if ind.n < ind.period + 1
        return missing
    end

    days_high = argmax([cdl.high for cdl in reverse(value(ind.input_values))]) - 1
    days_low = argmin([cdl.low for cdl in reverse(value(ind.input_values))]) - 1

    return AroonVal(
        100 * (ind.period - days_high) / ind.period,
        100 * (ind.period - days_low) / ind.period,
    )
end
