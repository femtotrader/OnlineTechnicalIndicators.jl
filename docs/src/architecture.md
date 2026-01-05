# Architecture

This page provides an overview of OnlineTechnicalIndicators.jl's architecture, including module organization and type hierarchy.

## Module Overview

OnlineTechnicalIndicators.jl is organized into several submodules, each with a specific responsibility:

```
OnlineTechnicalIndicators (main module)
├── Candlesticks     # OHLCV data structures
├── Internals        # Internal utility functions
├── Indicators       # Technical indicators (60+)
├── Patterns         # Candlestick pattern recognition
├── Wrappers         # Indicator wrappers (Smoother, DAGWrapper)
├── Factories        # Factory functions (MovingAverage)
└── SampleData       # Sample OHLCV data for testing
```

### Module Relationships

```@raw html
<pre class="mermaid">
flowchart TB
    subgraph OnlineTechnicalIndicators
        Main[OnlineTechnicalIndicators.jl]

        subgraph Submodules
            Candlesticks[Candlesticks]
            Internals[Internals]
            Indicators[Indicators]
            Patterns[Patterns]
            Wrappers[Wrappers]
            Factories[Factories]
            SampleData[SampleData]
        end

        subgraph BaseTypes["Abstract Types"]
            TI[TechnicalIndicator]
            TISO[TechnicalIndicatorSingleOutput]
            TIMO[TechnicalIndicatorMultiOutput]
            MAI[MovingAverageIndicator]
        end
    end

    subgraph External["External Dependencies"]
        OSB[OnlineStatsBase.jl]
        OSC[OnlineStatsChains.jl]
        Tables[Tables.jl]
    end

    Main --> Submodules
    TI --> OSB
    BaseTypes --> TI
    TISO --> TI
    TIMO --> TI
    MAI --> TISO

    Indicators --> BaseTypes
    Patterns --> BaseTypes
    Wrappers --> Indicators
    Factories --> Indicators
</pre>
```

## Type Hierarchy

All technical indicators inherit from a common type hierarchy rooted in `OnlineStatsBase.OnlineStat`.

### Abstract Types

```julia
# From OnlineStatsBase
abstract type OnlineStat{T} end

# Base type for all technical indicators
abstract type TechnicalIndicator{T} <: OnlineStat{T} end

# Single output indicators (e.g., SMA, RSI)
abstract type TechnicalIndicatorSingleOutput{T} <: TechnicalIndicator{T} end

# Multiple output indicators (e.g., MACD, BB)
abstract type TechnicalIndicatorMultiOutput{T} <: TechnicalIndicator{T} end

# Moving average indicators
abstract type MovingAverageIndicator{T} <: TechnicalIndicatorSingleOutput{T} end
```

### Type Hierarchy Diagram

```@raw html
<pre class="mermaid">
classDiagram
    class OnlineStat~T~ {
        &lt;&lt;OnlineStatsBase&gt;&gt;
    }

    class TechnicalIndicator~T~ {
        &lt;&lt;abstract&gt;&gt;
        +value
        +n::Int
    }

    class TechnicalIndicatorSingleOutput~T~ {
        &lt;&lt;abstract&gt;&gt;
        +value::Union Missing T
    }

    class TechnicalIndicatorMultiOutput~T~ {
        &lt;&lt;abstract&gt;&gt;
        +value::Union Missing Val
    }

    class MovingAverageIndicator~T~ {
        &lt;&lt;abstract&gt;&gt;
    }

    OnlineStat <|-- TechnicalIndicator
    TechnicalIndicator <|-- TechnicalIndicatorSingleOutput
    TechnicalIndicator <|-- TechnicalIndicatorMultiOutput
    TechnicalIndicatorSingleOutput <|-- MovingAverageIndicator
</pre>
```

## Submodule Details

### Candlesticks

Provides OHLCV (Open, High, Low, Close, Volume) data structures.

**Exports:**
- [`OHLCV`](@ref): Candlestick data structure with optional timestamp
- `OHLCVFactory`: Factory for batch OHLCV creation from vectors
- `ValueExtractor`: Module with extraction functions (`extract_open`, `extract_close`, etc.)

