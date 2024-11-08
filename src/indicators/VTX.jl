const VTX_PERIOD = 14

struct VTXVal{Tval}
    plus_vtx::Tval
    minus_vtx::Tval
end

"""
    VTX{Tohlcv}(; period = VTX_PERIOD, input_filter = always_true, input_modifier = identity, input_modifier_return_type = Tohlcv)

The `VTX` type implements a Vortex Indicator.
"""
mutable struct VTX{Tohlcv,IN,S} <: TechnicalIndicatorMultiOutput{Tohlcv}
    value::Union{Missing,VTXVal}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    period::Integer

    sub_indicators::Series
    tr::TrueRange

    tr_values::CircBuff

    plus_vm::CircBuff
    minus_vm::CircBuff

    input_modifier::Function
    input_filter::Function
    input_values::CircBuff

    function VTX{Tohlcv}(;
        period = VTX_PERIOD,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        S = fieldtype(T2, :close)
        tr = TrueRange{T2}()
        sub_indicators = Series(tr)
        tr_values = CircBuff(Union{Missing,S}, period, rev = false)
        plus_vm = CircBuff(S, period, rev = false)
        minus_vm = CircBuff(S, period, rev = false)
        input_values = CircBuff(T2, 2, rev = false)
        new{Tohlcv,true,S}(
            initialize_indicator_common_fields()...,
            period,
            sub_indicators,
            tr,
            tr_values,
            plus_vm,
            minus_vm,
            input_modifier,
            input_filter,
            input_values,
        )
    end
end

function _calculate_new_value(ind::VTX)
    _atr_value = value(ind.tr)
    fit!(ind.tr_values, _atr_value)
    if ind.n > 1
        candle = ind.input_values[end]
        candle_prev = ind.input_values[end-1]
        fit!(ind.plus_vm, abs(candle.high - candle_prev.low))
        fit!(ind.minus_vm, abs(candle.low - candle_prev.high))
        if !has_valid_values(ind.tr_values, ind.period) ||
           !has_valid_values(ind.plus_vm, ind.period) ||
           !has_valid_values(ind.minus_vm, ind.period)
            return missing
        end
        atr_sum = sum(value(ind.tr_values))
        return VTXVal(sum(value(ind.plus_vm)) / atr_sum, sum(value(ind.minus_vm)) / atr_sum)
    else
        return missing
    end
end
