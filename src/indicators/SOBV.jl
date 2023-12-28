const SOBV_PERIOD = 20

"""
    SOBV{Tohlcv,S}(; period = SOBV_PERIOD, ma = SMA)

The SOBV type implements a Smoothed On Balance Volume indicator.
"""
mutable struct SOBV{Tohlcv,S} <: TechnicalIndicator{Tohlcv}
    value::Union{Missing,S}
    n::Int

    period::Integer

    sub_indicators::Series
    # obv::OBV
    obv_ma::SMA

    function SOBV{Tohlcv,S}(; period = SOBV_PERIOD, ma = SMA) where {Tohlcv,S}
        obv = OBV{Tohlcv,S}()
        # obv_ma = SMA{S}(period = period)
        obv_ma = MAFactory(S)(ma, period)
        sub_indicators = Series(obv)
        new{Tohlcv,S}(missing, 0, period, sub_indicators, obv_ma)
    end
end

function OnlineStatsBase._fit!(ind::SOBV, candle)
    fit!(ind.sub_indicators, candle)
    obv, = ind.sub_indicators.stats
    fit!(ind.obv_ma, value(obv))
    ind.n += 1
    if has_output_value(ind.obv_ma)
        ind.value = value(ind.obv_ma)
    else
        ind.value = missing
    end
end
