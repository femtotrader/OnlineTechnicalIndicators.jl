# Quick Start Guide: Pattern Recognition

This guide will get you started with candlestick pattern recognition in OnlineTechnicalIndicators.jl in 5 minutes.

## Installation

The pattern recognition module is included with OnlineTechnicalIndicators.jl:

```julia
using Pkg
Pkg.add("OnlineTechnicalIndicators")
```

Or for development version:
```julia
using Pkg
Pkg.develop(path="/path/to/OnlineTechnicalIndicators")
```

## Basic Usage

### 1. Detect a Single Pattern

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

Output:
```
Pattern: DOJI
Confidence: 1.0
Direction: NEUTRAL
```

### 2. Detect All Patterns at Once

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

    # Check all detected patterns
    for pattern in result.single_patterns
        println("$(pattern.pattern): $(pattern.confidence)")
    end
end
```

### 3. Generate Trading Signals

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
    if pattern.confidence > 0.7  # High confidence
        if pattern.direction == PatternDirection.BULLISH
            println("BUY signal: $(pattern.pattern)")
        elseif pattern.direction == PatternDirection.BEARISH
            println("SELL signal: $(pattern.pattern)")
        end
    end
end
```

Output:
```
BUY signal: BULLISH_ENGULFING
```

## Available Patterns

### Single-Candle Patterns

```julia
# Doji family
doji = Doji{OHLCV{Missing,Float64,Missing}}()

# Hammer (bullish reversal)
hammer = Hammer{OHLCV{Missing,Float64,Missing}}()

# Shooting Star (bearish reversal)
shooting_star = ShootingStar{OHLCV{Missing,Float64,Missing}}()

# Marubozu (strong direction)
marubozu = Marubozu{OHLCV{Missing,Float64,Missing}}()

# Spinning Top (indecision)
spinning_top = SpinningTop{OHLCV{Missing,Float64,Missing}}()
```

### Two-Candle Patterns

```julia
# Engulfing
engulfing = Engulfing{OHLCV{Missing,Float64,Missing}}()

# Harami
harami = Harami{OHLCV{Missing,Float64,Missing}}()

# Piercing Line / Dark Cloud Cover
piercing = PiercingDarkCloud{OHLCV{Missing,Float64,Missing}}()

# Tweezer Top/Bottom
tweezer = Tweezer{OHLCV{Missing,Float64,Missing}}()
```

### Three-Candle Patterns

```julia
# Morning Star / Evening Star
star = Star{OHLCV{Missing,Float64,Missing}}()

# Three White Soldiers / Three Black Crows
soldiers = ThreeSoldiersCrows{OHLCV{Missing,Float64,Missing}}()

# Three Inside Up/Down
three_inside = ThreeInside{OHLCV{Missing,Float64,Missing}}()
```

## Pattern Types Reference

### Pattern Enums

```julia
# Single-candle patterns
SingleCandlePatternType.DOJI
SingleCandlePatternType.DRAGONFLY_DOJI
SingleCandlePatternType.GRAVESTONE_DOJI
SingleCandlePatternType.HAMMER
SingleCandlePatternType.SHOOTING_STAR
SingleCandlePatternType.MARUBOZU_BULLISH
SingleCandlePatternType.MARUBOZU_BEARISH
SingleCandlePatternType.SPINNING_TOP

# Two-candle patterns
TwoCandlePatternType.BULLISH_ENGULFING
TwoCandlePatternType.BEARISH_ENGULFING
TwoCandlePatternType.BULLISH_HARAMI
TwoCandlePatternType.BEARISH_HARAMI
TwoCandlePatternType.PIERCING_LINE
TwoCandlePatternType.DARK_CLOUD_COVER
TwoCandlePatternType.TWEEZER_TOP
TwoCandlePatternType.TWEEZER_BOTTOM

# Three-candle patterns
ThreeCandlePatternType.MORNING_STAR
ThreeCandlePatternType.EVENING_STAR
ThreeCandlePatternType.THREE_WHITE_SOLDIERS
ThreeCandlePatternType.THREE_BLACK_CROWS
ThreeCandlePatternType.THREE_INSIDE_UP
ThreeCandlePatternType.THREE_INSIDE_DOWN

# Direction
PatternDirection.BULLISH
PatternDirection.BEARISH
PatternDirection.NEUTRAL
```

## Common Patterns

### Filtering by Confidence

```julia
result = value(detector)

# Only high-confidence patterns
for pattern in result.single_patterns
    if pattern.confidence > 0.8
        println("High confidence: $(pattern.pattern)")
    end
end
```

### Filtering by Direction

