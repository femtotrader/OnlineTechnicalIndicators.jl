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
    KeltnerChannels{Tohlcv,S}(; ma_period = KeltnerChannels_MA_PERIOD, atr_period = KeltnerChannels_ATR_PERIOD, atr_mult_up = KeltnerChannels_ATR_MULT_UP, atr_mult_down = KeltnerChannels_ATR_MULT_DOWN, ma = EMA)

The KeltnerChannels type implements a Keltner Channels indicator.
"""
mutable struct KeltnerChannels{Tohlcv,S} <: TechnicalIndicator{Tohlcv}
    value::Union{Missing,KeltnerChannelsVal{S}}
    n::Int

    ma_period::Integer
    atr_period::Integer
    atr_mult_up::S
    atr_mult_down::S

    sub_indicators::Series
    # atr::ATR
    # cb  # EMA default

    function KeltnerChannels{Tohlcv,S}(;
        ma_period = KeltnerChannels_MA_PERIOD,
        atr_period = KeltnerChannels_ATR_PERIOD,
        atr_mult_up = KeltnerChannels_ATR_MULT_UP,
        atr_mult_down = KeltnerChannels_ATR_MULT_DOWN,
        ma = EMA,
    ) where {Tohlcv,S}
        atr = ATR{Tohlcv,S}(period = atr_period)
        # cb = EMA{S}(period = ma_period)
        _cb = MAFactory(S)(ma, ma_period)
        _cb = FilterTransform(_cb, Tohlcv, transform = candle -> candle.close)  # ValueExtractor is reference implementation
        sub_indicators = Series(atr, _cb)
        new{Tohlcv,S}(
            missing,
            0,
            ma_period,
            atr_period,
            atr_mult_up,
            atr_mult_down,
            sub_indicators,
        )
    end
end

function OnlineStatsBase._fit!(ind::KeltnerChannels, candle)
    fit!(ind.sub_indicators, candle)
    atr, cb = ind.sub_indicators.stats
    #fit!(ind.atr, candle)
    #fit!(ind.cb, candle)  # FilterTransform ie something like a ValueExtractor should be implemented taking a function like candle->candle.close as argument
    # fit!(ind.cb, candle.close)
    ind.n += 1
    if has_output_value(atr) && has_output_value(cb)
        ind.value = KeltnerChannelsVal(
            value(cb) - ind.atr_mult_down * value(atr),
            value(cb),
            value(cb) + ind.atr_mult_up * value(atr),
        )
    else
        ind.value = missing
    end
end
