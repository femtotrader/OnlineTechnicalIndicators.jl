# API Documentation

## Submodules

OnlineTechnicalIndicators is organized into submodules for better code organization:

```@docs
OnlineTechnicalIndicators.Candlesticks
OnlineTechnicalIndicators.Internals
OnlineTechnicalIndicators.Indicators
OnlineTechnicalIndicators.Patterns
OnlineTechnicalIndicators.Wrappers
OnlineTechnicalIndicators.Factories
```

## Candlesticks Module

The Candlesticks module contains OHLCV (Open, High, Low, Close, Volume) types and related utilities.

```@docs
OnlineTechnicalIndicators.Candlesticks.OHLCV
OnlineTechnicalIndicators.Candlesticks.OHLCVFactory
```

The `ValueExtractor` submodule provides helper functions for extracting values from candlesticks:
- `extract_open(candle)` - Get the open price
- `extract_high(candle)` - Get the high price
- `extract_low(candle)` - Get the low price
- `extract_close(candle)` - Get the close price
- `extract_volume(candle)` - Get the volume

## Internals Module

The Internals module contains internal utility functions used by indicator implementations.
These are exposed for users who want to implement custom indicators.

```@docs
OnlineTechnicalIndicators.Internals.is_multi_input
OnlineTechnicalIndicators.Internals.is_multi_output
OnlineTechnicalIndicators.Internals.expected_return_type
OnlineTechnicalIndicators.Internals.has_output_value
OnlineTechnicalIndicators.Internals.has_valid_values
OnlineTechnicalIndicators.Internals.is_valid
OnlineTechnicalIndicators.Internals.always_true
OnlineTechnicalIndicators.Internals._calculate_new_value
OnlineTechnicalIndicators.Internals._calculate_new_value_only_from_incoming_data
```

### Internal Fit Implementation

The `OnlineStatsBase._fit!` method for `TechnicalIndicator` types is implemented in the Internals module. This function:

1. Applies input filter and modifier (if present in legacy indicators)
2. Updates the input values circular buffer (if present)
3. Fits sub-indicators (if present)
4. Calculates and stores the new indicator value

## Wrappers Module

The Wrappers module contains wrapper/decorator types for composing indicators.

```@docs
OnlineTechnicalIndicators.Wrappers.Smoother
OnlineTechnicalIndicators.Wrappers.DAGWrapper
```

## Factories Module

The Factories module contains factory functions for creating indicator instances.

```@docs
OnlineTechnicalIndicators.Factories.MovingAverage
OnlineTechnicalIndicators.Factories.MAFactory
```

## Indicators (alphabetically ordered)
```@docs
OnlineTechnicalIndicators.Indicators.ADR
OnlineTechnicalIndicators.Indicators.ARDR
OnlineTechnicalIndicators.Indicators.ADX
OnlineTechnicalIndicators.Indicators.ALMA
OnlineTechnicalIndicators.Indicators.AO
OnlineTechnicalIndicators.Indicators.ATR
OnlineTechnicalIndicators.Indicators.AccuDist
OnlineTechnicalIndicators.Indicators.Aroon
OnlineTechnicalIndicators.Indicators.BB
OnlineTechnicalIndicators.Indicators.BOP
OnlineTechnicalIndicators.Indicators.CCI
OnlineTechnicalIndicators.Indicators.CHOP
OnlineTechnicalIndicators.Indicators.ChaikinOsc
OnlineTechnicalIndicators.Indicators.ChandeKrollStop
OnlineTechnicalIndicators.Indicators.CoppockCurve
OnlineTechnicalIndicators.Indicators.DEMA
OnlineTechnicalIndicators.Indicators.DPO
OnlineTechnicalIndicators.Indicators.DonchianChannels
OnlineTechnicalIndicators.Indicators.EMA
OnlineTechnicalIndicators.Indicators.EMV
OnlineTechnicalIndicators.Indicators.ForceIndex
OnlineTechnicalIndicators.Indicators.GannHiloActivator
OnlineTechnicalIndicators.Indicators.GannSwingChart
OnlineTechnicalIndicators.Indicators.HMA
OnlineTechnicalIndicators.Indicators.IntradayRange
OnlineTechnicalIndicators.Indicators.KAMA
OnlineTechnicalIndicators.Indicators.KST
OnlineTechnicalIndicators.Indicators.KVO
OnlineTechnicalIndicators.Indicators.KeltnerChannels
OnlineTechnicalIndicators.Indicators.MACD
OnlineTechnicalIndicators.Indicators.MassIndex
OnlineTechnicalIndicators.Indicators.McGinleyDynamic
OnlineTechnicalIndicators.Indicators.MeanDev
OnlineTechnicalIndicators.Indicators.MFI
OnlineTechnicalIndicators.Indicators.NATR
OnlineTechnicalIndicators.Indicators.OBV
OnlineTechnicalIndicators.Indicators.ParabolicSAR
OnlineTechnicalIndicators.Indicators.PeakValleyDetector
OnlineTechnicalIndicators.Indicators.PivotsHL
OnlineTechnicalIndicators.Indicators.RelativeIntradayRange
OnlineTechnicalIndicators.Indicators.ROC
OnlineTechnicalIndicators.Indicators.RSI
OnlineTechnicalIndicators.Indicators.RetracementCalculator
OnlineTechnicalIndicators.Indicators.SFX
OnlineTechnicalIndicators.Indicators.SMA
OnlineTechnicalIndicators.Indicators.SMMA
OnlineTechnicalIndicators.Indicators.SOBV
OnlineTechnicalIndicators.Indicators.STC
OnlineTechnicalIndicators.Indicators.StdDev
OnlineTechnicalIndicators.Indicators.Stoch
OnlineTechnicalIndicators.Indicators.StochRSI
OnlineTechnicalIndicators.Indicators.SuperTrend
OnlineTechnicalIndicators.Indicators.SupportResistanceLevel
OnlineTechnicalIndicators.Indicators.T3
OnlineTechnicalIndicators.Indicators.TEMA
OnlineTechnicalIndicators.Indicators.TRIX
OnlineTechnicalIndicators.Indicators.TrueRange
OnlineTechnicalIndicators.Indicators.TSI
OnlineTechnicalIndicators.Indicators.TTM
OnlineTechnicalIndicators.Indicators.UO
OnlineTechnicalIndicators.Indicators.VTX
OnlineTechnicalIndicators.Indicators.VWAP
OnlineTechnicalIndicators.Indicators.VWMA
OnlineTechnicalIndicators.Indicators.WMA
OnlineTechnicalIndicators.Indicators.ZLEMA
```

