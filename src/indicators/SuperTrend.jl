const SuperTrend_ATR_PERIOD = 10
const SuperTrend_MULT = 3

module Trend
export TrendEnum
@enum TrendEnum UP DOWN
end # module

"""
    SuperTrendVal{Tval}

Return value type for Super Trend indicator.

# Fields
- `value::Tval`: Super Trend value (support/resistance level)
- `trend::Trend.TrendEnum`: Current trend direction (UP or DOWN)

See also: [`SuperTrend`](@ref)
"""
struct SuperTrendVal{Tval}
    value::Tval
    trend::Trend.TrendEnum
end

"""
    SuperTrend{Tohlcv}(; atr_period = SuperTrend_ATR_PERIOD, mult = SuperTrend_MULT, input_modifier_return_type = Tohlcv)

The `SuperTrend` type implements a Super Trend indicator.

SuperTrend is a trend-following indicator that uses ATR to create dynamic support and
resistance levels. It flips between acting as support (in uptrends) and resistance
(in downtrends), making it useful for trailing stops and trend identification.

# Parameters
- `atr_period::Integer = $SuperTrend_ATR_PERIOD`: Period for ATR calculation
- `mult::Integer = $SuperTrend_MULT`: ATR multiplier for band width
- `input_modifier_return_type::Type = Tohlcv`: Input OHLCV type

# Formula
```
HLA = (high + low) / 2
Upper Band = HLA + (mult × ATR)
Lower Band = HLA - (mult × ATR)
SuperTrend = Lower Band (in uptrend) or Upper Band (in downtrend)
```
The indicator switches bands when price crosses through.

# Input
Requires OHLCV data with `high`, `low`, and `close` fields.

# Output
- [`SuperTrendVal`](@ref): Contains `value` (the SuperTrend level) and `trend` (UP or DOWN)

# Returns
`Union{Missing,SuperTrendVal}` - The SuperTrend value and direction, or `missing` during warm-up.

See also: [`ATR`](@ref), [`ParabolicSAR`](@ref), [`ChandeKrollStop`](@ref)
"""
mutable struct SuperTrend{Tohlcv,IN,S} <: TechnicalIndicatorMultiOutput{Tohlcv}
    value::Union{Missing,SuperTrendVal}
    n::Int

    atr_period::Integer
    mult::Integer

    sub_indicators::Series
    atr::ATR

    fub::CircBuff  # final upper band
    flb::CircBuff  # final lower band
    input_values::CircBuff

    function SuperTrend{Tohlcv}(;
        atr_period = SuperTrend_ATR_PERIOD,
        mult = SuperTrend_MULT,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        S = fieldtype(T2, :close)
        atr = ATR{T2}(period = atr_period)
        sub_indicators = Series(atr)
        fub = CircBuff(S, 2, rev = false)  # capacity 2 may be enough
        flb = CircBuff(S, 2, rev = false)
        input_values = CircBuff(T2, atr_period, rev = false)
        new{Tohlcv,true,S}(
            missing,
            0,
            atr_period,
            mult,
            sub_indicators,
            atr,
            fub,
            flb,
            input_values,
        )
    end
end

function SuperTrend(;
    atr_period = SuperTrend_ATR_PERIOD,
    mult = SuperTrend_MULT,
    input_modifier_return_type = OHLCV{Missing,Float64,Float64},
)
    SuperTrend{input_modifier_return_type}(;
        atr_period = atr_period,
        mult = mult,
        input_modifier_return_type = input_modifier_return_type,
    )
end

function _calculate_new_value(ind::SuperTrend{T,IN,S}) where {T,IN,S}
    if has_output_value(ind.atr)

        candle = ind.input_values[end]

        #=
        BASIC UPPER BAND = HLA + [ MULT * 10-DAY ATR ]
        BASIC LOWER BAND = HLA - [ MULT * 10-DAY ATR ]
        =#

        hla = (candle.high + candle.low) / 2.0
        bub = hla + ind.mult * value(ind.atr)
        blb = hla - ind.mult * value(ind.atr)

        #=
        IF C.BUB < P.FUB OR P.CLOSE > P.FUB: C.FUB = C.BUB
        IF THE CONDITION IS NOT SATISFIED: C.FUB = P.FUB
        =#

        if !has_output_value(ind.fub)
            fub = zero(S)
        else
            if bub < ind.fub[end] || ind.input_values[end-1].close > ind.fub[end]
                fub = bub
            else
                fub = ind.fub[end]
            end
        end
        fit!(ind.fub, fub)

        #=
        IF C.BLB > P.FLB OR P.CLOSE < P.FLB: C.FLB = C.BLB
        IF THE CONDITION IS NOT SATISFIED: C.FLB = P.FLB
        =#

        if !has_output_value(ind.flb)
            flb = zero(S)
        elseif blb > ind.flb[end] || ind.input_values[end-1].close < ind.flb[end]
            flb = blb
        else
            flb = ind.flb[end]
        end
        fit!(ind.flb, flb)

        #=
        IF P.ST == P.FUB AND C.CLOSE < C.FUB: C.ST = C.FUB
        IF P.ST == P.FUB AND C.CLOSE > C.FUB: C.ST = C.FLB
        IF P.ST == P.FLB AND C.CLOSE > C.FLB: C.ST = C.FLB
        IF P.ST == P.FLB AND C.CLOSE < C.FLB: C.ST = C.FUB
        =#

        if has_output_value(ind)
            _value_ind = value(ind)
            if _value_ind.value == ind.fub[end-1] && candle.close <= ind.fub[end]
                supertrend = ind.fub[end]
            elseif _value_ind.value == ind.fub[end-1] && candle.close > ind.fub[end]
                supertrend = ind.flb[end]
            elseif _value_ind.value == ind.flb[end-1] && candle.close >= ind.flb[end]
                supertrend = ind.flb[end]
            elseif _value_ind.value == ind.flb[end-1] && candle.close < ind.flb[end]
                supertrend = ind.fub[end]
            end
        else
            supertrend = zero(S)
        end

        trend_dir = candle.close > supertrend ? Trend.UP : Trend.DOWN

        return SuperTrendVal(supertrend, trend_dir)

    else
        return missing
    end
end