```julia
result = value(detector)

# Only bullish patterns
bullish = filter(p -> p.direction == PatternDirection.BULLISH, result.single_patterns)

# Only bearish patterns
bearish = filter(p -> p.direction == PatternDirection.BEARISH, result.single_patterns)
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

## Customizing Parameters

### Doji Tolerance

```julia
# Stricter Doji detection
doji = Doji{OHLCV{Missing,Float64,Missing}}(body_tolerance = 0.05)  # 5% instead of 10%
```

### Hammer Shadow Ratio

```julia
# Require longer lower shadow
hammer = Hammer{OHLCV{Missing,Float64,Missing}}(
    shadow_ratio = 3.0,  # 3x body instead of 2x
    body_ratio = 0.25     # Smaller body
)
```

### Engulfing Minimum Ratio

```julia
# Require larger engulfing
engulfing = Engulfing{OHLCV{Missing,Float64,Missing}}(min_body_ratio = 1.5)  # 50% larger
```

## Working with Real Data

### From CSV

```julia
using CSV, DataFrames, OnlineTechnicalIndicators

# Read data
df = CSV.read("prices.csv", DataFrame)

# Create detector
detector = CandlestickPatternDetector{OHLCV{Missing,Float64,Missing}}()

# Process each row
for row in eachrow(df)
    candle = OHLCV(row.open, row.high, row.low, row.close)
    fit!(detector, candle)

    result = value(detector)
    # Process patterns...
end
```

### Live Data Stream

```julia
using OnlineTechnicalIndicators

detector = CandlestickPatternDetector{OHLCV{Missing,Float64,Missing}}()

function on_new_candle(candle)
    fit!(detector, candle)
    result = value(detector)

    # Check for high-confidence bullish patterns
    for pattern in [result.single_patterns; result.two_patterns; result.three_patterns]
        if pattern.confidence > 0.7 && pattern.direction == PatternDirection.BULLISH
            println("BUY SIGNAL: $(pattern.pattern) @ $(pattern.confidence)")
        end
    end
end

# In your data stream handler
# on_new_candle(latest_candle)
```

## Performance Tips

1. **Use Individual Detectors**: If you only need specific patterns, use individual detectors instead of `CandlestickPatternDetector` for better performance.

2. **Confidence Threshold**: Filter early with confidence thresholds to avoid processing low-quality patterns.

3. **Selective Detection**: Disable pattern categories you don't need.

4. **Pre-allocate**: Reuse detector instances instead of creating new ones.

```julia
# Good - reuse detector
detector = Doji{OHLCV{Missing,Float64,Missing}}()
for candle in candles
    fit!(detector, candle)
    # Process...
end

# Bad - create new detector each time
for candle in candles
    detector = Doji{OHLCV{Missing,Float64,Missing}}()  # Wasteful
    fit!(detector, candle)
end
```

## Next Steps

- **Full Documentation**: See [docs/src/patterns.md](docs/src/patterns.md)
- **Examples**: Check [examples/pattern_recognition_example.jl](examples/pattern_recognition_example.jl)
- **Trading Signals**: See [examples/pattern_trading_signals.jl](examples/pattern_trading_signals.jl)
- **Implementation Details**: Read [PATTERN_RECOGNITION_SUMMARY.md](PATTERN_RECOGNITION_SUMMARY.md)

## Common Issues

### Issue: Pattern not detected

**Solution**: Check confidence threshold and pattern parameters. Some patterns are rare or require specific conditions.

```julia
# Lower confidence threshold
result = value(detector)
for pattern in result.single_patterns
    if pattern.confidence > 0.5  # Lower threshold
        println(pattern)
    end
end
```

### Issue: Too many false positives

**Solution**: Increase confidence threshold or use stricter parameters.

```julia
# Higher confidence threshold
if pattern.confidence > 0.8  # Only very strong patterns
    # Process...
end

# Stricter parameters
doji = Doji{OHLCV{Missing,Float64,Missing}}(body_tolerance = 0.05)
```

### Issue: Need trend context

**Solution**: Combine with trend indicators like EMA or SuperTrend.

```julia
# Combine with trend indicator
ema = EMA{Float64}(period = 20)
doji = Doji{OHLCV{Missing,Float64,Missing}}()

for candle in candles
    fit!(ema, candle.close)
    fit!(doji, candle)

    result = value(doji)
    if result.pattern == SingleCandlePatternType.HAMMER
        trend = candle.close > value(ema) ? "UP" : "DOWN"
        println("Hammer in $trend trend")
    end
end
```

## Support

For questions or issues:
- GitHub: https://github.com/femtotrader/OnlineTechnicalIndicators.jl/issues
- Documentation: https://femtotrader.github.io/OnlineTechnicalIndicators.jl/

## References

- [Technical Analysis Explained](https://www.amazon.com/Technical-Analysis-Explained-Martin-Pring/dp/0071825177)
- [Japanese Candlestick Charting Techniques](https://www.amazon.com/Japanese-Candlestick-Charting-Techniques-Second/dp/0735201811)

---

**Happy Pattern Recognition!** 📊🕯️📈
