const VTX_PERIOD = 14

struct VTXVal{Tval}
    plus_vtx::Tval
    minus_vtx::Tval
end

"""
    VTC{Tohlcv,S}(; period = VTX_PERIOD)

The `VTX` type implements a Vortex Indicator.
"""
mutable struct VTX{Tohlcv,S} <: TechnicalIndicator{Tohlcv}
    value::Union{Missing,VTXVal}
    n::Int

    period::Integer

    sub_indicators::Series
    # atr::ATR
    atr_values::CircBuff

    plus_vm::CircBuff
    minus_vm::CircBuff

    input_values::CircBuff

    function VTX{Tohlcv,S}(; period = VTX_PERIOD) where {Tohlcv,S}
        @warn "WIP - buggy"
        atr = ATR{Tohlcv,S}(period = 1)
        atr_values = CircBuff(Union{Missing,S}, period, rev = false)
        plus_vm = CircBuff(S, period, rev = false)
        minus_vm = CircBuff(S, period, rev = false)
        input = CircBuff(Tohlcv, 2, rev = false)
        new{Tohlcv,S}(missing, 0, period, Series(atr), atr_values, plus_vm, minus_vm, input)
    end
end

function OnlineStatsBase._fit!(ind::VTX, candle)
    fit!(ind.input_values, candle)
    fit!(ind.sub_indicators, candle)
    atr, = ind.sub_indicators.stats
    fit!(ind.atr_values, value(atr))
    if ind.n < ind.period
        ind.n += 1
    end

    if ind.n < 2
        ind.value = missing
        return
    end

    # candle = ind.input_values[end]
    candle_prev = ind.input_values[end-1]

    fit!(ind.plus_vm, abs(candle.high - candle_prev.low))
    fit!(ind.minus_vm, abs(candle.low - candle_prev.high))

    if length(ind.atr_values) < ind.period ||
       length(ind.plus_vm) < ind.period ||
       length(ind.minus_vm) < ind.period
        ind.value = missing
        return
    end
    atr_sum = sum(value(ind.atr_values))
    ind.value =
        VTXVal(sum(value(ind.plus_vm)) / atr_sum, sum(value(ind.minus_vm)) / atr_sum)

end
