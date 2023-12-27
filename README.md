# IncTA

[![Build Status](https://github.com/femtotrader/IncTA.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/femtotrader/IncTA.jl/actions/workflows/CI.yml?query=branch%3Amaster)

This project implements some Technical Analysis Indicators in Julia in an incremental approach.

It's inspired by Python project [talipp](https://github.com/nardew/talipp) which is used as "reference implementation" for unit tests.

It depends especially on [OnlineStatsBase.jl](https://github.com/joshday/OnlineStatsBase.jl) and [OnlineStats.jl](https://github.com/joshday/OnlineStatsBase.jl).

:construction: This software is under construction. API can have breaking changes.

## Install
Open Julia command line interface.

Type `] dev https://github.com/femtotrader/IncTA.jl/`

## Usage

See [tests](test/)

## Indicators

| Name | Description | Input | Output | Dependencies | Implementation status |
| --- | --- | --- | --- | --- | --- |
| `AccuDist` | Accumulation and Distribution | :candle: | :1234: | - | :heavy_check_mark:
| `ADX` | Average Directional Index | :1234: | :m: |  | 1 sub indicator (ATR) and several managed sequences
| `ALMA` | Arnaud Legoux Moving Average | :1234: | :1234: | `CircBuff` | :heavy_check_mark:
| `AO` | Awesome Oscillator | :candle: | :1234: | `SMA` | :heavy_check_mark:
| `Aroon` | Aroon Up/Down | :candle: | :m: |  | might be quite easy except the (need to search in reversed list in order to get the right-most index)
| `ATR` | Average True Range | :candle: | :1234: | `CircBuff` | :heavy_check_mark:
| `BB` | Bollinger Bands | :1234: | :m: | `SMA`, `StdDev` | :heavy_check_mark:
| `BOP` | Balance Of Power | :candle: | :1234: |  | :heavy_check_mark:
| `CCI` | Commodity Channel Index | :candle: | :1234: | `MeanDev` | :heavy_check_mark:
| `ChaikinOsc` | Chaikin Oscillator | :candle: | :1234: | `AccuDist`, `EMA` | :heavy_check_mark:
| `CHOP` | Choppiness Index | :candle: | :1234: | `CirBuf`, `ATR` | :heavy_exclamation_mark: Doesn't work as expected - help wanted
| `ChandeKrollStop` | Chande Kroll Stop | :candle: | :m: |  | 1 sub indicator (ATR) and 2 managed sequences
| `CoppockCurve` | Coppock Curve | :1234: | :1234: | `ROC`, `WMA` | :heavy_check_mark:
| `DEMA` | Double Exponential Moving Average | :1234: | :1234: | `EMA` | :heavy_check_mark:
| `DonchianChannels` | Donchian Channels | :candle: | :m: | `CircBuff` | :heavy_check_mark:
| `DPO` | Detrended Price Oscillator | :1234: | :1234: | `CircBuff`, `SMA` | :heavy_check_mark:
| `EMA` | Exponential Moving Average | :1234: | :1234: | `CircBuff` | :heavy_check_mark:
| `EMV` | Ease of Movement | :candle: | :1234: | `CircBuff`, `SMA` | :heavy_check_mark:
| `FibRetracement` | Fibonacci Retracement | :question: | :question: |  | doesn't look an indicator just a simple class with 236 382 5 618 786 values
| `ForceIndex` | Force Index | :candle: | :1234: | keep prev val of input, `EMA` | :heavy_check_mark:
| `HMA` | Hull Moving Average | :1234: | :1234: | `WMA` | :heavy_check_mark:
| `Ichimoku` | Ichimoku Clouds | :1234:  | :m: |  | 5 managed sequences :question: unit tests doesn't exists in [reference implementation](https://github.com/nardew/talipp/issues/87)
| `KAMA` | Kaufman's Adaptive Moving Average | :1234: | :1234: | `CircBuff` | :heavy_exclamation_mark: Doesn't work as expected - help wanted
| `KeltnerChannels` | Keltner Channels | :candle:  | :m: | `ATR`, `EMA` (+ValueExtractor?) | :heavy_check_mark:
| `KST` | Know Sure Thing | :1234: | :m: | `SMA` | :heavy_exclamation_mark: Doesn't work as expected - help wanted
| `KVO` | Klinger Volume Oscillator | :candle: | :1234: |  | need EMA (fast and slow period) and 4 managed sequences
| `MACD` | Moving Average Convergence Divergence | :1234: | :m: | `EMA` | :heavy_exclamation_mark: Doesn't work as expected - help wanted
| `MassIndex` | Mass Index | :candle: | :1234: | `EMA`, `CircBuff` | :heavy_check_mark:
| `McGinleyDynamic` | McGinley Dynamic | :1234: | :1234: |  | should be easy to implement by following reference implementation (but [why are they print statements](https://github.com/nardew/talipp/issues/83)?) :question: tests are also missing in reference implementation
| `MeanDev` | Mean Deviation | :1234: | :1234: | `CircBuff`, `SMA` | :heavy_check_mark:
| `OBV` | On Balance Volume | :candle: | :1234: | prev input val | :heavy_check_mark:
| `ParabolicSAR` | Parabolic Stop And Reverse | :candle: | :m: |  | 
| `PivotsHL` | High/Low Pivots | :candle: | :m: |  | :construction: unit tests in reference implementation are [missing](https://github.com/nardew/talipp/issues/85).
| `ROC` | Rate Of Change | :1234: | :1234: | `CircBuff` | :heavy_check_mark:
| `RSI` | Relative Strength Index | :1234: | :1234: | `CircBuff`, `SMMA` | :heavy_check_mark:
| `SFX` | SFX | :candle: | :m: |  | :construction: This indicator needs value extractor which is not currently implemented
| `SMA` | Simple Moving Average | :1234: | :1234: | `CircBuff` | :heavy_check_mark:
| `SMMA` | Smoothed Moving Average | :1234: | :1234: | `CircBuff` | :heavy_check_mark:
| `SOBV` | Smoothed On Balance Volume | :candle: | :1234: | `OBV`, `SMA` | :heavy_check_mark:
| `STC` | Schaff Trend Cycle | :1234: | :1234: |  | :heavy_exclamation_mark: Need MACD and Stoch
| `StdDev` | Standard Deviation | :1234: | :1234: | `CircBuff` | :heavy_check_mark:
| `Stoch` | Stochastic | :candle: | :m: | `CircBuff`, `SMA` | :heavy_check_mark: [:christmas_tree:](https://discourse.julialang.org/t/incremental-technical-analysis-indicators/107844/5)
| `StochRSI` | Stochastic RSI | :1234: | :m: |  | subindicator RSI and 2 managed sequences (with MA) [:christmas_tree:](https://discourse.julialang.org/t/incremental-technical-analysis-indicators/107844/11)
| `SuperTrend` | Super Trend | :candle: | :m: | `CircBuff`, `ATR` | :construction: Work In Progress (currently broken)
| `TEMA` | Triple Exponential Moving Average | :1234: | :1234: | `EMA` | :heavy_check_mark:
| `TRIX` | TRIX | :candle: | :m: |  | :construction: This indicator needs indicator chaining to be implemented which is currently not done
| `TSI` | True Strength Index | :1234: | :1234: |  | :construction: This indicator needs indicator chaining to be implemented which is currently not done
| `TTM` | TTM Squeeze | :candle: | :m: | `SMA`, `BB`, `DonchianChannels`, `KeltnerChannels` | This indicator needs value extractor which is not currently implemented.
| `UO` | Ultimate Oscillator | :candle: | :1234: |  | 2 "managed sequences"
| `VTX` | Vortex Indicator | :candle: | :m: | `CircBuff`, `ATR` | :construction: Work In Progress 1 sub indicator (ATR) and 2 managed sequences
| `VWAP` |  Volume Weighted Average Price | :candle: | :1234: | - | :heavy_check_mark:
| `VWMA` | Volume Weighted Moving Average | :candle: | :1234: | `CircBuff` | :heavy_check_mark:
| `WMA` | Weighted Moving Average | :1234: | :1234: | `CircBuff` | :heavy_check_mark:


### Legend

:1234: single number (input or ouput)

:m: multiple numbers (output)

:candle: OHLCV candlestick input