```julia
using OnlineTechnicalIndicators.Candlesticks

# Create a single candlestick
candle = OHLCV(100.0, 105.0, 98.0, 103.0; volume=1000.0, time=Date(2024,1,1))

# Create from vectors
factory = OHLCVFactory(opens, highs, lows, closes; volume=volumes)
candles = collect(factory)
```

### Internals

Internal utilities for indicator implementation. While exported for advanced use cases, the API may change between minor versions.

**Type Queries:**
- `is_multi_input(T)`: Check if indicator requires OHLCV input
- `is_multi_output(T)`: Check if indicator produces multiple values
- `expected_return_type(ind)`: Get return type of an indicator

**Value Utilities:**
- `has_output_value(ind)`: Check if indicator has valid output
- `has_valid_values(buf, window)`: Check circular buffer validity
- `is_valid(x)`: Check if value is not missing

**Calculation Functions:**
- `_fit!`: Internal fit function for OnlineStatsBase integration
- `_calculate_new_value`: Calculate value from internal state
- `_calculate_new_value_only_from_incoming_data`: Calculate from incoming data only

### Indicators

Contains 60+ technical indicators organized by input/output type. See [Indicators Support](@ref) for the complete list.

**Categories:**
- **SISO** (Single Input, Single Output): SMA, EMA, RSI, etc.
- **SIMO** (Single Input, Multiple Output): BB, MACD, StochRSI, KST
- **MISO** (Multiple Input, Single Output): ATR, OBV, MFI, etc.
- **MIMO** (Multiple Input, Multiple Output): Stoch, ADX, SuperTrend, etc.

### Patterns

Contains 13 candlestick pattern detectors. See [Pattern Recognition](@ref) for details.

**Categories:**
- **Single Candle**: Doji, Hammer, ShootingStar, Marubozu, SpinningTop
- **Two Candle**: Engulfing, Harami, PiercingDarkCloud, Tweezer
- **Three Candle**: Star, ThreeSoldiersCrows, ThreeInside
- **Composite**: CandlestickPatternDetector (detects all patterns)

### Wrappers

Provides wrapper types for composing indicators.

**Exports:**
- [`Smoother`](@ref): Generic wrapper that applies a moving average to any indicator's output
- `DAGWrapper`: Wrapper for StatDAG integration with `fit!` infrastructure

```julia
using OnlineTechnicalIndicators.Wrappers

# Create a smoother (applies SMA to TrueRange output)
smoother = Smoother(TrueRange; period=14, ma=SMA)

for candle in ohlcv_data
    fit!(smoother, candle)
end
```

### Factories

Factory functions for creating indicator instances.

**Exports:**
- [`MovingAverage`](@ref): Factory for creating typed moving average indicators
- `MAFactory`: Deprecated alias for `MovingAverage`

```julia
using OnlineTechnicalIndicators.Factories

factory = MovingAverage(Float64)
ma = factory(SMA, period=10)  # Creates SMA{Float64}(period=10)
```

### SampleData

Sample OHLCV data for testing and examples.

**Exports:**
- `OPEN_TMPL`, `HIGH_TMPL`, `LOW_TMPL`, `CLOSE_TMPL`, `VOLUME_TMPL`: Price/volume vectors
- `V_OHLCV`: Vector of OHLCV candlesticks
- `TAB_OHLCV`: Tables.jl-compatible sample data

```julia
using OnlineTechnicalIndicators.SampleData

candles = SampleData.V_OHLCV
prices = SampleData.CLOSE_TMPL
```

## External Dependencies

### OnlineStatsBase.jl

Provides the foundational `OnlineStat` abstract type and core utilities:
- `fit!`: Update a statistic with new data
- `value`: Get the current value
- `nobs`: Get the number of observations
- `CircBuff`: Circular buffer for rolling windows

### OnlineStatsChains.jl

Provides `StatDAG` for composing indicators into directed acyclic graphs with automatic value propagation. Used internally by composed indicators like DEMA, TEMA, T3, and TRIX.

### Tables.jl

Enables integration with any Tables.jl-compatible data source (DataFrames, CSV, etc.).

## See Also

- [Project Structure](@ref) for the directory layout
- [Data Flow](@ref) for how data flows through indicators
- [OnlineTechnicalIndicators internals](@ref) for implementation details
