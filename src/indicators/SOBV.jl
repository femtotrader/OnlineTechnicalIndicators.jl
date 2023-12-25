const SOBV_PERIOD = 20

"""
    SOBV{Tohlcv}(; period = SOBV_PERIOD)

The SOBV type implements a Smoothed On Balance Volume indicator.
"""
mutable struct SOBV{Tohlcv} <: OnlineStat{Tohlcv}
    value::Union{Missing,Float64}  # Tprice
    n::Int

    period::Integer

    obv::OBV
    sma_obv::SMA

    function SOBV{Tohlcv}(; period = SOBV_PERIOD) where {Tohlcv}
        obv = OBV{Tohlcv}()
        sma_obv = SMA{Float64}(period = period)
        new{Tohlcv}(missing, 0, period, obv, sma_obv)
    end
end

function OnlineStatsBase._fit!(ind::SOBV, candle::OHLCV)
    fit!(ind.obv, candle)
    fit!(ind.sma_obv, value(ind.obv))
    ind.n += 1
    if has_output_value(ind.obv)
        ind.value = value(ind.sma_obv)
    else
        ind.value = missing
    end
end
