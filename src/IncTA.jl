module IncTA

export OHLCV, OHLCVFactory
export fit!

export SampleData

# simple indicators (single input)
## single output => SISO
export SMA
export EMA
export SMMA
export RSI
export MeanDev
export StdDev
export ROC
export WMA
export HMA
export DPO
export CoppockCurve
export DEMA
export TEMA
export KAMA
export ALMA
export McGinleyDynamic
# simple indicators (single input)
## multiple output => SIMO
export BB
export MACD
export KST

# OHLCV indicators (multiple input)
## single output => MISO
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
export Stoch
export KVO

# OHLCV indicators (multiple input)
## multiple output => MIMO
export SuperTrend, Trend
export VTX
export DonchianChannels
export KeltnerChannels
export ADX
export Aroon

using OnlineStatsBase

abstract type TechnicalIndicator{T} <: OnlineStat{T} end
abstract type MovingAverageIndicator{T} <: TechnicalIndicator{T} end

include("ohlcv.jl")
include("sample_data.jl")

function has_output_value(ind::T) where {T<:OnlineStat}
    return !ismissing(value(ind))
end

# SISO
include("indicators/SMA.jl")
include("indicators/EMA.jl")
include("indicators/SMMA.jl")
include("indicators/RSI.jl")
include("indicators/MeanDev.jl")
include("indicators/StdDev.jl")
include("indicators/ROC.jl")
include("indicators/WMA.jl")
include("indicators/KAMA.jl")
include("indicators/HMA.jl")
include("indicators/DPO.jl")
include("indicators/CoppockCurve.jl")
include("indicators/DEMA.jl")
include("indicators/TEMA.jl")
include("indicators/ALMA.jl")
include("indicators/McGinleyDynamic.jl")

# SIMO
include("indicators/BB.jl")
include("indicators/MACD.jl")
include("indicators/KST.jl")

# MISO
include("indicators/AccuDist.jl")
include("indicators/BOP.jl")
include("indicators/CCI.jl")
include("indicators/ChaikinOsc.jl")
include("indicators/VWMA.jl")
include("indicators/VWAP.jl")
include("indicators/AO.jl")
include("indicators/ATR.jl")
include("indicators/ForceIndex.jl")
include("indicators/OBV.jl")
include("indicators/SOBV.jl")
include("indicators/EMV.jl")
include("indicators/Stoch.jl")
include("indicators/MassIndex.jl")
include("indicators/CHOP.jl")
include("indicators/ADX.jl")
include("indicators/KVO.jl")

# MIMO
include("indicators/SuperTrend.jl")
include("indicators/VTX.jl")
include("indicators/DonchianChannels.jl")
include("indicators/KeltnerChannels.jl")
include("indicators/Aroon.jl")

# Other stuff
include("ma.jl")  # Moving Average Factory

end
