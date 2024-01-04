const ChandeKrollStop_ATR_PERIOD = 5
const ChandeKrollStop_ATR_MULT = 2.0
const ChandeKrollStop_PERIOD = 3

struct ChandeKrollStopVal{Tval}
    short_stop::Tval
    long_stop::Tval
end

"""
    ChandeKrollStop{Tohlcv,S}(; atr_period = ChandeKrollStop_ATR_PERIOD, atr_mult = ChandeKrollStop_ATR_MULT, period = ChandeKrollStop_PERIOD, input_filter = always_true, input_modifier = identity, input_modifier_return_type = Tohlcv)

The `ChandeKrollStop` type implements a ChandeKrollStop indicator.
"""
mutable struct ChandeKrollStop{Tohlcv,S} <: TechnicalIndicator{Tohlcv}
    value::Union{Missing,ChandeKrollStopVal}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    atr_period::Integer
    atr_mult::S
    period::Integer

    sub_indicators::Series
    atr::ATR

    high_stop_list::CircBuff
    low_stop_list::CircBuff

    input_modifier::Function
    input_filter::Function
    input_values::CircBuff

    function ChandeKrollStop{Tohlcv}(;
        atr_period = ChandeKrollStop_ATR_PERIOD,
        atr_mult = ChandeKrollStop_ATR_MULT,
        period = ChandeKrollStop_PERIOD,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        S = fieldtype(T2, :close)
        input_values = CircBuff(T2, atr_period, rev = false)
        atr = ATR{T2}(period = atr_period)
        sub_indicators = Series(atr)
        high_stop_list = CircBuff(S, period, rev = false)
        low_stop_list = CircBuff(S, period, rev = false)
        new{Tohlcv,S}(
            initialize_indicator_common_fields()...,
            atr_period,
            atr_mult,
            period,
            sub_indicators,
            atr,
            high_stop_list,
            low_stop_list,
            input_modifier,
            input_filter,
            input_values,
        )
    end
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
