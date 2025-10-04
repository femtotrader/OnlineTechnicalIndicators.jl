const CoppockCurve_FAST_ROC_PERIOD = 11
const CoppockCurve_SLOW_ROC_PERIOD = 14
const CoppockCurve_WMA_PERIOD = 10

"""
    CoppockCurve{T}(; fast_roc_period = CoppockCurve_FAST_ROC_PERIOD, slow_roc_period = CoppockCurve_SLOW_ROC_PERIOD, wma_period = CoppockCurve_WMA_PERIOD, input_modifier_return_type = T)

The `CoppockCurve` type implements a Coppock Curve indicator.
"""
mutable struct CoppockCurve{Tval,IN,T2} <: TechnicalIndicatorSingleOutput{Tval}
    value::Union{Missing,T2}
    n::Int

    sub_indicators::Series
    fast_roc::ROC
    slow_roc::ROC

    wma::WMA

    function CoppockCurve{Tval}(;
        fast_roc_period = CoppockCurve_FAST_ROC_PERIOD,
        slow_roc_period = CoppockCurve_SLOW_ROC_PERIOD,
        wma_period = CoppockCurve_WMA_PERIOD,
        input_modifier_return_type = Tval) where {Tval}
        T2 = input_modifier_return_type
        fast_roc = ROC{T2}(period = fast_roc_period)
        slow_roc = ROC{T2}(period = slow_roc_period)
        sub_indicators = Series(fast_roc, slow_roc)
        wma = WMA{T2}(period = wma_period)
        new{Tval,false,T2}(
            missing,
            0,
            sub_indicators,
            fast_roc,
            slow_roc,
            wma)
    end
end

function CoppockCurve(;
    fast_roc_period = CoppockCurve_FAST_ROC_PERIOD,
    slow_roc_period = CoppockCurve_SLOW_ROC_PERIOD,
    wma_period = CoppockCurve_WMA_PERIOD,
    input_modifier_return_type = Float64)
    CoppockCurve{input_modifier_return_type}(;
        fast_roc_period=fast_roc_period,
        slow_roc_period=slow_roc_period,
        wma_period=wma_period,
        input_modifier_return_type=input_modifier_return_type)
end

function _calculate_new_value(ind::CoppockCurve)
    if has_output_value(ind.fast_roc) && has_output_value(ind.slow_roc)
        fit!(ind.wma, value(ind.slow_roc) + value(ind.fast_roc))
        if has_output_value(ind.wma)
            return value(ind.wma)
        else
            return missing
        end
    else
        return missing
    end
end
