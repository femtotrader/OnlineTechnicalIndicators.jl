# IncTA

[![Build Status](https://github.com/femtotrader/IncTA.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/femtotrader/IncTA.jl/actions/workflows/CI.yml?query=branch%3Amaster)

This project implements some Technical Analysis Indicators in Julia.

It's inspired by Python project [talipp](https://github.com/nardew/talipp)

## Install
Open Julia command line interface.

Type `] dev https://github.com/femtotrader/IncTA.jl/`

## Usage

See [tests](test/)

## Indicators

| Name | Description | Implementation status |
| --- | --- | --- |
| `ADX` | Average Directional Index |
| `ALMA` | Arnaud Legoux Moving Average |
| `AO` | Awesome Oscillator | :heavy_check_mark:
| `ATR` | Average True Range | :heavy_check_mark:
| `AccuDist` | Accumulation and Distribution | :heavy_check_mark:
| `Aroon` | Aroon Up/Down |
| `BB` | Bollinger Bands | :heavy_check_mark:
| `BOP` | Balance Of Power | :heavy_check_mark:
| `CCI` | Commodity Channel Index | :heavy_check_mark:
| `CHOP` | Choppiness Index | :heavy_exclamation_mark: Doesn't work as expected - help wanted
| `ChaikinOsc` | Chaikin Oscillator |
| `ChandeKrollStop` | Chande Kroll Stop |
| `CoppockCurve` | Coppock Curve |
| `DEMA` | Double Exponential Moving Average |
| `DPO` | Detrended Price Oscillator |
| `DonchianChannels` | Donchian Channels |
| `EMA` | Exponential Moving Average | :heavy_check_mark:
| `EMV` | Ease of Movement |
| `FibRetracement` | Fibonacci Retracement |
| `ForceIndex` | Force Index | :heavy_check_mark:
| `HMA` | Hull Moving Average | :heavy_check_mark:
| `Ichimoku` | Ichimoku Clouds |
| `KAMA` | Kaufman's Adaptive Moving Average | :heavy_exclamation_mark: Doesn't work as expected - help wanted
| `KST` | Know Sure Thing |
| `KVO` | Klinger Volume Oscillator |
| `KeltnerChannels` | Keltner Channels |
| `MACD` | Moving Average Convergence Divergence |
| `MassIndex` | Mass Index | :heavy_exclamation_mark: Doesn't work as expected - help wanted
| `McGinleyDynamic` | McGinley Dynamic |
| `MeanDev` | Mean Deviation | :heavy_check_mark:
| `OBV` | On Balance Volume | :heavy_check_mark:
| `ParabolicSAR` | Parabolic Stop And Reverse |
| `PivotsHL` | High/Low Pivots |
| `ROC` | Rate Of Change | :heavy_check_mark:
| `RSI` | Relative Strength Index | :heavy_check_mark:
| `SFX` | SFX |
| `SMA` | Simple Moving Average | :heavy_check_mark:
| `SMMA` | Smoothed Moving Average | :heavy_check_mark:
| `SOBV` | Smoothed On Balance Volume |
| `StdDev` | Standard Deviation | :heavy_check_mark:
| `Stoch` | Stochastic |
| `StochRSI` | Stochastic RSI |
| `SuperTrend` | Super Trend |
| `TEMA` | Triple Exponential Moving Average |
| `TRIX` | TRIX |
| `TSI` | True Strength Index |
| `TTM` | TTM Squeeze |
| `UO` | Ultimate Oscillator |
| `VTX` | Vortex Indicator |
| `VWAP` |  Volume Weighted Average Price | :heavy_check_mark:
| `VWMA` | Volume Weighted Moving Average | :heavy_check_mark:
| `WMA` | Weighted Moving Average | :heavy_check_mark:
