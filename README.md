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
| `ADX` | Average Directional Index | :candle: | :m: | `ATR` | :heavy_check_mark:
| `ALMA` | Arnaud Legoux Moving Average | :1234: | :1234: | `CircBuff` | :heavy_check_mark:
| `AO` | Awesome Oscillator | :candle: | :1234: | `SMA` | :heavy_check_mark:
| `Aroon` | Aroon Up/Down | :candle: | :m: | `CirBuff` | :heavy_check_mark:
| `ATR` | Average True Range | :candle: | :1234: | `CircBuff` | :heavy_check_mark:
| `BB` | Bollinger Bands | :1234: | :m: | `SMA`, `StdDev` | :heavy_check_mark:
| `BOP` | Balance Of Power | :candle: | :1234: | - | :heavy_check_mark:
| `CCI` | Commodity Channel Index | :candle: | :1234: | `MeanDev` | :heavy_check_mark:
| `ChaikinOsc` | Chaikin Oscillator | :candle: | :1234: | `AccuDist`, `EMA` | :heavy_check_mark:
| `ChandeKrollStop` | Chande Kroll Stop | :candle: | :m: | `CircBuff`, `ATR` | :heavy_check_mark:
| `CHOP` | Choppiness Index | :candle: | :1234: | `CirBuff`, `ATR` | :heavy_check_mark:
| `CoppockCurve` | Coppock Curve | :1234: | :1234: | `ROC`, `WMA` | :heavy_check_mark:
| `DEMA` | Double Exponential Moving Average | :1234: | :1234: | `EMA` | :heavy_check_mark:
| `DonchianChannels` | Donchian Channels | :candle: | :m: | `CircBuff` | :heavy_check_mark:
| `DPO` | Detrended Price Oscillator | :1234: | :1234: | `CircBuff`, `SMA` | :heavy_check_mark:
| `EMA` | Exponential Moving Average | :1234: | :1234: | `CircBuff` | :heavy_check_mark:
| `EMV` | Ease of Movement | :candle: | :1234: | `CircBuff`, `SMA` | :heavy_check_mark:
| `FibRetracement` | Fibonacci Retracement | :question: | :question: |  | doesn't look an indicator just a simple class with 236 382 5 618 786 values
| `ForceIndex` | Force Index | :candle: | :1234: | prev input val, `EMA` | :heavy_check_mark:
| `HMA` | Hull Moving Average | :1234: | :1234: | `WMA` | :heavy_check_mark:
| `Ichimoku` | Ichimoku Clouds | :1234:  | :m: | `CircBuff` | 5 managed sequences :question: unit tests doesn't exists in [reference implementation](https://github.com/nardew/talipp/issues/87)
| `KAMA` | Kaufman's Adaptive Moving Average | :1234: | :1234: | `CircBuff` | :heavy_check_mark:
| `KeltnerChannels` | Keltner Channels | :candle:  | :m: | `ATR`, `EMA` with `input_modifier` to extract close value of a candle | :heavy_check_mark:
| `KST` | Know Sure Thing | :1234: | :m: | `ROC`, `SMA` | :heavy_check_mark:
| `KVO` | Klinger Volume Oscillator | :candle: | :1234: | `EMA` | :heavy_check_mark:
| `MACD` | Moving Average Convergence Divergence | :1234: | :m: | `EMA` | :heavy_check_mark:
| `MassIndex` | Mass Index | :candle: | :1234: | `EMA`, `CircBuff` | :heavy_check_mark:
| `McGinleyDynamic` | McGinley Dynamic | :1234: | :1234: | `CircBuff` | :heavy_check_mark:
| `MeanDev` | Mean Deviation | :1234: | :1234: | `CircBuff`, `SMA` | :heavy_check_mark:
| `OBV` | On Balance Volume | :candle: | :1234: | prev input val | :heavy_check_mark:
| `ParabolicSAR` | Parabolic Stop And Reverse | :candle: | :m: | `CirBuff` | :heavy_check_mark:
| `PivotsHL` | High/Low Pivots | :candle: | :m: | `-` | :construction: unit tests in reference implementation are [missing](https://github.com/nardew/talipp/issues/85).
| `ROC` | Rate Of Change | :1234: | :1234: | `CircBuff` | :heavy_check_mark:
| `RSI` | Relative Strength Index | :1234: | :1234: | `CircBuff`, `SMMA` | :heavy_check_mark:
| `SFX` | SFX | :candle: | :m: | `ATR`, `StdDev`, `SMA` and `input_modifier` (to extract `close`) | :heavy_check_mark:
| `SMA` | Simple Moving Average | :1234: | :1234: | `CircBuff` | :heavy_check_mark:
| `SMMA` | Smoothed Moving Average | :1234: | :1234: | `CircBuff` | :heavy_check_mark:
| `SOBV` | Smoothed On Balance Volume | :candle: | :1234: | `OBV`, `SMA` | :heavy_check_mark:
| `STC` | Schaff Trend Cycle | :1234: | :1234: | `MACD`, `Stoch` with `input_modifier` (MACDVal->OHLCV and stoch_d->OHLCV), indicator chaining, `MAFactory` (default `SMA`) | :heavy_check_mark:
| `StdDev` | Standard Deviation | :1234: | :1234: | `CircBuff` | :heavy_check_mark:
| `Stoch` | Stochastic | :candle: | :m: | `CircBuff`, `SMA` | :heavy_check_mark: [:christmas_tree:](https://discourse.julialang.org/t/incremental-technical-analysis-indicators/107844/5)
| `StochRSI` | Stochastic RSI | :1234: | :m: | `RSI`, `SMA` | :heavy_check_mark:
| `SuperTrend` | Super Trend | :candle: | :m: | `CircBuff`, `ATR` | :heavy_check_mark:
| `T3` | T3 Moving Average | :1234: | :1234: | `EMA` with indicator chaining and input filter | :heavy_check_mark:
| `TEMA` | Triple Exponential Moving Average | :1234: | :1234: | `EMA` | :heavy_check_mark:
| `TRIX` | TRIX | :candle: | :m: | `EMA`, indicator chaining | :heavy_check_mark:
| `TSI` | True Strength Index | :1234: | :1234: | `EMA`, indicator chaining | :heavy_check_mark:
| `TTM` | TTM Squeeze | :candle: | :m: | `SMA`, `BB`, `DonchianChannels`, `KeltnerChannels` and `input_modifier` to extract `close` value of a candle | :heavy_check_mark:
| `UO` | Ultimate Oscillator | :candle: | :1234: | `CircBuff` | :heavy_check_mark:
| `VTX` | Vortex Indicator | :candle: | :m: | `CircBuff`, `ATR` | :heavy_check_mark:
| `VWAP` |  Volume Weighted Average Price | :candle: | :1234: | - | :heavy_check_mark:
| `VWMA` | Volume Weighted Moving Average | :candle: | :1234: | `CircBuff` | :heavy_check_mark:
| `WMA` | Weighted Moving Average | :1234: | :1234: | `CircBuff` | :heavy_check_mark:
| `ZLEMA` | Zero Lag Exponential Moving Average | :1234: | :1234: | `EMA` | :heavy_check_mark:

### Legend

:1234: single number (input or ouput)

:m: multiple numbers (output)

:candle: OHLCV candlestick input
