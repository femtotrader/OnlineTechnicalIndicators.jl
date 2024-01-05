const ParabolicSAR_INIT_ACCEL_FACTOR = 0.02
const ParabolicSAR_ACCEL_FACTOR_INC = 0.02
const ParabolicSAR_MAX_ACCEL_FACTOR = 0.2
const SAR_INIT_LEN = 5

module SARTrend
export TrendEnum
@enum TrendEnum UP DOWN
end # module

struct ParabolicSARVal{Tval}
    value::Tval
    trend::SARTrend.TrendEnum
    ep::Tval
    accel_factor::Tval
end

"""
    ParabolicSAR{Tohlcv,S}(; atr_period = ParabolicSAR_ATR_PERIOD, mult = ParabolicSAR_MULT, input_filter = always_true, input_modifier = identity, input_modifier_return_type = Tohlcv)

The `ParabolicSAR` type implements a Super Trend indicator.
"""
mutable struct ParabolicSAR{Tohlcv,IN,S} <: TechnicalIndicatorMultiOutput{Tohlcv}
    value::Union{Missing,ParabolicSARVal}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    init_accel_factor::S
    accel_factor_inc::S
    max_accel_factor::S

    input_modifier::Function
    input_filter::Function
    input_values::CircBuff

    function ParabolicSAR{Tohlcv}(;
        init_accel_factor = ParabolicSAR_INIT_ACCEL_FACTOR,
        accel_factor_inc = ParabolicSAR_ACCEL_FACTOR_INC,
        max_accel_factor = ParabolicSAR_MAX_ACCEL_FACTOR,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        S = fieldtype(T2, :close)
        input_values = CircBuff(T2, SAR_INIT_LEN, rev = false)
        new{Tohlcv,true,S}(
            initialize_indicator_common_fields()...,
            init_accel_factor,
            accel_factor_inc,
            max_accel_factor,
            input_modifier,
            input_filter,
            input_values,
        )
    end
end

function _calculate_new_value(ind::ParabolicSAR)
    if ind.n < SAR_INIT_LEN
        return missing
    elseif ind.n == SAR_INIT_LEN
        min_low = min((cdl.low for cdl in ind.input_values.value)...)
        max_high = max((cdl.high for cdl in ind.input_values.value)...)
        return ParabolicSARVal(min_low, SARTrend.UP, max_high, ind.init_accel_factor)
    else

        prev_sar = value(ind)

        new_sar_val =
            prev_sar.value + prev_sar.accel_factor * (prev_sar.ep - prev_sar.value)
        new_trend = prev_sar.trend
        new_ep = prev_sar.ep
        new_accel_factor = prev_sar.accel_factor

        candle = ind.input_values[end]
        candle_pm1 = ind.input_values[end-1]
        candle_pm2 = ind.input_values[end-2]

        # if new SAR overlaps last lows/highs (depending on the trend), cut it at that value
        if (prev_sar.trend == SARTrend.UP) &&
           (new_sar_val > min(candle_pm1.low, candle_pm2.low))
            new_sar_val = min(candle_pm1.low, candle_pm2.low)
        elseif (prev_sar.trend == SARTrend.DOWN) &&
               (new_sar_val < max(candle_pm1.high, candle_pm2.high))
            new_sar_val = max(candle_pm1.high, candle_pm2.high)
        end

        # update extreme point
        if prev_sar.trend == SARTrend.UP && candle.high > prev_sar.ep
            new_ep = candle.high
        elseif prev_sar.trend == SARTrend.DOWN && candle.low < prev_sar.ep
            new_ep = candle.low
        end

        # if extreme point was updated, increase acceleration factor
        if new_ep != prev_sar.ep
            new_accel_factor = new_accel_factor + ind.accel_factor_inc
            if new_accel_factor > ind.max_accel_factor
                new_accel_factor = ind.max_accel_factor
            end
        end

        # check if trend is reversed and initialize new initial values
        if prev_sar.trend == SARTrend.UP && new_sar_val > candle.low
            new_sar_val = max(prev_sar.ep, candle.high)
            new_ep = candle.low
            new_trend = SARTrend.DOWN
            new_accel_factor = ind.init_accel_factor
        elseif prev_sar.trend == SARTrend.DOWN && new_sar_val < candle.high
            new_sar_val = min(prev_sar.ep, candle.low)
            new_ep = candle.high
            new_trend = SARTrend.UP
            new_accel_factor = ind.init_accel_factor
        end

        return ParabolicSARVal(new_sar_val, new_trend, new_ep, new_accel_factor)
    end
end
