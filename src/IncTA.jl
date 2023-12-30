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
export STC
export ZLEMA
export T3
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
export UO

# OHLCV indicators (multiple input)
## multiple output => MIMO
export SuperTrend, Trend
export VTX
export DonchianChannels
export KeltnerChannels
export ADX
export Aroon
export ChandeKrollStop
export ParabolicSAR, SARTrend
export SFX
export TTM

export add_input_indicator!

using OnlineStatsBase

abstract type TechnicalIndicator{T} <: OnlineStat{T} end
abstract type MovingAverageIndicator{T} <: TechnicalIndicator{T} end

include("ohlcv.jl")
include("sample_data.jl")

function OnlineStatsBase._fit!(ind::O, data) where {O <: TechnicalIndicator}
    _fieldnames = fieldnames(O)
    has_input_values = :input_values in _fieldnames
    if has_input_values
        fit!(ind.input_values, data)
    end
    has_sub_indicators = :sub_indicators in _fieldnames && length(ind.sub_indicators.stats) > 0
    if :sub_indicators in fieldnames(O)
        fit!(ind.sub_indicators, data)
    end
    ind.n += 1
    ind.value = has_input_values || has_sub_indicators ? _calculate_new_value(ind) : _calculate_new_value_only_from_incoming_data(ind, data)
    fit_listeners!(ind)
end

function has_output_value(ind::O) where {O<:OnlineStat}
    return !ismissing(value(ind))
end

function fit_listeners!(ind::O) where {O<:TechnicalIndicator}
    if :output_listeners in fieldnames(typeof(ind))
        if length(ind.output_listeners.stats) == 0
            return
        end
        for listener in ind.output_listeners.stats
            fit!(listener, ind.value)
        end
    end
end

function add_input_indicator!(
    ind2::O1,
    ind1::O2,
) where {O1<:TechnicalIndicator,O2<:TechnicalIndicator}
    ind2.input_indicator = ind1
    if length(ind1.output_listeners.stats) > 0
        ind1.output_listeners = merge(ind1.output_listeners, ind2)
    else
        ind1.output_listeners = Series(ind2)
    end
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
include("indicators/ZLEMA.jl")
include("indicators/T3.jl")

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
include("indicators/UO.jl")

# MIMO
include("indicators/SuperTrend.jl")
include("indicators/VTX.jl")
include("indicators/DonchianChannels.jl")
include("indicators/KeltnerChannels.jl")
include("indicators/Aroon.jl")
include("indicators/ChandeKrollStop.jl")
include("indicators/ParabolicSAR.jl")
include("indicators/SFX.jl")
include("indicators/TTM.jl")

# More complex indicators
## SISO
include("indicators/STC.jl")  # uses MIMO indicator such as Stoch
## SIMO
## MISO
## MIMO


# Other stuff
include("ma.jl")  # Moving Average Factory

end
