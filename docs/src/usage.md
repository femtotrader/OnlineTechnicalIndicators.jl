# Usage

## Quick Start

```julia
# Import indicators from the Indicators submodule
using OnlineTechnicalIndicators.Indicators: SMA, EMA, RSI
using OnlineStatsBase: fit!, value

# Create an indicator
ind = SMA{Float64}(period=10)

# Feed data
prices = [100.0, 101.0, 102.0, 101.5, 103.0, 102.5, 104.0, 103.5, 105.0, 104.5]
for price in prices
    fit!(ind, price)
end

# Get the current value
println(value(ind))  # 102.6
```

## Working with OHLCV Data

```julia
using OnlineTechnicalIndicators.Candlesticks: OHLCV
using OnlineTechnicalIndicators.Indicators: ATR
using OnlineStatsBase: fit!, value

# Create OHLCV candle
candle = OHLCV(100.0, 105.0, 95.0, 102.0, volume=1000.0)

# Create indicator for OHLCV input
ind = ATR{OHLCV{Missing,Float64,Float64}}(period=14)
fit!(ind, candle)
```

## Module Structure

OnlineTechnicalIndicators.jl exports only submodule names. Import types and functions from the appropriate submodule:

- **`Candlesticks`**: OHLCV types (`OHLCV`, `OHLCVFactory`, `ValueExtractor`)
- **`Indicators`**: All technical indicators (`SMA`, `EMA`, `RSI`, `MACD`, etc.)
- **`Patterns`**: Candlestick pattern recognition (`Doji`, `Hammer`, `Engulfing`, etc.)
- **`Internals`**: Utility functions for custom indicator implementation
- **`Wrappers`**: Indicator composition utilities (`Smoother`, `DAGWrapper`)
- **`Factories`**: Factory functions for creating indicators (`MovingAverage`)
- **`SampleData`**: Sample data for testing

See the [Migration Guide](@ref) for details on the new import patterns.

## Resources

See [examples](https://github.com/femtotrader/OnlineTechnicalIndicators.jl/tree/main/examples) and [tests](https://github.com/femtotrader/OnlineTechnicalIndicators.jl/tree/main/test)

OnlineTechnicalIndicators.jl - installing and using it

[![OnlineTechnicalIndicators.jl - installing and using it](http://img.youtube.com/vi/UqHEMi8pCyc/0.jpg)](http://www.youtube.com/watch?v=UqHEMi8pCyc "OnlineTechnicalIndicators.jl - installing and using it")

OnlineTechnicalIndicators.jl - dealing with TSFrames

[![OnlineTechnicalIndicators.jl - dealing with TSFrames](http://img.youtube.com/vi/gmR1QvISiLA/0.jpg)](http://www.youtube.com/watch?v=gmR1QvISiLA "OnlineTechnicalIndicators.jl - dealing with TSFrames")
