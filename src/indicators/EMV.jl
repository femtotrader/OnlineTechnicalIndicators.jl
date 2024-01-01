const EMV_PERIOD = 20
const EMV_VOLUME_DIV = 10000

"""
    EMV{Tohlcv,S}(; period = EMV_PERIOD, volume_div = EMV_VOLUME_DIV, ma = SMA, input_filter = always_true, input_modifier = identity, input_modifier_return_type = Tohlcv)

The `EMV` type implements a Ease of Movement indicator.
"""
mutable struct EMV{Tohlcv,S} <: TechnicalIndicator{Tohlcv}
    value::Union{Missing,S}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    period::Integer
    volume_div::Integer

    emv_ma::MovingAverageIndicator  # SMA

    input_modifier::Function
    input_filter::Function
    input_values::CircBuff

    function EMV{Tohlcv,S}(;
        period = EMV_PERIOD,
        volume_div = EMV_VOLUME_DIV,
        ma = SMA,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv,S}
        T2 = input_modifier_return_type
        _emv_ma = MAFactory(S)(ma, period = period)
        input_values = CircBuff(T2, period, rev = false)
        new{Tohlcv,S}(
            initialize_indicator_common_fields()...,
            period,
            volume_div,
            _emv_ma,
            input_modifier,
            input_filter,
            input_values,
        )
    end
end

function _calculate_new_value(ind::EMV)
    if ind.n >= 2
        candle = ind.input_values[end]
        candle_prev = ind.input_values[end-1]
        if candle.high != candle.low
            distance =
                ((candle.high + candle.low) / 2) -
                ((candle_prev.high + candle_prev.low) / 2)
            box_ratio = (candle.volume / ind.volume_div / (candle.high - candle.low))
            emv = distance / box_ratio
        else
            emv = 0.0
        end

        fit!(ind.emv_ma, emv)

        if length(ind.emv_ma.value) >= 1
            return value(ind.emv_ma)
        else
            return missing
        end
    else
        return missing
    end
end
