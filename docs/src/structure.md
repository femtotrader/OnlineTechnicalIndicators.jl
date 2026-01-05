# Project Structure

This page describes the directory layout and file organization of OnlineTechnicalIndicators.jl.

## Directory Tree

```
OnlineTechnicalIndicators/
├── src/                                # Source code
│   ├── OnlineTechnicalIndicators.jl    # Main module entry point
│   ├── stats.jl                        # Statistical utilities
│   ├── sample_data.jl                  # Sample OHLCV data module
│   ├── resample.jl                     # Time-series resampling utilities
│   │
│   ├── candlesticks/                   # OHLCV data structures
│   │   ├── Candlesticks.jl             # Submodule definition
│   │   └── ohlcv.jl                    # OHLCV struct and OHLCVFactory
│   │
│   ├── internals/                      # Internal utilities
│   │   └── Internals.jl                # Helper functions for indicators
│   │
│   ├── indicators/                     # Technical indicators (60+)
│   │   ├── Indicators.jl               # Submodule definition and exports
│   │   │
│   │   │   # SISO (Single Input, Single Output)
│   │   ├── SMA.jl                      # Simple Moving Average
│   │   ├── EMA.jl                      # Exponential Moving Average
│   │   ├── SMMA.jl                     # Smoothed Moving Average
│   │   ├── WMA.jl                      # Weighted Moving Average
│   │   ├── DEMA.jl                     # Double EMA
│   │   ├── TEMA.jl                     # Triple EMA
│   │   ├── KAMA.jl                     # Kaufman Adaptive MA
│   │   ├── HMA.jl                      # Hull Moving Average
│   │   ├── ALMA.jl                     # Arnaud Legoux MA
│   │   ├── ZLEMA.jl                    # Zero-Lag EMA
│   │   ├── McGinleyDynamic.jl          # McGinley Dynamic
│   │   ├── T3.jl                       # Tillson T3
│   │   ├── RSI.jl                      # Relative Strength Index
│   │   ├── ROC.jl                      # Rate of Change
│   │   ├── DPO.jl                      # Detrended Price Oscillator
│   │   ├── CoppockCurve.jl             # Coppock Curve
│   │   ├── MeanDev.jl                  # Mean Deviation
│   │   ├── StdDev.jl                   # Standard Deviation
│   │   ├── TRIX.jl                     # Triple Smooth EMA ROC
│   │   ├── TSI.jl                      # True Strength Index
│   │   │
│   │   │   # SIMO (Single Input, Multiple Output)
│   │   ├── BB.jl                       # Bollinger Bands
│   │   ├── MACD.jl                     # Moving Average Convergence Divergence
│   │   ├── StochRSI.jl                 # Stochastic RSI
│   │   ├── KST.jl                      # Know Sure Thing
│   │   │
│   │   │   # MISO (Multiple Input, Single Output)
│   │   ├── TrueRange.jl                # True Range
│   │   ├── ATR.jl                      # Average True Range
│   │   ├── NATR.jl                     # Normalized ATR
│   │   ├── AccuDist.jl                 # Accumulation/Distribution
│   │   ├── OBV.jl                      # On Balance Volume
│   │   ├── SOBV.jl                     # Smoothed OBV
│   │   ├── MFI.jl                      # Money Flow Index
│   │   ├── BOP.jl                      # Balance of Power
│   │   ├── CCI.jl                      # Commodity Channel Index
│   │   ├── ChaikinOsc.jl               # Chaikin Oscillator
│   │   ├── VWMA.jl                     # Volume Weighted MA
│   │   ├── VWAP.jl                     # Volume Weighted Average Price
│   │   ├── AO.jl                       # Awesome Oscillator
│   │   ├── ForceIndex.jl               # Force Index
│   │   ├── EMV.jl                      # Ease of Movement
│   │   ├── MassIndex.jl                # Mass Index
│   │   ├── CHOP.jl                     # Choppiness Index
│   │   ├── KVO.jl                      # Klinger Volume Oscillator
│   │   ├── UO.jl                       # Ultimate Oscillator
│   │   ├── IntradayRange.jl            # Intraday Range
│   │   ├── RelativeIntradayRange.jl    # Relative Intraday Range
│   │   ├── ADR.jl                      # Average Daily Range
│   │   ├── ARDR.jl                     # Average Relative Daily Range
│   │   │
│   │   │   # MIMO (Multiple Input, Multiple Output)
│   │   ├── Stoch.jl                    # Stochastic Oscillator
│   │   ├── ADX.jl                      # Average Directional Index
│   │   ├── SuperTrend.jl               # SuperTrend
│   │   ├── VTX.jl                      # Vortex Indicator
│   │   ├── DonchianChannels.jl         # Donchian Channels
│   │   ├── KeltnerChannels.jl          # Keltner Channels
│   │   ├── Aroon.jl                    # Aroon Indicator
│   │   ├── ChandeKrollStop.jl          # Chande Kroll Stop
│   │   ├── ParabolicSAR.jl             # Parabolic SAR
│   │   ├── SFX.jl                      # SFX Indicator
│   │   ├── TTM.jl                      # TTM Squeeze
│   │   ├── PivotsHL.jl                 # Pivot High/Low
│   │   ├── GannHiloActivator.jl        # Gann HiLo Activator
│   │   ├── GannSwingChart.jl           # Gann Swing Chart
│   │   ├── PeakValleyDetector.jl       # Peak/Valley Detection
│   │   ├── RetracementCalculator.jl    # Retracement Levels
│   │   ├── SupportResistanceLevel.jl   # Support/Resistance
│   │   │
│   │   │   # Other
│   │   └── STC.jl                      # Schaff Trend Cycle
│   │
│   ├── patterns/                       # Candlestick patterns (13)
│   │   ├── Patterns.jl                 # Submodule definition
│   │   ├── PatternTypes.jl             # Pattern type enumerations
│   │   ├── PatternValues.jl            # Pattern value structs
│   │   │
│   │   │   # Single Candle Patterns
│   │   ├── Doji.jl                     # Doji pattern
│   │   ├── Hammer.jl                   # Hammer pattern
│   │   ├── ShootingStar.jl             # Shooting Star pattern
│   │   ├── Marubozu.jl                 # Marubozu pattern
│   │   ├── SpinningTop.jl              # Spinning Top pattern
│   │   │
│   │   │   # Two Candle Patterns
│   │   ├── Engulfing.jl                # Engulfing pattern
│   │   ├── Harami.jl                   # Harami pattern
│   │   ├── PiercingDarkCloud.jl        # Piercing/Dark Cloud patterns
│   │   ├── Tweezer.jl                  # Tweezer pattern
│   │   │
│   │   │   # Three Candle Patterns
│   │   ├── Star.jl                     # Morning/Evening Star
│   │   ├── ThreeSoldiersCrows.jl       # Three Soldiers/Crows
│   │   ├── ThreeInside.jl              # Three Inside patterns
│   │   │
│   │   │   # Composite
│   │   └── CandlestickPatternDetector.jl  # All patterns detector
│   │
│   ├── wrappers/                       # Indicator wrappers
│   │   ├── Wrappers.jl                 # Submodule definition
│   │   ├── dag.jl                      # DAGWrapper for StatDAG
│   │   └── smoother.jl                 # Generic smoothing wrapper
│   │
│   ├── factories/                      # Factory functions
│   │   ├── Factories.jl                # Submodule definition
│   │   └── MovingAverage.jl            # MA factory
│   │
│   └── other/                          # Integration utilities
│       ├── arrays_indicators.jl        # Array convenience functions
│       ├── tables_indicators.jl        # Tables.jl integration
│       ├── iterators.jl                # Iterator support
│       └── tsframes.jl                 # TSFrames integration
│
├── test/                               # Test suite
│   ├── runtests.jl                     # Test entry point
│   ├── test_ohlcv.jl                   # OHLCV tests
│   ├── test_indicators_interface.jl   # Interface tests
│   ├── test_ind_single_input_single_output.jl    # SISO tests
│   ├── test_ind_single_input_several_outputs.jl  # SIMO tests
│   ├── test_ind_OHLCV_input_single_output.jl     # MISO tests
│   ├── test_ind_OHLCV_input_several_outputs.jl   # MIMO tests
│   ├── test_gann_indicators.jl         # Gann indicator tests
│   ├── test_patterns.jl                # Pattern tests
│   └── test_resample.jl                # Resampling tests
│
├── docs/                               # Documentation
│   ├── make.jl                         # Documenter.jl build script
│   ├── Project.toml                    # Docs dependencies
│   └── src/                            # Documentation source
│       ├── index.md                    # Home page
│       ├── features.md                 # Package features
│       ├── install.md                  # Installation guide
│       ├── usage.md                    # Basic usage
│       ├── usage_more.md               # Advanced usage
│       ├── indicators_support.md       # Supported indicators
│       ├── examples.md                 # Usage examples
│       ├── internals.md                # Internal details
│       ├── implementing_your_indic.md  # Custom indicator guide
│       ├── migration.md                # Migration guide
│       ├── api.md                      # API reference
│       ├── projects.md                 # Related projects
│       └── patterns/                   # Pattern documentation
│           ├── index.md                # Pattern overview
│           ├── quickstart.md           # Pattern quick start
│           └── implementation.md       # Pattern implementation
│
├── Project.toml                        # Package dependencies
├── README.md                           # Repository readme
├── LICENSE                             # License file
└── WIKI.md                             # Comprehensive documentation
```

