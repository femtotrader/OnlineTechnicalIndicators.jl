const ChandeKrollStop_ATR_PERIOD = 5
const ChandeKrollStop_ATR_MULT = 2.0
const ChandeKrollStop_PERIOD = 3

"""
    ChandeKrollStopVal{Tval}

Return value type for Chande Kroll Stop indicator.

# Fields
- `short_stop::Tval`: Short stop level (for short positions)
- `long_stop::Tval`: Long stop level (for long positions)

See also: [`ChandeKrollStop`](@ref)
"""
struct ChandeKrollStopVal{Tval}
    short_stop::Tval
    long_stop::Tval
end

"""
    ChandeKrollStop{Tohlcv}(; atr_period = ChandeKrollStop_ATR_PERIOD, atr_mult = ChandeKrollStop_ATR_MULT, period = ChandeKrollStop_PERIOD, input_modifier_return_type = Tohlcv)

The `ChandeKrollStop` type implements a Chande Kroll Stop indicator.

The Chande Kroll Stop is a volatility-based trailing stop indicator that adapts to market
conditions using ATR. It calculates stop levels for both long and short positions,
helping traders set protective stops that account for normal price fluctuations.

# Parameters
- `atr_period::Integer = $ChandeKrollStop_ATR_PERIOD`: Period for ATR calculation
- `atr_mult::Number = $ChandeKrollStop_ATR_MULT`: Multiplier for ATR (controls stop distance)
- `period::Integer = $ChandeKrollStop_PERIOD`: Period for stop level smoothing
- `input_modifier_return_type::Type = Tohlcv`: Input OHLCV type

# Formula
```
High Stop = max(high, atr_period) - ATR × atr_mult
Low Stop = min(low, atr_period) + ATR × atr_mult
Short Stop = max(High Stop, period)
Long Stop = min(Low Stop, period)
```

# Input
Requires OHLCV data with `high`, `low`, and `close` fields.

# Output
- [`ChandeKrollStopVal`](@ref): Contains `short_stop` and `long_stop` levels

# Returns
`Union{Missing,ChandeKrollStopVal}` - The stop levels, or `missing` during warm-up.

See also: [`ATR`](@ref), [`SuperTrend`](@ref), [`ParabolicSAR`](@ref)
"""
mutable struct ChandeKrollStop{Tohlcv,IN,S} <: TechnicalIndicatorMultiOutput{Tohlcv}
    value::Union{Missing,ChandeKrollStopVal}
    n::Int

    atr_period::Integer
    atr_mult::S
    period::Integer

    sub_indicators::Series
    atr::ATR

    high_stop_list::CircBuff
    low_stop_list::CircBuff
    input_values::CircBuff

    function ChandeKrollStop{Tohlcv}(;
        atr_period = ChandeKrollStop_ATR_PERIOD,
        atr_mult = ChandeKrollStop_ATR_MULT,
        period = ChandeKrollStop_PERIOD,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        S = fieldtype(T2, :close)
        input_values = CircBuff(T2, atr_period, rev = false)
        atr = ATR{T2}(period = atr_period)
        sub_indicators = Series(atr)
        high_stop_list = CircBuff(S, period, rev = false)
        low_stop_list = CircBuff(S, period, rev = false)
        new{Tohlcv,true,S}(
            missing,
            0,
            atr_period,
            atr_mult,
            period,
            sub_indicators,
            atr,
            high_stop_list,
            low_stop_list,
            input_values,
        )
    end
end

function ChandeKrollStop(;
    atr_period = ChandeKrollStop_ATR_PERIOD,
    atr_mult = ChandeKrollStop_ATR_MULT,
    period = ChandeKrollStop_PERIOD,
    input_modifier_return_type = OHLCV{Missing,Float64,Float64},
)
    ChandeKrollStop{input_modifier_return_type}(;
        atr_period = atr_period,
        atr_mult = atr_mult,
        period = period,
        input_modifier_return_type = input_modifier_return_type,
    )
end

function _calculate_new_value(ind::ChandeKrollStop)
    if (ind.n < ind.atr_period) || !has_output_value(ind.atr)
        return missing
    end

    fit!(
        ind.high_stop_list,
        max([cdl.high for cdl in ind.input_values.value]...) - value(ind.atr) * ind.atr_mult,
    )
    fit!(
        ind.low_stop_list,
        min([cdl.low for cdl in ind.input_values.value]...) + value(ind.atr) * ind.atr_mult,
    )

    if ind.n < ind.period
        return missing
    end

    return ChandeKrollStopVal(
        max(ind.high_stop_list.value...),
        min(ind.low_stop_list.value...),
    )
end
