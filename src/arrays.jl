module ArraysInterface

using IncTA
using IncTA: TechnicalIndicator

function apply_func(arr::AbstractArray, IND::Type{I}, args...; kwargs...) where {I <: TechnicalIndicator}
    ind = IND{eltype(arr)}(; kwargs...)
    mapped = map(val -> value(fit!(ind, val)), arr)
    return collect(mapped)
end

# SISO indicators

SMA(x::AbstractArray, args...; kwargs...) = apply_func(x, IncTA.SMA, args...; kwargs...)

EMA(x::AbstractArray, args...; kwargs...) = apply_func(x, IncTA.EMA, args...; kwargs...)

SMMA(x::AbstractArray, args...; kwargs...) = apply_func(x, IncTA.SMMA, args...; kwargs...)

RSI(x::AbstractArray, args...; kwargs...) = apply_func(x, IncTA.RSI, args...; kwargs...)

MeanDev(x::AbstractArray, args...; kwargs...) = apply_func(x, IncTA.MeanDev, args...; kwargs...)

StdDev(x::AbstractArray, args...; kwargs...) = apply_func(x, IncTA.StdDev, args...; kwargs...)

ROC(x::AbstractArray, args...; kwargs...) = apply_func(x, IncTA.ROC, args...; kwargs...)

WMA(x::AbstractArray, args...; kwargs...) = apply_func(x, IncTA.WMA, args...; kwargs...)

KAMA(x::AbstractArray, args...; kwargs...) = apply_func(x, IncTA.KAMA, args...; kwargs...)

HMA(x::AbstractArray, args...; kwargs...) = apply_func(x, IncTA.HMA, args...; kwargs...)

DPO(x::AbstractArray, args...; kwargs...) = apply_func(x, IncTA.DPO, args...; kwargs...)

CoppockCurve(x::AbstractArray, args...; kwargs...) = apply_func(x, IncTA.CoppockCurve, args...; kwargs...)

DEMA(x::AbstractArray, args...; kwargs...) = apply_func(x, IncTA.DEMA, args...; kwargs...)

TEMA(x::AbstractArray, args...; kwargs...) = apply_func(x, IncTA.TEMA, args...; kwargs...)

ALMA(x::AbstractArray, args...; kwargs...) = apply_func(x, IncTA.ALMA, args...; kwargs...)

McGinleyDynamic(x::AbstractArray, args...; kwargs...) = apply_func(x, IncTA.McGinleyDynamic, args...; kwargs...)

ZLEMA(x::AbstractArray, args...; kwargs...) = apply_func(x, IncTA.ZLEMA, args...; kwargs...)

T3(x::AbstractArray, args...; kwargs...) = apply_func(x, IncTA.T3, args...; kwargs...)

TRIX(x::AbstractArray, args...; kwargs...) = apply_func(x, IncTA.TRIX, args...; kwargs...)

TSI(x::AbstractArray, args...; kwargs...) = apply_func(x, IncTA.TSI, args...; kwargs...)

# SIMO indicators
# MISO indicators
# MIMO indicators

end