## Indicator Value Types (alphabetically ordered)
```@docs
OnlineTechnicalIndicators.Indicators.ADXVal
OnlineTechnicalIndicators.Indicators.AroonVal
OnlineTechnicalIndicators.Indicators.BBVal
OnlineTechnicalIndicators.Indicators.ChandeKrollStopVal
OnlineTechnicalIndicators.Indicators.DonchianChannelsVal
OnlineTechnicalIndicators.Indicators.GannHiloActivatorVal
OnlineTechnicalIndicators.Indicators.GannSwingChartVal
OnlineTechnicalIndicators.Indicators.KSTVal
OnlineTechnicalIndicators.Indicators.KeltnerChannelsVal
OnlineTechnicalIndicators.Indicators.MACDVal
OnlineTechnicalIndicators.Indicators.ParabolicSARVal
OnlineTechnicalIndicators.Indicators.PeakValleyVal
OnlineTechnicalIndicators.Indicators.PivotsHLVal
OnlineTechnicalIndicators.Indicators.RetracementVal
OnlineTechnicalIndicators.Indicators.SFXVal
OnlineTechnicalIndicators.Indicators.StochRSIVal
OnlineTechnicalIndicators.Indicators.StochVal
OnlineTechnicalIndicators.Indicators.SuperTrendVal
OnlineTechnicalIndicators.Indicators.SupportResistanceLevelVal
OnlineTechnicalIndicators.Indicators.TTMVal
OnlineTechnicalIndicators.Indicators.VTXVal
```

## Pattern Detectors
```@docs
OnlineTechnicalIndicators.Patterns.Doji
OnlineTechnicalIndicators.Patterns.Hammer
OnlineTechnicalIndicators.Patterns.ShootingStar
OnlineTechnicalIndicators.Patterns.Marubozu
OnlineTechnicalIndicators.Patterns.SpinningTop
OnlineTechnicalIndicators.Patterns.Engulfing
OnlineTechnicalIndicators.Patterns.Harami
OnlineTechnicalIndicators.Patterns.PiercingDarkCloud
OnlineTechnicalIndicators.Patterns.Tweezer
OnlineTechnicalIndicators.Patterns.Star
OnlineTechnicalIndicators.Patterns.ThreeSoldiersCrows
OnlineTechnicalIndicators.Patterns.ThreeInside
OnlineTechnicalIndicators.Patterns.CandlestickPatternDetector
```

## Pattern Value Types
```@docs
OnlineTechnicalIndicators.Patterns.SingleCandlePatternVal
OnlineTechnicalIndicators.Patterns.TwoCandlePatternVal
OnlineTechnicalIndicators.Patterns.ThreeCandlePatternVal
OnlineTechnicalIndicators.Patterns.AllPatternsVal
```

## Core Types
```@docs
OnlineTechnicalIndicators.SampleData.TabOHLCV
OnlineTechnicalIndicators.TechnicalIndicatorWrapper
OnlineTechnicalIndicators.TechnicalIndicatorResults
OnlineTechnicalIndicators.Resample.SamplingPeriod
OnlineTechnicalIndicators.Resample.Resampler
OnlineTechnicalIndicators.Resample.TimedEvent
OnlineTechnicalIndicators.Resample.AgregatedStat
OnlineTechnicalIndicators.Resample.StatBuilder
OnlineTechnicalIndicators.Resample.OHLC
OnlineTechnicalIndicators.Resample.OHLCStat
OnlineTechnicalIndicators.Resample.ResamplerBy
```

## Other

!!! warning "Removed Function"
    `add_input_indicator!` has been **removed**.
    Use `OnlineStatsChains.StatDAG` to chain indicators instead.
    See the [Migration Guide](@ref) for detailed examples and migration instructions.

```@docs
OnlineTechnicalIndicators.StatLag
OnlineTechnicalIndicators.TechnicalIndicatorIterator
OnlineTechnicalIndicators.Indicators.update_levels!
```
