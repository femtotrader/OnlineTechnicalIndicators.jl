const VTX_PERIOD = 14

struct VTXVal{Tval}
    plus_vtx::Tval
    minus_vtx::Tval
end

"""
    VTC{Tohlcv,S}(; period = VTX_PERIOD, input_filter = always_true, input_modifier = identity, input_modifier_return_type = Tohlcv)

The `VTX` type implements a Vortex Indicator.
"""
mutable struct VTX{Tohlcv,S} <: TechnicalIndicator{Tohlcv}
    value::Union{Missing,VTXVal}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    period::Integer

    sub_indicators::Series
    atr::ATR

    atr_values::CircBuff

    plus_vm::CircBuff
    minus_vm::CircBuff

    input_modifier::Function
    input_filter::Function
    input_values::CircBuff

    function VTX{Tohlcv,S}(;
        period = VTX_PERIOD,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv,S}
        @warn "WIP - buggy"
        T2 = input_modifier_return_type
        atr = ATR{T2,S}(period = 1)
        sub_indicators = Series(atr)
        atr_values = CircBuff(Union{Missing,S}, period, rev = false)
        plus_vm = CircBuff(S, period, rev = false)
        minus_vm = CircBuff(S, period, rev = false)
        input_values = CircBuff(T2, 2, rev = false)
        output_listeners = Series()
        input_indicator = missing
        new{Tohlcv,S}(
            initialize_indicator_common_fields()...,
            period,
            sub_indicators,
            atr,
            atr_values,
            plus_vm,
            minus_vm,
            input_modifier,
            input_filter,
            input_values,
        )
    end
end

function _calculate_new_value(ind::VTX)
    fit!(ind.atr_values, value(ind.atr))

    if ind.n < 2
        return missing
    end

    candle = ind.input_values[end]
    candle_prev = ind.input_values[end-1]

    fit!(ind.plus_vm, abs(candle.high - candle_prev.low))
    fit!(ind.minus_vm, abs(candle.low - candle_prev.high))

    if length(ind.atr_values) < ind.period ||
       length(ind.plus_vm) < ind.period ||
       length(ind.minus_vm) < ind.period
        return missing
    end
    atr_sum = sum(value(ind.atr_values))
    return VTXVal(sum(value(ind.plus_vm)) / atr_sum, sum(value(ind.minus_vm)) / atr_sum)
end
