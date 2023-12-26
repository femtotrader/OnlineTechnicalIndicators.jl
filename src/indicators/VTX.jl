const VTX_PERIOD = 14

struct VTXVal{Tval}
    plus_vtx::Tval
    minus_vtx::Tval
end

"""
    VTC{Tohlcv}(; period = VTX_PERIOD)

The VTX type implements a Vortex Indicator.
"""
mutable struct VTX{Tohlcv} <: OnlineStat{Tohlcv}
    value::Union{Missing,VTXVal}
    n::Int

    period::Integer

    atr::ATR  # Tohlcv
    atr_values::CircBuff

    plus_vm::CircBuff
    minus_vm::CircBuff

    input::CircBuff

    function VTX{Tohlcv}(; period = VTX_PERIOD) where {Tohlcv}
        @warn "WIP - buggy"
        atr = ATR{Tohlcv}(period = 1)
        Tprice = Float64
        atr_values = CircBuff(Union{Missing,Tprice}, period, rev = false)
        plus_vm = CircBuff(Tprice, period, rev = false)
        minus_vm = CircBuff(Tprice, period, rev = false)
        input = CircBuff(Tohlcv, 2, rev = false)
        new{Tohlcv}(missing, 0, period, atr, atr_values, plus_vm, minus_vm, input)
    end
end

function OnlineStatsBase._fit!(ind::VTX, candle::OHLCV)
    fit!(ind.input, candle)
    fit!(ind.atr, candle)
    fit!(ind.atr_values, value(ind.atr))
    if ind.n < ind.period
        ind.n += 1
    end

    if ind.n < 2
        ind.value = missing
        return
    end

    # candle = ind.input[end]
    candle_prev = ind.input[end-1]

    fit!(ind.plus_vm, abs(candle.high - candle_prev.low))
    fit!(ind.minus_vm, abs(candle.low - candle_prev.high))

    if length(ind.atr_values) < ind.period || length(ind.plus_vm) < ind.period || length(ind.minus_vm) < ind.period
        ind.value = missing
        return
    end
    atr_sum = sum(value(ind.atr_values))
    ind.value = VTXVal(sum(value(ind.plus_vm)) / atr_sum, sum(value(ind.minus_vm)) / atr_sum)

end
