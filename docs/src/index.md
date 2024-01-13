[![Build Status](https://github.com/femtotrader/IncTA.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/femtotrader/IncTA.jl/actions/workflows/CI.yml?query=branch%3Amaster)

# IncTA.jl
This project implements some *Technical Analysis Indicators* in Julia in an incremental approach.

It's inspired by Python project [talipp](https://github.com/nardew/talipp) which is used as "reference implementation" for unit tests.

It depends especially on [OnlineStatsBase.jl](https://github.com/joshday/OnlineStatsBase.jl) and on [Tables.jl](https://tables.juliadata.org/).

Currently more than 50 technical analysis indicators are supported (SMA, EMA, SMMA, RSI, MeanDev, StdDev, ROC, WMA, KAMA, HMA, DPO, CoppockCurve, DEMA, TEMA, ALMA, McGinleyDynamic, ZLEMA, T3, TRIX, TSI ; BB, MACD, StochRSI, KST ; AccuDist, BOP, CCI, ChaikinOsc, VWMA, VWAP, AO, ATR, ForceIndex, OBV, SOBV, EMV, MassIndex, CHOP, KVO, UO ; Stoch, ADX, SuperTrend, VTX, DonchianChannels, KeltnerChannels, Aroon, ChandeKrollStop, ParabolicSAR, SFX, TTM, PivotsHL ; STC)

🚧 This software is under construction. API can have breaking changes.

## Package Features
- Input new data (one observation at a time) to indicator with `fit!` function (from [OnlineStats.jl](https://joshday.github.io/OnlineStats.jl/))
- Input data which inherits `AbstractVector`
- Input data as compatible [Tables.jl](https://tables.juliadata.org/) format
- Sub-indicators
- Indicators chaining
- Filter/transform input of indicator

## Install
Open Julia command line interface. 

Type `] dev https://github.com/femtotrader/IncTA.jl/`

## Usage

See [examples](https://github.com/femtotrader/IncTA.jl/tree/main/examples) and [tests](https://github.com/femtotrader/IncTA.jl/tree/main/test)

IncTA.jl - installing and using it

[![IncTA.jl - installing and using it](http://img.youtube.com/vi/UqHEMi8pCyc/0.jpg)](http://www.youtube.com/watch?v=UqHEMi8pCyc "IncTA.jl - installing and using it")

IncTA.jl - dealing with TSFrames

[![IncTA.jl - dealing with TSFrames](http://img.youtube.com/vi/gmR1QvISiLA/0.jpg)](http://www.youtube.com/watch?v=gmR1QvISiLA "IncTA.jl - dealing with TSFrames")

## Indicators support

| Name | Description | Input | Output | Dependencies | Implementation status |
| --- | --- | --- | --- | --- | --- |
| `AccuDist` | Accumulation and Distribution | 🕯️ | 🔢 | - | ✔️
| `ADX` | Average Directional Index | 🕯️ | Ⓜ️ | `ATR` | ✔️
| `ALMA` | Arnaud Legoux Moving Average | 🔢 | 🔢 | `CircBuff` | ✔️
| `AO` | Awesome Oscillator | 🕯️ | 🔢 | `SMA` | ✔️
| `Aroon` | Aroon Up/Down | 🕯️ | Ⓜ️ | `CirBuff` | ✔️
| `ATR` | Average True Range | 🕯️ | 🔢 | `CircBuff` | ✔️
| `BB` | Bollinger Bands | 🔢 | Ⓜ️ | `SMA`, `StdDev` | ✔️
| `BOP` | Balance Of Power | 🕯️ | 🔢 | - | ✔️
| `CCI` | Commodity Channel Index | 🕯️ | 🔢 | `MeanDev` | ✔️
| `ChaikinOsc` | Chaikin Oscillator | 🕯️ | 🔢 | `AccuDist`, `EMA` | ✔️
| `ChandeKrollStop` | Chande Kroll Stop | 🕯️ | Ⓜ️ | `CircBuff`, `ATR` | ✔️
| `CHOP` | Choppiness Index | 🕯️ | 🔢 | `CirBuff`, `ATR` | ✔️
| `CoppockCurve` | Coppock Curve | 🔢 | 🔢 | `ROC`, `WMA` | ✔️
| `DEMA` | Double Exponential Moving Average | 🔢 | 🔢 | `EMA` | ✔️
| `DonchianChannels` | Donchian Channels | 🕯️ | Ⓜ️ | `CircBuff` | ✔️
| `DPO` | Detrended Price Oscillator | 🔢 | 🔢 | `CircBuff`, `SMA` | ✔️
| `EMA` | Exponential Moving Average | 🔢 | 🔢 | `CircBuff` | ✔️
| `EMV` | Ease of Movement | 🕯️ | 🔢 | `CircBuff`, `SMA` | ✔️
| `FibRetracement` | Fibonacci Retracement | ❓ | ❓ |  | doesn't look an indicator just a simple class with 236 382 5 618 786 values
| `ForceIndex` | Force Index | 🕯️ | 🔢 | prev input val, `EMA` | ✔️
| `HMA` | Hull Moving Average | 🔢 | 🔢 | `WMA` | ✔️
| `Ichimoku` | Ichimoku Clouds | 🔢  | Ⓜ️ | `CircBuff` | 5 managed sequences ❓ unit tests doesn't exists in [reference implementation](https://github.com/nardew/talipp/issues/87)
| `KAMA` | Kaufman's Adaptive Moving Average | 🔢 | 🔢 | `CircBuff` | ✔️
| `KeltnerChannels` | Keltner Channels | 🕯️  | Ⓜ️ | `ATR`, `EMA` with `input_modifier` to extract close value of a candle | ✔️
| `KST` | Know Sure Thing | 🔢 | Ⓜ️ | `ROC`, `SMA` | ✔️
| `KVO` | Klinger Volume Oscillator | 🕯️ | 🔢 | `EMA` | ✔️
| `MACD` | Moving Average Convergence Divergence | 🔢 | Ⓜ️ | `EMA` | ✔️
| `MassIndex` | Mass Index | 🕯️ | 🔢 | `EMA`, `CircBuff` | ✔️
| `McGinleyDynamic` | McGinley Dynamic | 🔢 | 🔢 | `CircBuff` | ✔️
| `MeanDev` | Mean Deviation | 🔢 | 🔢 | `CircBuff`, `SMA` | ✔️
| `OBV` | On Balance Volume | 🕯️ | 🔢 | prev input val | ✔️
| `ParabolicSAR` | Parabolic Stop And Reverse | 🕯️ | Ⓜ️ | `CirBuff` | ✔️
| `PivotsHL` | High/Low Pivots | 🕯️ | Ⓜ️ | `-` | 🚧 unit tests in reference implementation are [missing](https://github.com/nardew/talipp/issues/85) but code seems quite ready ✔️
| `ROC` | Rate Of Change | 🔢 | 🔢 | `CircBuff` | ✔️
| `RSI` | Relative Strength Index | 🔢 | 🔢 | `CircBuff`, `SMMA` | ✔️
| `SFX` | SFX | 🕯️ | Ⓜ️ | `ATR`, `StdDev`, `SMA` and `input_modifier` (to extract `close`) | ✔️
| `SMA` | Simple Moving Average | 🔢 | 🔢 | `CircBuff` | ✔️
| `SMMA` | Smoothed Moving Average | 🔢 | 🔢 | `CircBuff` | ✔️
| `SOBV` | Smoothed On Balance Volume | 🕯️ | 🔢 | `OBV`, `SMA` | ✔️
| `STC` | Schaff Trend Cycle | 🔢 | 🔢 | `MACD`, `Stoch` with `input_modifier` (MACDVal->OHLCV and stoch_d->OHLCV), indicator chaining, `MAFactory` (default `SMA`) | ✔️
| `StdDev` | Standard Deviation | 🔢 | 🔢 | `CircBuff` | ✔️
| `Stoch` | Stochastic | 🕯️ | Ⓜ️ | `CircBuff`, `SMA` | ✔️ [🎄](https://discourse.julialang.org/t/incremental-technical-analysis-indicators/107844/5)
| `StochRSI` | Stochastic RSI | 🔢 | Ⓜ️ | `RSI`, `SMA` | ✔️
| `SuperTrend` | Super Trend | 🕯️ | Ⓜ️ | `CircBuff`, `ATR` | ✔️
| `T3` | T3 Moving Average | 🔢 | 🔢 | `EMA` with indicator chaining and input filter | ✔️
| `TEMA` | Triple Exponential Moving Average | 🔢 | 🔢 | `EMA` | ✔️
| `TRIX` | TRIX | 🕯️ | Ⓜ️ | `EMA`, indicator chaining | ✔️
| `TSI` | True Strength Index | 🔢 | 🔢 | `EMA`, indicator chaining | ✔️
| `TTM` | TTM Squeeze | 🕯️ | Ⓜ️ | `SMA`, `BB`, `DonchianChannels`, `KeltnerChannels` and `input_modifier` to extract `close` value of a candle | ✔️
| `UO` | Ultimate Oscillator | 🕯️ | 🔢 | `CircBuff` | ✔️
| `VTX` | Vortex Indicator | 🕯️ | Ⓜ️ | `CircBuff`, `ATR` | ✔️
| `VWAP` |  Volume Weighted Average Price | 🕯️ | 🔢 | - | ✔️
| `VWMA` | Volume Weighted Moving Average | 🕯️ | 🔢 | `CircBuff` | ✔️
| `WMA` | Weighted Moving Average | 🔢 | 🔢 | `CircBuff` | ✔️
| `ZLEMA` | Zero Lag Exponential Moving Average | 🔢 | 🔢 | `EMA` | ✔️

### Legend

🔢 single number (input or ouput)

Ⓜ️ multiple numbers (output)

🕯️ OHLCV candlestick input

#### Indicators implementation category

🔢 🔢 SISO indicators

🔢 Ⓜ️ SIMO indicators

🕯️ 🔢 MISO indicators

🕯️ Ⓜ️ MIMO indicators

Indicators can be of 1 out of 4 categories given their input/output behavior : SISO, SIMO, MISO and MIMO.

### Feeding a technical analysis indicator

- A technical indicator can be feeded using `fit!` function.

- It's feeded *one observation at a time*.


#### Showing sample data (close prices)

Some sample data are provided for testing purpose.

```julia
julia> using IncTA
julia> using IncTA.SampleData: CLOSE_TMPL, V_OHLCV
julia> CLOSE_TMPL
50-element Vector{Float64}:
 10.5
  9.78
 10.46
 10.51
  ⋮
 10.15
 10.3
 10.59
 10.23
 10.0
```

#### Calculate `SMA` (simple moving average)

```julia
julia> ind = SMA{Float64}(period = 3)  # this is a SISO (single input / single output) indicator
SMA: n=0 | value=missing

julia> for p in CLOSE_TMPL
           fit!(ind, p)
           println(value(ind))
       end
missing
missing
10.246666666666668
10.250000000000002
10.50666666666667
10.593333333333335
10.476666666666668
 ⋮
9.283333333333339
9.886666666666672
10.346666666666671
10.373333333333338
10.273333333333339
```

#### Calculate BB (Bollinger bands)

```julia
julia> ind = BB{Float64}(period = 3)  # this is a SIMO (single input / multiple output) indicator
       for p in CLOSE_TMPL
           fit!(ind, p)
           println(value(ind))
       end
missing
missing
IncTA.BBVal{Float64}(9.585892709687261, 10.246666666666668, 10.907440623646075)
IncTA.BBVal{Float64}(9.584067070444279, 10.250000000000002, 10.915932929555725)
IncTA.BBVal{Float64}(10.433030926552087, 10.50666666666667, 10.580302406781252)
 ⋮
IncTA.BBVal{Float64}(7.923987085233826, 9.283333333333339, 10.642679581432851)
IncTA.BBVal{Float64}(8.921909932792502, 9.886666666666672, 10.851423400540842)
IncTA.BBVal{Float64}(9.981396599151932, 10.346666666666671, 10.71193673418141)
IncTA.BBVal{Float64}(10.061635473931714, 10.373333333333338, 10.685031192734963)
IncTA.BBVal{Float64}(9.787718030627357, 10.273333333333339, 10.758948636039321)
```

#### Showing sample data (OHLCV data)

```julia
julia> V_OHLCV  # fields are open/high/low/close/volume/time
50-element Vector{OHLCV{Missing, Float64, Float64}}:
 OHLCV{Missing, Float64, Float64}(10.81, 11.02, 9.9, 10.5, 55.03, missing)
 OHLCV{Missing, Float64, Float64}(10.58, 10.74, 9.78, 9.78, 117.86, missing)
 OHLCV{Missing, Float64, Float64}(10.07, 10.65, 9.5, 10.46, 301.04, missing)
 OHLCV{Missing, Float64, Float64}(10.58, 11.05, 10.47, 10.51, 157.94, missing)
 ⋮
 OHLCV{Missing, Float64, Float64}(9.3, 10.5, 9.26, 10.15, 255.3, missing)
 OHLCV{Missing, Float64, Float64}(10.23, 10.3, 10.0, 10.3, 111.55, missing)
 OHLCV{Missing, Float64, Float64}(10.29, 10.86, 10.19, 10.59, 108.27, missing)
 OHLCV{Missing, Float64, Float64}(10.77, 10.77, 10.15, 10.23, 48.29, missing)
 OHLCV{Missing, Float64, Float64}(10.28, 10.39, 9.62, 10.0, 81.66, missing)
```

#### Calculate ATR (Average true range)

```julia
julia> ind = ATR{OHLCV}(period = 3)  # this is a MISO (multi input / single output) indicator
ATR: n=0 | value=missing

julia> for candle in V_OHLCV
           fit!(ind, candle)
           println(value(ind))
       end
missing
missing
1.0766666666666669
0.9144444444444445
0.7562962962962961
 ⋮
0.898122497312842
0.6987483315418949
0.6891655543612633
0.6661103695741752
0.700740246382784
```

#### Calculate Stoch (Stochastic)

```julia
julia> ind = Stoch{OHLCV{Missing,Float64,Float64}}(period = 3)  # this is a MIMO indicator
Stoch: n=0 | value=missing

julia> for candle in V_OHLCV
           fit!(ind, candle)
           println(value(ind))
       end
IncTA.StochVal{Float64}(53.57142857142858, missing)
IncTA.StochVal{Float64}(0.0, missing)
IncTA.StochVal{Float64}(63.15789473684218, 38.90977443609025)
IncTA.StochVal{Float64}(65.1612903225806, 42.77306168647426)
IncTA.StochVal{Float64}(67.74193548387099, 65.35370684776458)
 ⋮
IncTA.StochVal{Float64}(83.17307692307695, 54.98661936768733)
IncTA.StochVal{Float64}(90.38461538461543, 83.17307692307693)
IncTA.StochVal{Float64}(83.12500000000001, 85.56089743589745)
IncTA.StochVal{Float64}(26.744186046511697, 66.75126714370903)
IncTA.StochVal{Float64}(30.645161290322637, 46.83811577894477)
```

### Feeding a technical analysis indicator with a compatible Tables.jl table such as TSFrame.

A technical analysis indicator can also accept a [Tables.jl](https://tables.juliadata.org/) compatible table (`TSFrame`) as input parameter.

#### Showing sample data (OHLCV data)

```julia
julia> using MarketData
julia> using TSFrames
julia> using Random
julia> Random.seed!(1234)  # to have reproductible results (so won't be really random)
julia> ta = random_ohlcv()  # should return a TimeSeries.TimeArray
julia> ts = TSFrame(ta)  # converts a TimeSeries.TimeArray to TSFrames.TSFrame
500×5 TSFrame with DateTime Index
 Index                Open     High     Low      Close    Volume
 DateTime             Float64  Float64  Float64  Float64  Float64
──────────────────────────────────────────────────────────────────
 2020-01-01T00:00:00   326.75   334.03   326.18   333.16     83.6
 2020-01-01T01:00:00   333.29   334.6    330.01   330.3      45.9
 2020-01-01T02:00:00   330.79   336.7    329.99   334.0      71.2
 2020-01-01T03:00:00   334.83   339.79   334.83   338.39     97.1
 2020-01-01T04:00:00   338.36   339.09   331.22   331.22     79.1
          ⋮              ⋮        ⋮        ⋮        ⋮        ⋮
 2020-01-21T15:00:00   353.2    360.62   349.99   358.86     59.0
 2020-01-21T16:00:00   358.81   364.03   354.5    364.03      4.2
 2020-01-21T17:00:00   363.06   367.52   362.31   362.31     90.0
 2020-01-21T18:00:00   362.03   364.81   360.4    363.3      45.6
 2020-01-21T19:00:00   362.35   363.23   358.28   361.52     19.8
```

#### Simple Moving Average (`SMA`) of close prices

```julia
julia> SMA(ts; period = 3)
500×1 TSFrame with DateTime Index
 Index                SMA
 DateTime             Float64?
──────────────────────────────────
 2020-01-01T00:00:00  missing
 2020-01-01T01:00:00  missing
 2020-01-01T02:00:00      332.487
 2020-01-01T03:00:00      334.23
 2020-01-01T04:00:00      334.537
          ⋮                ⋮
 2020-01-21T15:00:00      352.087
 2020-01-21T16:00:00      358.41
 2020-01-21T17:00:00      361.733
 2020-01-21T18:00:00      363.213
 2020-01-21T19:00:00      362.377
```

#### Simple Moving Average (`SMA`) of open prices

```julia
julia> SMA(ts; period = 3, default = :Open)
500×1 TSFrame with DateTime Index
 Index                SMA
 DateTime             Float64?
──────────────────────────────────
 2020-01-01T00:00:00  missing
 2020-01-01T01:00:00  missing
 2020-01-01T02:00:00      330.277
 2020-01-01T03:00:00      332.97
 2020-01-01T04:00:00      334.66
          ⋮                ⋮
 2020-01-21T15:00:00      346.72
 2020-01-21T16:00:00      352.293
 2020-01-21T17:00:00      358.357
 2020-01-21T18:00:00      361.3
 2020-01-21T19:00:00      362.48
```

#### Calculate `BB` (Bollinger bands)

```julia
julia> SMA(ts; period = 3)
500×1 TSFrame with DateTime Index
 Index                SMA
 DateTime             Float64?
──────────────────────────────────
 2020-01-01T00:00:00  missing
 2020-01-01T01:00:00  missing
 2020-01-01T02:00:00      332.487
 2020-01-01T03:00:00      334.23
 2020-01-01T04:00:00      334.537
          ⋮                ⋮
 2020-01-21T15:00:00      352.087
 2020-01-21T16:00:00      358.41
 2020-01-21T17:00:00      361.733
 2020-01-21T18:00:00      363.213
 2020-01-21T19:00:00      362.377
```

#### Calculate `ATR` (Average true range)

```julia
julia> ATR(ts; period = 3)
500×1 TSFrame with DateTime Index
 Index                ATR
 DateTime             Float64?
────────────────────────────────────
 2020-01-01T00:00:00  missing
 2020-01-01T01:00:00  missing
 2020-01-01T02:00:00        6.38333
 2020-01-01T03:00:00        6.18556
 2020-01-01T04:00:00        6.74704
          ⋮                 ⋮
 2020-01-21T15:00:00        8.53068
 2020-01-21T16:00:00        8.86378
 2020-01-21T17:00:00        7.64586
 2020-01-21T18:00:00        6.56724
 2020-01-21T19:00:00        6.05149
```

##### Calculate `Stoch` (Stochastic)

```julia
julia> Stoch(ts; period = 3)
500×2 TSFrame with DateTime Index
 Index                Stoch_k    Stoch_d
 DateTime             Float64    Float64?
───────────────────────────────────────────────
 2020-01-01T00:00:00   88.9172   missing
 2020-01-01T01:00:00   48.9311   missing
 2020-01-01T02:00:00   74.3346        70.7276
 2020-01-01T03:00:00   85.7143        69.66
 2020-01-01T04:00:00   12.551         57.5333
          ⋮               ⋮            ⋮
 2020-01-21T15:00:00   91.4272        93.9504
 2020-01-21T16:00:00  100.0           97.1424
 2020-01-21T17:00:00   70.2795        87.2356
 2020-01-21T18:00:00   67.5883        79.2893
 2020-01-21T19:00:00   35.0649        57.6443
```

## IncTA internals

### Sub-indicator(s)

An indicator *can* be composed *internally* of sub-indicator(s). Input values catched by `fit!` calls are transmitted to each `sub_indicators` to be processed to `_calculate_new_value` function which calculates value of indicator output.

Example: Bollinger Bands (`BB`) indicator owns 2 internal sub-indicators
- `central_band` which is a simple moving average of prices,
- `std_dev` which is standard deviation of prices.

### Composing new indicators

#### Indicators chaining

All indicators come with a great feature named **indicators chaining**. It's like building new indicator with Lego™ bricks.

Example:

- `DEMA` : **2** `EMA` chained together
- `TEMA` : **3** `EMA` chained together

#### Filtering and transforming input

Thanks to this indicator chaining feature it's possible to **compose more complex indicators** on top of the existing and simpler ones.

A mechanism for **filtering and transforming** input of an indicator which is feeded by an another one (using generally anonymous functions) have also be implemented.

Input of an indicator can be filtered / transformed to be used internaly by sub-indicators or be processed directly by `_calculate_new_value` function.

#### Moving average factory

- `SMA`, `EMA`, ... are moving average.

Most complex indicators uses in their **original form** SMA or EMA as default moving average.

In some markets they can perform better by using instead **an other kind of moving average**.

A **moving average factory** have been implemented 

This kind of indicators have a `ma` parameter in order to **bypass** their default moving average uses.

## Implementing your own indicator

### Categorization of your indicator

Categorization of indicators is done to better understand *implementation* of indicators, not to understand the *role* of each indicator. To better understand the role of each indicator other categories such as moving averages, momentum indicators, volatility indicators are better suited.

#### SISO indicators (🔢 🔢)

A **SISO** indicator takes one simple observation (price of an asset, volume of assets traded...) and output just one value for this observation.

`SMA`, `EMA` are good examples of such indicator category (but also most of others moving average indicators).

#### SIMO indicators (🔢 Ⓜ️)

The very famous `BB` (Bollinger Bands developed by financial analyst John Bollinger) indicator is an example of **SIMO** indicator. Like a SISO indicator it takes one simple value at a time. But contrary to SISO indicator, SIMO indicators generate several values at a time (upper band, central value, lower band in the case of Bollinger Bands indicator).

#### MISO indicators (🕯️ 🔢)

IncTA have also some **MISO** indicators ie indicators which takes several values at a time. It can be candlestick OHLCV data for example. Average True Range (ATR) is an example of such an indicator. It's the average of true ranges over the specified period. ATR measures volatility, taking into account any gaps in the price movement. It was developed by a very prolific author named J. Welles Wilder (also author of RSI, ParabolicSAR and ADX).

#### MIMO indicators (🕯️ Ⓜ️)

The last implementation type of indicator are **MIMO** indicators ie indicator which take several values at a time (such a candlestick data) and ouput several values at a time. Stochastic oscillator (`Stoch` also known as KD indicator) is an example of such indicator implementation category). It was developed in the late 1950s by a technical analyst named Georges Lane. This method attempts to predict price turning points by comparing the closing price of a security to its price range. Such indicator ouputs 2 values at a time : k and d.

### Steps to implement your own indicator

1. First step to implement your own indicator is to **categorized** it in the SISO, SIMO, MISO, MIMO category.
2. Look at **indicator dependencies** and try to find out an existing indicator of similar category with similar features used.
3. **Watch existing code** of an indicator of a similar category with quite similar dependencies.
4. Copy file into `src\indicators` directory with same name for `struct` and filename (that's important for tests)
5. Increment number of indicators in `test_indicators_interface.jl`
    
    `@test length(files) == ...  # number of indicators`

6. Create unit tests (in the correct category) and ensure they are passing.

## API Documentation
### Indicators (alphabetically ordered)
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
IncTA.PivotsHL
IncTA.ROC
IncTA.RSI
IncTA.SFX
IncTA.SMA
IncTA.SMMA
IncTA.SOBV
IncTA.STC
IncTA.StdDev
IncTA.Stoch
IncTA.StochRSI
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

### Other
```@docs
IncTA.StatLag
IncTA.TechnicalIndicatorIterator
```
