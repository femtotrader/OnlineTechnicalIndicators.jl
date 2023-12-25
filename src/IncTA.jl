module IncTA

export OHLCV, OHLCVFactory
export fit!

export SampleData

export Memory

# simple indicators
export SMA
export EMA
export SMMA
export RSI
export MeanDev
export StdDev
export ROC
export WMA
export BB
export KST
export KAMA
export HMA
export DPO
export CoppockCurve
export MACD
export DEMA
export ALMA

# OHLCV indicators
export VWMA
export VWAP
export AO
export ATR
export AccuDist
export BOP
export ForceIndex
export OBV
export SOBV
export EMV
export CCI
export ChaikinOsc
export MassIndex
export CHOP
export SuperTrend, Trend
export Stoch

using DataStructures
using OnlineStatsBase

abstract type AbstractIncTAIndicator end

include("ohlcv.jl")
include("sample_data.jl")

function has_output_value(ind::T) where {T<:AbstractIncTAIndicator}
    if length(ind.value) == 0
        return false
    else
        if ismissing(ind.value[end])
            return false
        else
            return true
        end
    end
end

#=
function fit!(ind::T, values::Vector) where {T<:AbstractIncTAIndicator}
    for value in values
        push!(ind, value)
    end
end
=#

include("indicators/SMA.jl")
include("indicators/EMA.jl")
include("indicators/SMMA.jl")
include("indicators/RSI.jl")
include("indicators/MeanDev.jl")
include("indicators/StdDev.jl")
include("indicators/ROC.jl")
include("indicators/WMA.jl")
include("indicators/BB.jl")
include("indicators/KST.jl")
include("indicators/KAMA.jl")
include("indicators/HMA.jl")
include("indicators/DPO.jl")
include("indicators/CoppockCurve.jl")
include("indicators/MACD.jl")
include("indicators/DEMA.jl")
include("indicators/ALMA.jl")

include("indicators/VWMA.jl")
include("indicators/VWAP.jl")
include("indicators/AO.jl")
include("indicators/ATR.jl")
include("indicators/AccuDist.jl")
include("indicators/BOP.jl")
include("indicators/ForceIndex.jl")
include("indicators/OBV.jl")
include("indicators/SOBV.jl")
include("indicators/EMV.jl")
include("indicators/CCI.jl")
include("indicators/ChaikinOsc.jl")
include("indicators/MassIndex.jl")
include("indicators/CHOP.jl")
include("indicators/SuperTrend.jl")
include("indicators/Stoch.jl")
end
