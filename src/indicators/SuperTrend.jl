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
    SuperTrend{Ttime, Tprice, Tvol}(; period=CHOP_PERIOD)

The SuperTrend type implements a Choppiness Index indicator.
"""
mutable struct SuperTrend{Ttime, Tprice, Tvol} <: AbstractIncTAIndicator
    atr_period::Integer
    mult::Integer

    atr::ATR{Ttime, Tprice, Tvol}
    fub::CircularBuffer{Tprice}  # final upper band
    flb::CircularBuffer{Tprice}  # final lower band
    
    input::CircularBuffer{OHLCV{Ttime, Tprice, Tvol}}
    output::CircularBuffer{Union{SuperTrendVal, Missing}}

    function SuperTrend{Ttime, Tprice, Tvol}(; atr_period=SuperTrend_ATR_PERIOD, mult=SuperTrend_MULTIPLIER) where {Ttime, Tprice, Tvol}
        atr = ATR{Ttime, Tprice, Tvol}(period=atr_period)
        fub = CircularBuffer{Tprice}(atr_period)  # capacity 2 may be enougth
        flb = CircularBuffer{Tprice}(atr_period)

        input = CircularBuffer{OHLCV{Ttime, Tprice, Tvol}}(atr_period)
        output = CircularBuffer{Union{SuperTrendVal, Missing}}(atr_period)
        new{Ttime, Tprice, Tvol}(atr_period, mult, atr, fub, flb, input, output)
    end
end

function Base.push!(ind::SuperTrend, candle::OHLCV)
    push!(ind.input, candle)
    push!(ind.atr, candle)

    if !has_output_value(ind.atr)
        out_val = missing
        push!(ind.output, out_val)
        return out_val
    end

    #=
    BASIC UPPER BAND = HLA + [ MULTIPLIER * 10-DAY ATR ]
    BASIC LOWER BAND = HLA - [ MULTIPLIER * 10-DAY ATR ]
    =#

    hla = (candle.high + candle.low) / 2.0
    bub = hla + ind.mult * ind.atr.output[end]
    blb = hla - ind.mult * ind.atr.output[end]

    #=
    IF C.BUB < P.FUB OR P.CLOSE > P.FUB: C.FUB = C.BUB
    IF THE CONDITION IS NOT SATISFIED: C.FUB = P.FUB
    =#

    if length(ind.fub) == 0
        fub = 0
    else
        if bub < ind.fub[end] || ind.input[end - 1].close > ind.fub[end]
            fub = bub
        else
            fub = ind.fub[end]
        end
    end
    push!(ind.fub, fub)

    #=
    IF C.BLB > P.FLB OR P.CLOSE < P.FLB: C.FLB = C.BLB
    IF THE CONDITION IS NOT SATISFIED: C.FLB = P.FLB
    =#

    if length(ind.flb) == 0
        flb = 0
    elseif blb > ind.flb[end] || ind.input[end - 1].close < ind.flb[end]
        flb = blb
    else
        flb = ind.flb[end]
    end
    push!(ind.flb, flb)

    #=
    IF P.ST == P.FUB AND C.CLOSE < C.FUB: C.ST = C.FUB
    IF P.ST == P.FUB AND C.CLOSE > C.FUB: C.ST = C.FLB
    IF P.ST == P.FLB AND C.CLOSE > C.FLB: C.ST = C.FLB
    IF P.ST == P.FLB AND C.CLOSE < C.FLB: C.ST = C.FUB
    =#

    if !has_output_value(ind)
        supertrend = 0
    elseif ind.output[end].value == ind.fub[end - 1] && ind.input[end].close <= ind.fub[end]
        supertrend = ind.fub[end]
    elseif ind.output[end].value == ind.fub[end - 1] && ind.input[end].close > ind.fub[end]
        supertrend = ind.flb[end]
    elseif ind.output[end].value == ind.flb[end - 1] && ind.input[end].close >= ind.flb[end]
        supertrend = ind.flb[end]
    elseif ind.output[end].value == ind.flb[end - 1] && ind.input[end].close < ind.flb[end]
        supertrend = ind.fub[end]
    end

    trend_dir = ind.input[end].close > supertrend ? Trend.UP : Trend.DOWN

    out_val = SuperTrendVal(supertrend, trend_dir)

    push!(ind.output, out_val)
    return out_val
end
