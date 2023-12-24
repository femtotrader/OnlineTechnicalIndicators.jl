const CoppockCurve_FAST_ROC_PERIOD = 11
const CoppockCurve_SLOW_ROC_PERIOD = 14
const CoppockCurve_WMA_PERIOD = 10

"""
    CoppockCurve{T}(; period = CoppockCurve_PERIOD)

The CoppockCurve type implements a Coppock Curve indicator.
"""
mutable struct CoppockCurve{Tval} <: AbstractIncTAIndicator
    fast_roc::ROC{Tval}
    slow_roc::ROC{Tval}
    wma::WMA{Tval}

    value::CircularBuffer{Union{Missing,Tval}}

    function CoppockCurve{Tval}(;
        fast_roc_period = CoppockCurve_FAST_ROC_PERIOD,
        slow_roc_period = CoppockCurve_SLOW_ROC_PERIOD,
        wma_period = CoppockCurve_WMA_PERIOD,
    ) where {Tval}
        fast_roc = ROC{Tval}(period = fast_roc_period)
        slow_roc = ROC{Tval}(period = slow_roc_period)
        wma = WMA{Tval}(period = wma_period)
        value = CircularBuffer{Union{Missing,Tval}}(wma_period)
        new{Tval}(fast_roc, slow_roc, wma, value)
    end
end


function Base.push!(ind::CoppockCurve{Tval}, val::Tval) where {Tval}
    push!(ind.slow_roc, val)
    push!(ind.fast_roc, val)

    if !has_output_value(ind.fast_roc) || !has_output_value(ind.slow_roc)
        out_val = missing
        push!(ind.value, out_val)
        return out_val
    end

    push!(ind.wma, ind.slow_roc.value[end] + ind.fast_roc.value[end])

    if !has_output_value(ind.wma)
        out_val = missing
        push!(ind.value, out_val)
        return out_val
    else
        out_val = ind.wma.value[end]
        push!(ind.value, out_val)
        return out_val
    end
end
