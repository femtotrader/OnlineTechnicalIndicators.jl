[![Build Status](https://github.com/femtotrader/IncTA.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/femtotrader/IncTA.jl/actions/workflows/CI.yml?query=branch%main)

# IncTA.jl
This project implements some *Technical Analysis Indicators* in Julia in an incremental approach ie using [online algorithms](https://en.wikipedia.org/wiki/Online_algorithm).

It's inspired by Python project [talipp](https://github.com/nardew/talipp) which is used as "reference implementation" for unit tests.

It depends especially on [OnlineStatsBase.jl](https://github.com/joshday/OnlineStatsBase.jl) and on [Tables.jl](https://tables.juliadata.org/).

Currently more than 50 technical analysis indicators are supported (SMA, EMA, SMMA, RSI, MeanDev, StdDev, ROC, WMA, KAMA, HMA, DPO, CoppockCurve, DEMA, TEMA, ALMA, McGinleyDynamic, ZLEMA, T3, TRIX, TSI ; BB, MACD, StochRSI, KST ; AccuDist, BOP, CCI, ChaikinOsc, VWMA, VWAP, AO, ATR, ForceIndex, OBV, SOBV, EMV, MassIndex, CHOP, KVO, UO ; Stoch, ADX, SuperTrend, VTX, DonchianChannels, KeltnerChannels, Aroon, ChandeKrollStop, ParabolicSAR, SFX, TTM, PivotsHL ; STC)

🚧 This software is under construction. API can have breaking changes.

## Contents

```@contents
Pages = [
    "index.md",
    "features.md",
    "install.md",
    "usage.md",
    "indicators_support.md",
    "usage_more.md",
    "examples.md",
    "internals.md",
    "implementing_your_indic.md",
    "api.md",
]
```
