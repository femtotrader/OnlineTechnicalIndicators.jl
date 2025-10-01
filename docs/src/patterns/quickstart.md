# Quick Start: Pattern Recognition

Get started with candlestick pattern recognition in OnlineTechnicalIndicators.jl in 5 minutes.

## Installation

The pattern recognition module is included with OnlineTechnicalIndicators.jl:

```julia
using Pkg
Pkg.add("OnlineTechnicalIndicators")
```

## Basic Usage

### Example 1: Detect a Single Pattern

```julia
using OnlineTechnicalIndicators

# Create a Doji detector
doji = Doji{OHLCV{Missing,Float64,Missing}}()

# Create a candle (Open, High, Low, Close)
candle = OHLCV(100.0, 102.0, 98.0, 100.0)

# Detect pattern
fit!(doji, candle)
result = value(doji)

# Check result
if result.pattern != SingleCandlePatternType.NONE
    println("Pattern: $(result.pattern)")
    println("Confidence: $(result.confidence)")
    println("Direction: $(result.direction)")
end
```

**Output:**
```
Pattern: DOJI
Confidence: 1.0
Direction: NEUTRAL
```

### Example 2: Detect All Patterns

```julia
using OnlineTechnicalIndicators

# Create comprehensive detector
detector = CandlestickPatternDetector{OHLCV{Missing,Float64,Missing}}()

# Stream candles
candles = [
    OHLCV(100.0, 105.0, 98.0, 103.0),
    OHLCV(103.0, 104.0, 102.0, 103.0),  # Doji
    OHLCV(100.0, 110.0, 100.0, 110.0),  # Marubozu
]

for candle in candles
    fit!(detector, candle)
    result = value(detector)

    # Check detected patterns
    for pattern in result.single_patterns
        println("$(pattern.pattern): $(pattern.confidence)")
    end
end
```

### Example 3: Trading Signals

```julia
using OnlineTechnicalIndicators

detector = CandlestickPatternDetector{OHLCV{Missing,Float64,Missing}}()

# Bullish engulfing pattern
candle1 = OHLCV(110.0, 111.0, 105.0, 106.0)  # Bearish
candle2 = OHLCV(105.0, 115.0, 104.0, 114.0)  # Bullish engulfing

fit!(detector, candle1)
fit!(detector, candle2)

result = value(detector)

# Generate signals
for pattern in result.two_patterns
    if pattern.confidence > 0.7
        if pattern.direction == PatternDirection.BULLISH
            println("BUY signal: $(pattern.pattern)")
        elseif pattern.direction == PatternDirection.BEARISH
            println("SELL signal: $(pattern.pattern)")
        end
    end
end
```

**Output:**
```
BUY signal: BULLISH_ENGULFING
```

## Available Patterns

### Single-Candle Patterns (5 detectors, 10 patterns)

- **Doji**: Standard, Dragonfly, Gravestone
- **Hammer**: Bullish reversal
- **Shooting Star**: Bearish reversal
- **Marubozu**: Bullish/Bearish strong direction
- **Spinning Top**: Market indecision

### Two-Candle Patterns (4 detectors, 8 patterns)

- **Engulfing**: Bullish/Bearish engulfing
- **Harami**: Bullish/Bearish inside patterns
- **Piercing/Dark Cloud**: Penetration patterns
- **Tweezer**: Top/Bottom support/resistance

### Three-Candle Patterns (3 detectors, 6 patterns)

- **Star**: Morning/Evening star reversals
- **Three Soldiers/Crows**: Strong trend patterns
- **Three Inside**: Harami with confirmation

## Common Operations

### Filter by Confidence

```julia
result = value(detector)

# Only high-confidence patterns
for pattern in result.single_patterns
    if pattern.confidence > 0.8
        println("High confidence: $(pattern.pattern)")
    end
end
```

### Filter by Direction

```julia
# Only bullish patterns
bullish = filter(p -> p.direction == PatternDirection.BULLISH,
                 result.single_patterns)

# Only bearish patterns
bearish = filter(p -> p.direction == PatternDirection.BEARISH,
                 result.single_patterns)
```

### Selective Detection

```julia
# Only detect three-candle patterns (faster)
detector = CandlestickPatternDetector{OHLCV{Missing,Float64,Missing}}(
    enable_single = false,
    enable_two = false,
    enable_three = true
)
```

### Customize Parameters

```julia
# Stricter Doji detection
doji = Doji{OHLCV{Missing,Float64,Missing}}(body_tolerance = 0.05)

# Require longer hammer shadow
hammer = Hammer{OHLCV{Missing,Float64,Missing}}(
    shadow_ratio = 3.0,
    body_ratio = 0.25
)

# Larger engulfing required
engulfing = Engulfing{OHLCV{Missing,Float64,Missing}}(
    min_body_ratio = 1.5
)
```

## Next Steps

- See full [Pattern Recognition Guide](index.md) for detailed documentation
- Check [examples/pattern_recognition_example.jl](https://github.com/femtotrader/OnlineTechnicalIndicators.jl/tree/main/examples) for complete examples
- Read about [incremental processing](index.md#incremental-pattern-detection) for streaming data
