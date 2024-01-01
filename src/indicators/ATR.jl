const ATR_PERIOD = 3

"""
    ATR{Tohlcv,S}(; period = ATR_PERIOD, input_filter = always_true, input_modifier = identity, input_modifier_return_type = Tohlcv)

The `ATR` type implements an Average True Range indicator.
"""
mutable struct ATR{Tohlcv,S} <: TechnicalIndicator{Tohlcv}
    value::Union{Missing,S}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    period::Number

    tr::CircBuff
    rolling::Bool

    input_modifier::Function
    input_filter::Function
    input_values::CircBuff

    function ATR{Tohlcv,S}(;
        period = ATR_PERIOD,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv,S}
        T2 = input_modifier_return_type
        tr = CircBuff(S, period, rev = false)
        input_values = CircBuff(T2, period, rev = false)
        new{Tohlcv,S}(
            initialize_indicator_common_fields()...,
            period,
            tr,
            false,
            input_modifier,
            input_filter,
            input_values,
        )
    end
end

function _calculate_new_value(ind::ATR)
    candle = ind.input_values[end]
    true_range = candle.high - candle.low
    if ind.n != 1
        close2 = ind.input_values[end-1].close
        fit!(ind.tr, max(true_range, abs(candle.high - close2), abs(candle.low - close2)))
        if ind.rolling  # CircBuff is full and rolling
            return (value(ind) * (ind.period - 1) + ind.tr[end]) / ind.period
        else
            if ind.n == ind.period  # CircBuff is full but not rolling
                ind.rolling = true
                return sum(value(ind.tr)) / ind.period
            else   # CircBuff is filling up
                return missing
            end
        end
    else
        fit!(ind.tr, true_range)
        return missing
    end
end
