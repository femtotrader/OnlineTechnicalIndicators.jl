[![Build Status](https://github.com/femtotrader/OnlineTechnicalIndicators.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/femtotrader/OnlineTechnicalIndicators.jl/actions/workflows/CI.yml?query=branch%3Amain)

# OnlineTechnicalIndicators.jl
This project implements some *Technical Analysis Indicators* in Julia in an incremental approach ie using [online algorithms](https://en.wikipedia.org/wiki/Online_algorithm).

It's inspired by Python project [talipp](https://github.com/nardew/talipp) which is used as "reference implementation" for unit tests.

It depends especially on [OnlineStatsBase.jl](https://github.com/joshday/OnlineStatsBase.jl) and on [Tables.jl](https://tables.juliadata.org/).

Currently 57 technical analysis indicators are supported (SMA, EMA, SMMA, RSI, MeanDev, StdDev, ROC, WMA, KAMA, HMA, DPO, CoppockCurve, DEMA, TEMA, ALMA, McGinleyDynamic, ZLEMA, T3, TRIX, TSI ; BB, MACD, StochRSI, KST ; AccuDist, BOP, CCI, ChaikinOsc, VWMA, VWAP, AO, TrueRange, ATR, NATR, ForceIndex, OBV, SOBV, EMV, MassIndex, CHOP, KVO, UO ; Stoch, ADX, SuperTrend, VTX, DonchianChannels, KeltnerChannels, Aroon, ChandeKrollStop, ParabolicSAR, SFX, TTM, PivotsHL ; STC)

🚧 This software is under construction. API can have breaking changes.

## ⚠️ Disclaimer – No Investment Advice

OnlineTechnicalIndicators.jl is an open-source library provided **"as-is" for educational and informational purposes only**.
* It does **not** constitute investment advice, brokerage services, or a recommendation to buy or sell any financial instrument.
* All trading involves substantial risk; **past performance is not indicative of future results**. You may lose some or all of your capital.
* By using OnlineTechnicalIndicators.jl you acknowledge that **you alone are responsible for your trading decisions** and agree that the OnlineTechnicalIndicators.jl maintainers and contributors will **not be liable for any loss or damage** arising from the use of this software.
* Consult a qualified financial professional before deploying live capital.

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
    "projects.md",
]
```
