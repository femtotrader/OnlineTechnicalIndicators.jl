module IncTA

export OHLCV, OHLCVFactory

# simple indicators
export SMA, SMA_v2, SMA_v3
export EMA
export SMMA
export RSI
export MeanDev
export StdDev
export ROC
export WMA
export BB
export KAMA  # ToFix
export HMA
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
export CCI
export MassIndex
export CHOP
export SuperTrend, Trend

using DataStructures
using OnlineStats

abstract type AbstractIncTAIndicator end

include("ohlcv.jl")

function has_output_value(ind::T) where {T<:AbstractIncTAIndicator}
    if length(ind.output) == 0
        return false
    else
        if ismissing(ind.output[end])
            return false
        else
            return true
        end
    end
end

function Base.append!(ind::T, values::Vector) where {T<:AbstractIncTAIndicator}
    for value in values
        push!(ind, value)
    end
end

include("indicators/SMA.jl")
include("indicators/EMA.jl")
include("indicators/SMMA.jl")
include("indicators/RSI.jl")
include("indicators/MeanDev.jl")
include("indicators/StdDev.jl")
include("indicators/ROC.jl")
include("indicators/WMA.jl")
include("indicators/BB.jl")
include("indicators/KAMA.jl")
include("indicators/HMA.jl")
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
include("indicators/CCI.jl")
include("indicators/MassIndex.jl")
include("indicators/CHOP.jl")
include("indicators/SuperTrend.jl")
end
