const MassIndex_EMA_PERIOD = 9
const MassIndex_EMA_EMA_PERIOD = 9
const MassIndex_EMA_RATIO_PERIOD = 10


"""
    MassIndex{T,S}(; ema_period = MassIndex_EMA_PERIOD, ema_ema_period = MassIndex_EMA_EMA_PERIOD, ema_ratio_period = MassIndex_EMA_RATIO_PERIOD)

The MassIndex type implements a Commodity Channel Index.
"""
mutable struct MassIndex{Tohlcv,S} <: OnlineStat{Tohlcv}
    value::Union{Missing,S}
    n::Int

    ema_ratio_period::Integer

    ema::EMA{S}
    ema_ema::EMA{S}
    ema_ratio::CircBuff{S}

    function MassIndex{Tohlcv,S}(;
        ema_period = MassIndex_EMA_PERIOD,
        ema_ema_period = MassIndex_EMA_EMA_PERIOD,
        ema_ratio_period = MassIndex_EMA_RATIO_PERIOD,
    ) where {Tohlcv,S}
        ema = EMA{S}(period = ema_period)
        ema_ema = EMA{S}(period = ema_ema_period)
        ema_ratio = CircBuff(S, ema_ratio_period, rev = false)
        new{Tohlcv,S}(missing, 0, ema_ratio_period, ema, ema_ema, ema_ratio)
    end
end

function OnlineStatsBase._fit!(ind::MassIndex, candle::OHLCV)
    fit!(ind.ema, candle.high - candle.low)
    ind.n += 1

    if !has_output_value(ind.ema)
        ind.value = missing
        return
    end

    fit!(ind.ema_ema, value(ind.ema))

    if !has_output_value(ind.ema_ema)
        ind.value = missing
        return
    end

    fit!(ind.ema_ratio, value(ind.ema) / value(ind.ema_ema))

    if length(ind.ema_ratio) < ind.ema_ratio_period
        ind.value = missing
        return
    end

    ind.value = sum(value(ind.ema_ratio))
end
