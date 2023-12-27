const SOBV_PERIOD = 20

"""
    SOBV{Tohlcv,S}(; period = SOBV_PERIOD)

The SOBV type implements a Smoothed On Balance Volume indicator.
"""
mutable struct SOBV{Tohlcv,S} <: OnlineStat{Tohlcv}
    value::Union{Missing,S}
    n::Int

    period::Integer

    obv::OBV
    sma_obv::SMA

    function SOBV{Tohlcv,S}(; period = SOBV_PERIOD) where {Tohlcv,S}
        obv = OBV{Tohlcv,S}()
        sma_obv = SMA{S}(period = period)
        new{Tohlcv,S}(missing, 0, period, obv, sma_obv)
    end
end

function OnlineStatsBase._fit!(ind::SOBV, candle)
    fit!(ind.obv, candle)
    fit!(ind.sma_obv, value(ind.obv))
    ind.n += 1
    if has_output_value(ind.obv)
        ind.value = value(ind.sma_obv)
    else
        ind.value = missing
    end
end
