const CoppockCurve_FAST_ROC_PERIOD = 11
const CoppockCurve_SLOW_ROC_PERIOD = 14
const CoppockCurve_WMA_PERIOD = 10

"""
    CoppockCurve{T}(; fast_roc_period = CoppockCurve_FAST_ROC_PERIOD, slow_roc_period = CoppockCurve_SLOW_ROC_PERIOD, wma_period = CoppockCurve_WMA_PERIOD)

The `CoppockCurve` type implements a Coppock Curve indicator.
"""
mutable struct CoppockCurve{Tval} <: TechnicalIndicator{Tval}
    value::Union{Missing,Tval}
    n::Int

    sub_indicators::Series
    fast_roc::ROC
    slow_roc::ROC

    wma::WMA{Tval}

    function CoppockCurve{Tval}(;
        fast_roc_period = CoppockCurve_FAST_ROC_PERIOD,
        slow_roc_period = CoppockCurve_SLOW_ROC_PERIOD,
        wma_period = CoppockCurve_WMA_PERIOD,
    ) where {Tval}
        fast_roc = ROC{Tval}(period = fast_roc_period)
        slow_roc = ROC{Tval}(period = slow_roc_period)
        sub_indicators = Series(fast_roc, slow_roc)
        wma = WMA{Tval}(period = wma_period)
        new{Tval}(missing, 0, sub_indicators, fast_roc, slow_roc, wma)
    end
end

function OnlineStatsBase._fit!(ind::CoppockCurve, data)
    fit!(ind.sub_indicators, data)
    # fit!(ind.slow_roc, data)
    # fit!(ind.fast_roc, data)
    # fast_roc, slow_roc = ind.sub_indicators.stats
    if ind.n != ind.slow_roc.period
        ind.n += 1
    end
    if has_output_value(ind.fast_roc) && has_output_value(ind.slow_roc)
        fit!(ind.wma, value(ind.slow_roc) + value(ind.fast_roc))
        ind.value = value(ind.wma)
        if has_output_value(ind.wma)
            ind.value = value(ind.wma)
        else
            ind.value = missing
        end
    else
        ind.value = missing
    end
    return ind.value
end
