# Indicators support

| Name | Description | Input | Output | Dependencies | Implementation status |
| --- | --- | --- | --- | --- | --- |
| `AccuDist` | Accumulation and Distribution | 🕯️ | 🔢 | - | ✔️
| `ADX` | Average Directional Index | 🕯️ | Ⓜ️ | `ATR` | ✔️
| `ALMA` | Arnaud Legoux Moving Average | 🔢 | 🔢 | `CircBuff` | ✔️
| `AO` | Awesome Oscillator | 🕯️ | 🔢 | `SMA` | ✔️
| `Aroon` | Aroon Up/Down | 🕯️ | Ⓜ️ | `CircBuff` | ✔️
| `ATR` | Average True Range | 🕯️ | 🔢 | `TrueRange`, `SMMA` | ✔️
| `BB` | Bollinger Bands | 🔢 | Ⓜ️ | `SMA`, `StdDev` | ✔️
| `BOP` | Balance Of Power | 🕯️ | 🔢 | - | ✔️
| `CCI` | Commodity Channel Index | 🕯️ | 🔢 | `MeanDev` | ✔️
| `ChaikinOsc` | Chaikin Oscillator | 🕯️ | 🔢 | `AccuDist`, `EMA` | ✔️
| `ChandeKrollStop` | Chande Kroll Stop | 🕯️ | Ⓜ️ | `CircBuff`, `ATR` | ✔️
| `CHOP` | Choppiness Index | 🕯️ | 🔢 | `CircBuff`, `ATR` | ✔️
| `CoppockCurve` | Coppock Curve | 🔢 | 🔢 | `ROC`, `WMA` | ✔️
| `DEMA` | Double Exponential Moving Average | 🔢 | 🔢 | `EMA` | ✔️
| `DonchianChannels` | Donchian Channels | 🕯️ | Ⓜ️ | `CircBuff` | ✔️
| `DPO` | Detrended Price Oscillator | 🔢 | 🔢 | `CircBuff`, `SMA` | ✔️
| `EMA` | Exponential Moving Average | 🔢 | 🔢 | `CircBuff` | ✔️
| `EMV` | Ease of Movement | 🕯️ | 🔢 | `CircBuff`, `SMA` | ✔️
| `FibRetracement` | Fibonacci Retracement | ❓ | ❓ |  | Simple class with standard Fibonacci levels (0.236, 0.382, 0.5, 0.618, 0.786)
| `ForceIndex` | Force Index | 🕯️ | 🔢 | prev input val, `EMA` | ✔️
| `GannHiloActivator` | Gann HiLo Activator | 🕯️ | Ⓜ️ | `CircBuff`, `SMA` | ✔️
| `GannSwingChart` | Gann Swing Chart Analyzer | 🕯️ | Ⓜ️ | `CircBuff` | ✔️
| `HMA` | Hull Moving Average | 🔢 | 🔢 | `WMA` | ✔️
| `Ichimoku` | Ichimoku Clouds | 🔢  | Ⓜ️ | `CircBuff` | 5 managed sequences (unit tests not available in [reference implementation](https://github.com/nardew/talipp/issues/87))
| `KAMA` | Kaufman's Adaptive Moving Average | 🔢 | 🔢 | `CircBuff` | ✔️
| `KeltnerChannels` | Keltner Channels | 🕯️  | Ⓜ️ | `ATR`, `EMA` with `input_modifier` to extract close value of a candle | ✔️
| `KST` | Know Sure Thing | 🔢 | Ⓜ️ | `ROC`, `SMA` | ✔️
| `KVO` | Klinger Volume Oscillator | 🕯️ | 🔢 | `EMA` | ✔️
| `MACD` | Moving Average Convergence Divergence | 🔢 | Ⓜ️ | `EMA` | ✔️
| `MassIndex` | Mass Index | 🕯️ | 🔢 | `EMA`, `CircBuff` | ✔️
| `McGinleyDynamic` | McGinley Dynamic | 🔢 | 🔢 | `CircBuff` | ✔️
| `MeanDev` | Mean Deviation | 🔢 | 🔢 | `CircBuff`, `SMA` | ✔️
| `NATR` | Normalized Average True Range | 🕯️ | 🔢 | `ATR` | ✔️
| `OBV` | On Balance Volume | 🕯️ | 🔢 | prev input val | ✔️
| `ParabolicSAR` | Parabolic Stop And Reverse | 🕯️ | Ⓜ️ | `CircBuff` | ✔️
| `PeakValleyDetector` | Peak Valley Detection | 🕯️ | Ⓜ️ | `CircBuff` | ✔️
| `PivotsHL` | High/Low Pivots | 🕯️ | Ⓜ️ | `-` | ✔️ (unit tests [missing](https://github.com/nardew/talipp/issues/85) in reference implementation)
| `RetracementCalculator` | Retracement Level Calculator | 🕯️ | Ⓜ️ | `CircBuff` | ✔️
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
| `SupportResistanceLevel` | Support Resistance Levels | 🕯️ | Ⓜ️ | `CircBuff` | ✔️
| `T3` | T3 Moving Average | 🔢 | 🔢 | `EMA` with indicator chaining and input filter | ✔️
| `TEMA` | Triple Exponential Moving Average | 🔢 | 🔢 | `EMA` | ✔️
| `TRIX` | TRIX | 🕯️ | Ⓜ️ | `EMA`, indicator chaining | ✔️
| `TrueRange` | True Range | 🕯️ | 🔢 | `CircBuff` | ✔️
| `TSI` | True Strength Index | 🔢 | 🔢 | `EMA`, indicator chaining | ✔️
| `TTM` | TTM Squeeze | 🕯️ | Ⓜ️ | `SMA`, `BB`, `DonchianChannels`, `KeltnerChannels` and `input_modifier` to extract `close` value of a candle | ✔️
| `UO` | Ultimate Oscillator | 🕯️ | 🔢 | `CircBuff` | ✔️
| `VTX` | Vortex Indicator | 🕯️ | Ⓜ️ | `CircBuff`, `ATR` | ✔️
| `VWAP` |  Volume Weighted Average Price | 🕯️ | 🔢 | - | ✔️
| `VWMA` | Volume Weighted Moving Average | 🕯️ | 🔢 | `CircBuff` | ✔️
| `WMA` | Weighted Moving Average | 🔢 | 🔢 | `CircBuff` | ✔️
| `ZLEMA` | Zero Lag Exponential Moving Average | 🔢 | 🔢 | `EMA` | ✔️

## Legend

🔢 single number (input or output)

Ⓜ️ multiple numbers (output)

🕯️ OHLCV candlestick input

### Indicators implementation category

🔢 🔢 SISO indicators

🔢 Ⓜ️ SIMO indicators

🕯️ 🔢 MISO indicators

🕯️ Ⓜ️ MIMO indicators

Indicators can be of 1 out of 4 categories given their input/output behavior : SISO, SIMO, MISO and MIMO.
