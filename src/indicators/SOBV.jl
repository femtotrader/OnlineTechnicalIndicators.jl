const SOBV_PERIOD = 20

"""
    SOBV{Tohlcv,S}(; period = SOBV_PERIOD, ma = SMA)

The SOBV type implements a Smoothed On Balance Volume indicator.
"""
mutable struct SOBV{Tohlcv,S} <: OnlineStat{Tohlcv}
    value::Union{Missing,S}
    n::Int

    period::Integer

    obv::OBV
    obv_ma::SMA

    function SOBV{Tohlcv,S}(; period = SOBV_PERIOD, ma = SMA) where {Tohlcv,S}
        obv = OBV{Tohlcv,S}()
        # obv_ma = SMA{S}(period = period)
        obv_ma = MAFactory(S)(ma, period)
        new{Tohlcv,S}(missing, 0, period, obv, obv_ma)
    end
end

function OnlineStatsBase._fit!(ind::SOBV, candle)
    fit!(ind.obv, candle)
    fit!(ind.obv_ma, value(ind.obv))
    ind.n += 1
    if has_output_value(ind.obv)
        ind.value = value(ind.obv_ma)
    else
        ind.value = missing
    end
end
