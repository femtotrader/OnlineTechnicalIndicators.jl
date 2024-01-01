const KeltnerChannels_MA_PERIOD = 10
const KeltnerChannels_ATR_PERIOD = 10
const KeltnerChannels_ATR_MULT_UP = 2.0
const KeltnerChannels_ATR_MULT_DOWN = 3.0


struct KeltnerChannelsVal{Tval}
    lower::Tval
    central::Tval
    upper::Tval
end

"""
    KeltnerChannels{Tohlcv,S}(; ma_period = KeltnerChannels_MA_PERIOD, atr_period = KeltnerChannels_ATR_PERIOD, atr_mult_up = KeltnerChannels_ATR_MULT_UP, atr_mult_down = KeltnerChannels_ATR_MULT_DOWN, ma = EMA, input_filter = always_true, input_modifier = identity, input_modifier_return_type = Tohlcv)

The `KeltnerChannels` type implements a Keltner Channels indicator.
"""
mutable struct KeltnerChannels{Tohlcv,S} <: TechnicalIndicator{Tohlcv}
    value::Union{Missing,KeltnerChannelsVal{S}}
    n::Int

    output_listeners::Series

    ma_period::Integer
    atr_period::Integer
    atr_mult_up::S
    atr_mult_down::S

    sub_indicators::Series
    atr::ATR
    cb::MovingAverageIndicator  # EMA default

    input_modifier::Function
    input_filter::Function
    input_indicator::Union{Missing,TechnicalIndicator}

    function KeltnerChannels{Tohlcv,S}(;
        ma_period = KeltnerChannels_MA_PERIOD,
        atr_period = KeltnerChannels_ATR_PERIOD,
        atr_mult_up = KeltnerChannels_ATR_MULT_UP,
        atr_mult_down = KeltnerChannels_ATR_MULT_DOWN,
        ma = EMA,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv,S}
        T2 = input_modifier_return_type
        atr = ATR{T2,S}(period = atr_period)
        _cb = MAFactory(S)(
            ma,
            period = ma_period,
            input_modifier = ValueExtractor.extract_close,
        )
        sub_indicators = Series(atr, _cb)
        output_listeners = Series()
        input_indicator = missing
        new{Tohlcv,S}(
            missing,
            0,
            output_listeners,
            ma_period,
            atr_period,
            atr_mult_up,
            atr_mult_down,
            sub_indicators,
            atr,
            _cb,
            input_modifier,
            input_filter,
            input_indicator,
        )
    end
end

function _calculate_new_value(ind::KeltnerChannels)
    if has_output_value(ind.atr) && has_output_value(ind.cb)
        return KeltnerChannelsVal(
            value(ind.cb) - ind.atr_mult_down * value(ind.atr),
            value(ind.cb),
            value(ind.cb) + ind.atr_mult_up * value(ind.atr),
        )
    else
        return missing
    end
end
