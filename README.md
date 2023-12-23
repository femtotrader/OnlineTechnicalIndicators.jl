# IncTA

[![Build Status](https://github.com/femtotrader/IncTA.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/femtotrader/IncTA.jl/actions/workflows/CI.yml?query=branch%3Amaster)

This project implements some Technical Analysis Indicators in Julia in an incremental approach.

It's inspired by Python project [talipp](https://github.com/nardew/talipp) which is used as "reference implementation" for unit tests.

## Install
Open Julia command line interface.

Type `] dev https://github.com/femtotrader/IncTA.jl/`

## Usage

See [tests](test/)

## Indicators

| Name | Description | Implementation status |
| --- | --- | --- |
| `ADX` | Average Directional Index | 1 sub indicator (ATR) and several managed sequences
| `ALMA` | Arnaud Legoux Moving Average | :heavy_check_mark:
| `AO` | Awesome Oscillator | :heavy_check_mark:
| `ATR` | Average True Range | :heavy_check_mark:
| `AccuDist` | Accumulation and Distribution | :heavy_check_mark:
| `Aroon` | Aroon Up/Down | might be quite easy except the (need to search in reversed list in order to get the right-most index)
| `BB` | Bollinger Bands | :heavy_check_mark:
| `BOP` | Balance Of Power | :heavy_check_mark:
| `CCI` | Commodity Channel Index | :heavy_check_mark:
| `CHOP` | Choppiness Index | :heavy_exclamation_mark: Doesn't work as expected - help wanted
| `ChaikinOsc` | Chaikin Oscillator | :heavy_check_mark:
| `ChandeKrollStop` | Chande Kroll Stop | 1 sub indicator (ATR) and 2 managed sequences
| `CoppockCurve` | Coppock Curve | :heavy_check_mark:
| `DEMA` | Double Exponential Moving Average | :heavy_exclamation_mark: Doesn't work as expected - help wanted
| `DPO` | Detrended Price Oscillator | :heavy_check_mark:
| `DonchianChannels` | Donchian Channels | this one should be easy (take OHLCV as input and output several values) - implementation should looks similar to SuperTrend
| `EMA` | Exponential Moving Average | :heavy_check_mark:
| `EMV` | Ease of Movement | :heavy_check_mark:
| `FibRetracement` | Fibonacci Retracement | doesn't look an indicator just a simple class with 236 382 5 618 786 values
| `ForceIndex` | Force Index | :heavy_check_mark:
| `HMA` | Hull Moving Average | :heavy_check_mark:
| `Ichimoku` | Ichimoku Clouds | 5 managed sequences
| `KAMA` | Kaufman's Adaptive Moving Average | :heavy_exclamation_mark: Doesn't work as expected - help wanted
| `KST` | Know Sure Thing | :heavy_exclamation_mark: Doesn't work as expected - help wanted
| `KVO` | Klinger Volume Oscillator | need EMA (fast and slow period) and 4 managed sequences
| `KeltnerChannels` | Keltner Channels | input OHLC output several values (same as SuperTrend or DonchianChannels). need subindicators ATR and EMA
| `MACD` | Moving Average Convergence Divergence | :heavy_exclamation_mark: Doesn't work as expected - help wanted
| `MassIndex` | Mass Index | :heavy_exclamation_mark: Doesn't work as expected - help wanted
| `McGinleyDynamic` | McGinley Dynamic | should be easy to implement by following reference implementation (but [why are they print statements](https://github.com/nardew/talipp/issues/83)?)
| `MeanDev` | Mean Deviation | :heavy_check_mark:
| `OBV` | On Balance Volume | :heavy_check_mark:
| `ParabolicSAR` | Parabolic Stop And Reverse | input OHLCV output several values
| `PivotsHL` | High/Low Pivots | :construction: unit tests in reference implementation are [missing](https://github.com/nardew/talipp/issues/85).
| `ROC` | Rate Of Change | :heavy_check_mark:
| `RSI` | Relative Strength Index | :heavy_check_mark:
| `SFX` | SFX | :construction: This indicator needs value extractor which is not currently implemented
| `SMA` | Simple Moving Average | :heavy_check_mark:
| `SMMA` | Smoothed Moving Average | :heavy_check_mark:
| `SOBV` | Smoothed On Balance Volume | :heavy_check_mark:
| `StdDev` | Standard Deviation | :heavy_check_mark:
| `Stoch` | Stochastic | :christmas_tree: :construction:  [Work in progress](https://discourse.julialang.org/t/incremental-technical-analysis-indicators/107844/5)
| `StochRSI` | Stochastic RSI | input single value output several values at once (like) subindicator RSI and 2 managed sequences (with MA)
| `SuperTrend` | Super Trend | :heavy_check_mark:
| `TEMA` | Triple Exponential Moving Average | :construction: This should probably be tackled after DEMA
| `TRIX` | TRIX | :construction: This indicator needs indicator chaining to be implemented which is currently not done
| `TSI` | True Strength Index | :construction: This indicator needs indicator chaining to be implemented which is currently not done
| `TTM` | TTM Squeeze | This indicator needs value extractor which is not currently implemented. This indicator needs SMA and BB (implemented) but also DonchianChannels and KeltnerChannels (not implemented currently)
| `UO` | Ultimate Oscillator | 2 "managed sequences"
| `VTX` | Vortex Indicator | 1 sub indicator (ATR) and 2 managed sequences
| `VWAP` |  Volume Weighted Average Price | :heavy_check_mark:
| `VWMA` | Volume Weighted Moving Average | :heavy_check_mark:
| `WMA` | Weighted Moving Average | :heavy_check_mark:
