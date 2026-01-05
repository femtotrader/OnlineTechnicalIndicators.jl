"""
    Candlesticks

Submodule containing candlestick/OHLCV data structures and utilities.

# Exports
- `OHLCV`: Candlestick data structure (Open, High, Low, Close, Volume, Time)
- `OHLCVFactory`: Factory for creating OHLCV instances from vectors
- `ValueExtractor`: Module with functions to extract values from candlesticks

# Example
```julia
using OnlineTechnicalIndicators.Candlesticks: OHLCV, OHLCVFactory

# Create a single candlestick
candle = OHLCV(100.0, 105.0, 98.0, 103.0; volume=1000.0)

# Create multiple candlesticks from vectors
factory = OHLCVFactory(opens, highs, lows, closes; volume=volumes)
candles = collect(factory)
```
"""
module Candlesticks

export OHLCV, OHLCVFactory, ValueExtractor

include("ohlcv.jl")

end # module Candlesticks