## Key Files

### Entry Point

**`src/OnlineTechnicalIndicators.jl`** is the main module entry point. It:
1. Exports submodule names (`Candlesticks`, `Indicators`, `Patterns`, etc.)
2. Defines abstract base types (`TechnicalIndicator`, etc.)
3. Includes core utilities (`stats.jl`)
4. Includes all submodules in dependency order

### Submodule Definitions

Each submodule has a main file (e.g., `Indicators.jl`) that:
1. Imports dependencies from parent/sibling modules
2. Includes individual indicator/pattern files
3. Exports public types and functions
4. Defines `is_multi_input` for each type

### Indicator Files

Each indicator file (e.g., `SMA.jl`) contains:
1. Default parameter constants
2. Docstring with formula and usage
3. Mutable struct definition
4. Constructor functions
5. `_calculate_new_value` implementation

### Test Files

Tests are organized by indicator category:
- **SISO**: Single input, single output indicators
- **SIMO**: Single input, multiple output indicators
- **MISO**: OHLCV input, single output indicators
- **MIMO**: OHLCV input, multiple output indicators

## Module Loading Order

The main module includes files in a specific order to satisfy dependencies:

1. `stats.jl` - Core utilities
2. `candlesticks/Candlesticks.jl` - OHLCV types
3. `internals/Internals.jl` - Internal utilities
4. `sample_data.jl` - Sample data
5. `factories/MovingAverage.jl` - MA factory (needed by indicators)
6. `wrappers/dag.jl` - DAGWrapper (needed by composed indicators)
7. `indicators/Indicators.jl` - All technical indicators
8. `patterns/Patterns.jl` - All pattern detectors
9. `resample.jl` - Resampling utilities
10. `other/iterators.jl` - Iterator support
11. `wrappers/Wrappers.jl` - Re-export module
12. `factories/Factories.jl` - Re-export module

## See Also

- [Architecture](@ref) for module relationships and type hierarchy
- [Data Flow](@ref) for how data flows through indicators
