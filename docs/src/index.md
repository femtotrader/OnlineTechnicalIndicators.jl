[![Build Status](https://github.com/femtotrader/IncTA.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/femtotrader/IncTA.jl/actions/workflows/CI.yml?query=branch%3Amaster)

# IncTA.jl
This project implements some *Technical Analysis Indicators* in Julia in an incremental approach.

It's inspired by Python project [talipp](https://github.com/nardew/talipp) which is used as "reference implementation" for unit tests.

It depends especially on [OnlineStatsBase.jl](https://github.com/joshday/OnlineStatsBase.jl) and [OnlineStats.jl](https://github.com/joshday/OnlineStatsBase.jl).

🚧 This software is under construction. API can have breaking changes.

## Package Features
- Calculate new value of some technical analysis indicators when new incoming are received

## Install
Open Julia command line interface. 

Type `] dev https://github.com/femtotrader/IncTA.jl/`

## Function Documentation (alphabetically ordered)
```@docs
IncTA.ADX
IncTA.ALMA
IncTA.AO
IncTA.ATR
IncTA.AccuDist
IncTA.Aroon
IncTA.BB
IncTA.BOP
IncTA.CCI
IncTA.CHOP
IncTA.ChaikinOsc
IncTA.ChandeKrollStop
IncTA.CoppockCurve
IncTA.DEMA
IncTA.DPO
IncTA.DonchianChannels
IncTA.EMA
IncTA.EMV
IncTA.ForceIndex
IncTA.HMA
IncTA.KAMA
IncTA.KST
IncTA.KVO
IncTA.KeltnerChannels
IncTA.MACD
IncTA.MassIndex
IncTA.McGinleyDynamic
IncTA.MeanDev
IncTA.OBV
IncTA.ParabolicSAR
IncTA.ROC
IncTA.RSI
IncTA.SFX
IncTA.SMA
IncTA.SMMA
IncTA.SOBV
IncTA.STC
IncTA.StdDev
IncTA.Stoch
IncTA.SuperTrend
IncTA.T3
IncTA.TEMA
IncTA.TRIX
IncTA.TSI
IncTA.TTM
IncTA.UO
IncTA.VTX
IncTA.VWAP
IncTA.VWMA
IncTA.WMA
IncTA.ZLEMA
```
