const SuperTrend_ATR_PERIOD = 10
const SuperTrend_MULT = 3

module Trend
export TrendEnum
@enum TrendEnum UP DOWN
end # module

struct SuperTrendVal{Tval}
    value::Tval
    trend::Trend.TrendEnum
end

"""
    SuperTrend{Tohlcv,S}(; atr_period = SuperTrend_ATR_PERIOD, mult = SuperTrend_MULT, input_filter = always_true, input_modifier = identity, input_modifier_return_type = T)

The `SuperTrend` type implements a Super Trend indicator.
"""
mutable struct SuperTrend{Tohlcv,S} <: TechnicalIndicator{Tohlcv}
    value::Union{Missing,SuperTrendVal}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    atr_period::Integer
    mult::Integer

    sub_indicators::Series
    atr::ATR

    fub::CircBuff  # final upper band
    flb::CircBuff  # final lower band

    input_modifier::Function
    input_filter::Function
    input_values::CircBuff

    function SuperTrend{Tohlcv,S}(;
        atr_period = SuperTrend_ATR_PERIOD,
        mult = SuperTrend_MULT,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv,S}
        T2 = input_modifier_return_type
        atr = ATR{T2,S}(period = atr_period)
        sub_indicators = Series(atr)
        fub = CircBuff(S, 2, rev = false)  # capacity 2 may be enough
        flb = CircBuff(S, 2, rev = false)
        input_values = CircBuff(T2, atr_period, rev = false)
        new{Tohlcv,S}(
            initialize_indicator_common_fields()...,
            atr_period,
            mult,
            sub_indicators,
            atr,
            fub,
            flb,
            input_modifier,
            input_filter,
            input_values,
        )
    end
end

function _calculate_new_value(ind::SuperTrend)
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
            fub = 0.0
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
            flb = 0.0
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
            supertrend = 0
        end

        trend_dir = candle.close > supertrend ? Trend.UP : Trend.DOWN

        return SuperTrendVal(supertrend, trend_dir)

    else
        return missing
    end
end
