const SFX_ATR_PERIOD = 12
const SFX_STD_DEV_PERIOD = 12
const SFX_STD_DEV_SMOOTHING_PERIOD = 3

struct SFXVal{Tval}
    atr::Union{Missing,Tval}
    std_dev::Tval
    ma_std_dev::Union{Missing,Tval}
end

"""
    SFX{Tohlcv,S}(; atr_period = SFX_ATR_PERIOD, std_dev_period = SFX_STD_DEV_PERIOD, std_dev_smoothing_period = SFX_STD_DEV_SMOOTHING_PERIOD, ma = SMA)

The `SFX` type implements a SFX indicator.
"""
mutable struct SFX{Tohlcv,S} <: TechnicalIndicator{Tohlcv}
    value::Union{Missing,SFXVal}
    n::Int

    sub_indicators::Series
    atr::ATR
    std_dev::FilterTransform  # StdDev

    ma_std_dev::MovingAverageIndicator

    function SFX{Tohlcv,S}(;
        atr_period = SFX_ATR_PERIOD,
        std_dev_period = SFX_STD_DEV_PERIOD,
        std_dev_smoothing_period = SFX_STD_DEV_SMOOTHING_PERIOD,
        ma = SMA,
    ) where {Tohlcv,S}
        atr = ATR{Tohlcv,S}(period = atr_period)
        std_dev = StdDev{Float64}(period = std_dev_period)
        std_dev = FilterTransform(std_dev, Tohlcv, transform = candle -> candle.close)
        sub_indicators = Series(atr, std_dev)
        ma_std_dev = MAFactory(S)(ma, std_dev_smoothing_period)
        new{Tohlcv,S}(missing, 0, sub_indicators, atr, std_dev, ma_std_dev)
    end
end

function OnlineStatsBase._fit!(ind::SFX, candle)
    fit!(ind.sub_indicators, candle)
    ind.n += 1
    #atr, std_dev = ind.sub_indicators.stats

    if has_output_value(ind.std_dev)
        fit!(ind.ma_std_dev, value(ind.std_dev))
    end

    _atr = value(ind.atr)
    _std_dev = value(ind.std_dev)
    _ma_std_dev = value(ind.ma_std_dev)

    ind.value = SFXVal(_atr, _std_dev, _ma_std_dev)
end
