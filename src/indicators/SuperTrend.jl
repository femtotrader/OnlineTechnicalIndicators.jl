const SuperTrend_ATR_PERIOD = 10
const SuperTrend_MULTIPLIER = 3

module Trend
export TrendEnum
@enum TrendEnum UP DOWN
end # module

struct SuperTrendVal{Tval}
    value::Tval
    trend::Trend.TrendEnum
end

"""
    SuperTrend{Tohlcv,S}(; atr_period = SuperTrend_ATR_PERIOD, mult = SuperTrend_MULTIPLIER)

The SuperTrend type implements a Super Trend indicator.
"""
mutable struct SuperTrend{Tohlcv,S} <: OnlineStat{Tohlcv}
    value::Union{Missing,SuperTrendVal}
    n::Int

    atr_period::Integer
    mult::Integer

    atr::ATR  # Tohlcv
    fub::CircBuff  # final upper band
    flb::CircBuff  # Tprice  # final lower band

    input::CircBuff{Tohlcv}

    function SuperTrend{Tohlcv,S}(;
        atr_period = SuperTrend_ATR_PERIOD,
        mult = SuperTrend_MULTIPLIER,
    ) where {Tohlcv,S}
        atr = ATR{Tohlcv,S}(period = atr_period)
        fub = CircBuff(S, atr_period, rev = false)  # capacity 2 may be enougth
        flb = CircBuff(S, atr_period, rev = false)
        input = CircBuff(Tohlcv, atr_period, rev = false)
        new{Tohlcv,S}(missing, 0, atr_period, mult, atr, fub, flb, input)
    end
end

function OnlineStatsBase._fit!(ind::SuperTrend, candle)
    fit!(ind.input, candle)
    fit!(ind.atr, candle)

    if !has_output_value(ind.atr)
        ind.value = missing
        return
    end

    #=
    BASIC UPPER BAND = HLA + [ MULTIPLIER * 10-DAY ATR ]
    BASIC LOWER BAND = HLA - [ MULTIPLIER * 10-DAY ATR ]
    =#

    hla = (candle.high + candle.low) / 2.0
    bub = hla + ind.mult * value(ind.atr)
    blb = hla - ind.mult * value(ind.atr)

    #=
    IF C.BUB < P.FUB OR P.CLOSE > P.FUB: C.FUB = C.BUB
    IF THE CONDITION IS NOT SATISFIED: C.FUB = P.FUB
    =#

    if length(ind.fub) == 0
        fub = 0.0
    else
        if bub < ind.fub.value[end] || ind.input.value[end-1].close > ind.fub.value[end]
            fub = bub
        else
            fub = ind.fub.value[end]
        end
    end
    fit!(ind.fub, fub)

    #=
    IF C.BLB > P.FLB OR P.CLOSE < P.FLB: C.FLB = C.BLB
    IF THE CONDITION IS NOT SATISFIED: C.FLB = P.FLB
    =#

    if length(ind.flb) == 0
        flb = 0.0
    elseif blb > ind.flb.value[end] || ind.input.value[end-1].close < ind.flb.value[end]
        flb = blb
    else
        flb = ind.flb.value[end]
    end
    fit!(ind.flb, flb)

    #=
    IF P.ST == P.FUB AND C.CLOSE < C.FUB: C.ST = C.FUB
    IF P.ST == P.FUB AND C.CLOSE > C.FUB: C.ST = C.FLB
    IF P.ST == P.FLB AND C.CLOSE > C.FLB: C.ST = C.FLB
    IF P.ST == P.FLB AND C.CLOSE < C.FLB: C.ST = C.FUB
    =#

    if !has_output_value(ind)
        supertrend = 0
    else
        _val = value(ind)
        supertrend = 99999999
        println(
            _val.value,
            " ",
            ind.fub.value[end-1],
            " ",
            candle.close,
            " ",
            ind.fub.value[end],
        )
        if _val.value == ind.fub.value[end-1] && candle.close <= ind.fub.value[end]
            supertrend = ind.fub.value[end]
            supertrend = 100000
        elseif _val.value == ind.fub.value[end-1] && candle.close > ind.fub.value[end]
            supertrend = ind.fub.value[end]
            supertrend = 200000
        elseif _val.value == ind.flb.value[end-1] && candle.close >= ind.flb.value[end]
            supertrend = ind.fub.value[end]
            supertrend = 300000
        elseif _val.value == ind.flb.value[end-1] && candle.close < ind.flb.value[end]
            supertrend = ind.fub.value[end]
            supertrend = 400000
        end
        println(supertrend)
    end

    trend_dir = candle.close > supertrend ? Trend.UP : Trend.DOWN

    ind.value = SuperTrendVal(supertrend, trend_dir)
end
