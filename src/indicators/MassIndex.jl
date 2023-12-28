const MassIndex_MA_PERIOD = 9
const MassIndex_MA_MA_PERIOD = 9
const MassIndex_MA_RATIO_PERIOD = 10


"""
    MassIndex{T,S}(; ma_period = MassIndex_MA_PERIOD, ma_ma_period = MassIndex_MA_MA_PERIOD, ma_ratio_period = MassIndex_MA_RATIO_PERIOD, ma = EMA)

The MassIndex type implements a Commodity Channel Index.
"""
mutable struct MassIndex{Tohlcv,S} <: TechnicalIndicator{Tohlcv}
    value::Union{Missing,S}
    n::Int

    ma_ratio_period::Integer

    sub_indicators::Series
    #ma  # EMA
    ma_ma::Any  # EMA
    ma_ratio::CircBuff{S}

    function MassIndex{Tohlcv,S}(;
        ma_period = MassIndex_MA_PERIOD,
        ma_ma_period = MassIndex_MA_MA_PERIOD,
        ma_ratio_period = MassIndex_MA_RATIO_PERIOD,
        ma = EMA,
    ) where {Tohlcv,S}
        # ma = EMA{S}(period = ma_period)
        _ma = MAFactory(S)(ma, ma_period)
        sub_indicators = Series(_ma)
        # ma_ma = EMA{S}(period = ma_ma_period)
        _ma_ma = MAFactory(S)(ma, ma_ma_period)
        _ma_ratio = CircBuff(S, ma_ratio_period, rev = false)
        new{Tohlcv,S}(missing, 0, ma_ratio_period, sub_indicators, _ma_ma, _ma_ratio)
    end
end

function OnlineStatsBase._fit!(ind::MassIndex, candle)
    ma, = ind.sub_indicators.stats
    fit!(ma, candle.high - candle.low)
    ind.n += 1

    if !has_output_value(ma)
        ind.value = missing
        return
    end

    fit!(ind.ma_ma, value(ma))

    if !has_output_value(ind.ma_ma)
        ind.value = missing
        return
    end

    fit!(ind.ma_ratio, value(ma) / value(ind.ma_ma))

    if length(ind.ma_ratio) < ind.ma_ratio_period
        ind.value = missing
        return
    end

    ind.value = sum(value(ind.ma_ratio))
end
