# Candlestick Pattern Recognition

OnlineTechnicalIndicators.jl includes comprehensive support for candlestick pattern recognition using an incremental (online) approach. All pattern detectors work with streaming data and maintain minimal state.

## Overview

Pattern recognition indicators detect specific candlestick formations that often signal potential market reversals or continuations. These patterns are categorized by the number of candles required:

- **Single-candle patterns**: Patterns formed by one candlestick (e.g., Doji, Hammer)
- **Two-candle patterns**: Patterns formed by two consecutive candlesticks (e.g., Engulfing, Harami)
- **Three-candle patterns**: Patterns formed by three consecutive candlesticks (e.g., Morning Star, Three White Soldiers)

## Pattern Types and Enumerations

### Single Candle Patterns

```julia
using OnlineTechnicalIndicators

# Available single-candle patterns
SingleCandlePatternType.NONE
SingleCandlePatternType.DOJI
SingleCandlePatternType.DRAGONFLY_DOJI
SingleCandlePatternType.GRAVESTONE_DOJI
SingleCandlePatternType.HAMMER
SingleCandlePatternType.HANGING_MAN
SingleCandlePatternType.SHOOTING_STAR
SingleCandlePatternType.INVERTED_HAMMER
SingleCandlePatternType.MARUBOZU_BULLISH
SingleCandlePatternType.MARUBOZU_BEARISH
SingleCandlePatternType.SPINNING_TOP
```

### Two Candle Patterns

```julia
# Available two-candle patterns
TwoCandlePatternType.NONE
TwoCandlePatternType.BULLISH_ENGULFING
TwoCandlePatternType.BEARISH_ENGULFING
TwoCandlePatternType.BULLISH_HARAMI
TwoCandlePatternType.BEARISH_HARAMI
TwoCandlePatternType.PIERCING_LINE
TwoCandlePatternType.DARK_CLOUD_COVER
TwoCandlePatternType.TWEEZER_TOP
TwoCandlePatternType.TWEEZER_BOTTOM
```

### Three Candle Patterns

```julia
# Available three-candle patterns
ThreeCandlePatternType.NONE
ThreeCandlePatternType.MORNING_STAR
ThreeCandlePatternType.EVENING_STAR
ThreeCandlePatternType.THREE_WHITE_SOLDIERS
ThreeCandlePatternType.THREE_BLACK_CROWS
ThreeCandlePatternType.THREE_INSIDE_UP
ThreeCandlePatternType.THREE_INSIDE_DOWN
```

### Pattern Direction

```julia
# Pattern direction indicates bullish, bearish, or neutral sentiment
PatternDirection.NEUTRAL
PatternDirection.BULLISH
PatternDirection.BEARISH
```

## Individual Pattern Detectors

### Doji

A Doji occurs when open and close prices are virtually equal, indicating market indecision.

```julia
doji = Doji{OHLCV{Missing,Float64,Missing}}(body_tolerance = 0.1)
fit!(doji, candle)
result = value(doji)  # Returns SingleCandlePatternVal
```

**Parameters:**
- `body_tolerance`: Maximum ratio of body to total range (default: 0.1)

**Subtypes:**
- Standard Doji: Equal open and close with shadows on both sides
- Dragonfly Doji: Long lower shadow, no upper shadow (bullish)
- Gravestone Doji: Long upper shadow, no lower shadow (bearish)

### Hammer

A Hammer is characterized by a small body at the top with a long lower shadow.

```julia
hammer = Hammer{OHLCV{Missing,Float64,Missing}}(
    body_ratio = 0.33,
    shadow_ratio = 2.0,
    upper_shadow_tolerance = 0.1
)
fit!(hammer, candle)
result = value(hammer)
```

**Parameters:**
- `body_ratio`: Maximum ratio of body to total range (default: 0.33)
- `shadow_ratio`: Minimum ratio of lower shadow to body (default: 2.0)
- `upper_shadow_tolerance`: Maximum upper shadow tolerance (default: 0.1)

### Shooting Star

A Shooting Star has a small body at the bottom with a long upper shadow.

```julia
shooting_star = ShootingStar{OHLCV{Missing,Float64,Missing}}()
fit!(shooting_star, candle)
```

### Marubozu

A Marubozu has little to no shadows, indicating strong directional momentum.

```julia
marubozu = Marubozu{OHLCV{Missing,Float64,Missing}}(shadow_tolerance = 0.05)
fit!(marubozu, candle)
```

### Spinning Top

A Spinning Top has a small body with relatively long shadows on both sides.

```julia
spinning_top = SpinningTop{OHLCV{Missing,Float64,Missing}}(
    body_ratio = 0.25,
    min_shadow_ratio = 0.3
)
fit!(spinning_top, candle)
```

### Engulfing

An Engulfing pattern occurs when one candle's body completely engulfs the previous candle's body.

```julia
engulfing = Engulfing{OHLCV{Missing,Float64,Missing}}(min_body_ratio = 1.1)

# Fit with two consecutive candles
fit!(engulfing, candle1)
fit!(engulfing, candle2)
result = value(engulfing)  # Returns TwoCandlePatternVal
```

### Harami

A Harami occurs when a small candle is contained within the previous candle's body.

```julia
harami = Harami{OHLCV{Missing,Float64,Missing}}(max_body_ratio = 0.5)
fit!(harami, candle1)
fit!(harami, candle2)
```

### Piercing Line / Dark Cloud Cover

These patterns involve 50%+ penetration of the previous candle's body.

```julia
piercing = PiercingDarkCloud{OHLCV{Missing,Float64,Missing}}(min_penetration = 0.5)
fit!(piercing, candle1)
fit!(piercing, candle2)
```

### Tweezer Top / Bottom

Tweezer patterns have matching highs (top) or lows (bottom).

```julia
tweezer = Tweezer{OHLCV{Missing,Float64,Missing}}(tolerance = 0.001)
fit!(tweezer, candle1)
fit!(tweezer, candle2)
```

### Morning Star / Evening Star

Star patterns involve three candles with a small-bodied "star" in the middle.

```julia
star = Star{OHLCV{Missing,Float64,Missing}}(
    doji_tolerance = 0.1,
    min_gap_ratio = 0.1
)
fit!(star, candle1)
fit!(star, candle2)
fit!(star, candle3)
result = value(star)  # Returns ThreeCandlePatternVal
```

### Three White Soldiers / Three Black Crows

These patterns involve three consecutive candles in the same direction with progressive closes.

```julia
soldiers = ThreeSoldiersCrows{OHLCV{Missing,Float64,Missing}}(min_progress = 0.2)
fit!(soldiers, candle1)
fit!(soldiers, candle2)
fit!(soldiers, candle3)
```

### Three Inside Up / Down

Combination of Harami followed by confirmation candle.

```julia
three_inside = ThreeInside{OHLCV{Missing,Float64,Missing}}(max_harami_ratio = 0.5)
fit!(three_inside, candle1)
fit!(three_inside, candle2)
fit!(three_inside, candle3)
```

## Comprehensive Pattern Detector

The `CandlestickPatternDetector` aggregates all pattern detectors and can detect multiple patterns simultaneously.

```julia
detector = CandlestickPatternDetector{OHLCV{Missing,Float64,Missing}}(
    enable_single = true,
    enable_two = true,
    enable_three = true
)

# Stream candles
fit!(detector, candle1)
fit!(detector, candle2)
fit!(detector, candle3)

result = value(detector)  # Returns AllPatternsVal

# Access detected patterns
for pattern in result.single_patterns
    println("Single: $(pattern.pattern), confidence: $(pattern.confidence)")
end

for pattern in result.two_patterns
    println("Two: $(pattern.pattern), confidence: $(pattern.confidence)")
end

for pattern in result.three_patterns
    println("Three: $(pattern.pattern), confidence: $(pattern.confidence)")
end
```

**Parameters:**
- `enable_single`: Enable single-candle detection (default: true)
- `enable_two`: Enable two-candle detection (default: true)
- `enable_three`: Enable three-candle detection (default: true)

## Return Values

### SingleCandlePatternVal

```julia
struct SingleCandlePatternVal{T}
    pattern::SingleCandlePattern
    confidence::T          # 0.0 to 1.0
    direction::Direction   # BULLISH, BEARISH, or NEUTRAL
end
```

### TwoCandlePatternVal

```julia
struct TwoCandlePatternVal{T}
    pattern::TwoCandlePattern
    confidence::T
    direction::Direction
end
```

### ThreeCandlePatternVal

```julia
struct ThreeCandlePatternVal{T}
    pattern::ThreeCandlePattern
    confidence::T
    direction::Direction
end
```

### AllPatternsVal

```julia
struct AllPatternsVal{S}
    single_patterns::Vector{SingleCandlePatternVal{S}}
    two_patterns::Vector{TwoCandlePatternVal{S}}
    three_patterns::Vector{ThreeCandlePatternVal{S}}
end
```

## Incremental Pattern Detection

All pattern detectors use an incremental (online) approach:

1. **Minimal State**: Each detector maintains only the necessary lookback window (1, 2, or 3 candles)
2. **Real-time Updates**: Patterns are detected as new candles arrive
3. **Confidence Scoring**: Each detected pattern includes a confidence score (0.0 to 1.0)
4. **Memory Efficient**: Uses circular buffers to store historical candles

### Example: Streaming Pattern Detection

```julia
detector = Doji{OHLCV{Missing,Float64,Missing}}()

for candle in live_candle_stream
    fit!(detector, candle)

    result = value(detector)
    if !ismissing(result) && result.pattern != SingleCandlePatternType.NONE
        println("Pattern detected: $(result.pattern)")
        println("Confidence: $(result.confidence)")
        println("Direction: $(result.direction)")
    end
end
```

## Tips and Best Practices

1. **Use with Context**: Patterns are more reliable when considered with market context (trend, volume, support/resistance)

2. **Confidence Scores**: Higher confidence scores indicate better pattern fit. Consider using thresholds:
   ```julia
   if result.confidence > 0.7
       # High-confidence pattern
   end
   ```

3. **Combine Patterns**: Use `CandlestickPatternDetector` to detect multiple patterns and look for confirmations

4. **Performance**: Individual detectors are faster. Use them if you only need specific patterns

5. **Trend Context**: Some patterns (Hammer vs Hanging Man) require trend context for proper interpretation

## Complete Example

```julia
using OnlineTechnicalIndicators

# Create detector for all patterns
detector = CandlestickPatternDetector{OHLCV{Missing,Float64,Missing}}()

# Simulate streaming data
candles = [
    OHLCV(100.0, 105.0, 98.0, 103.0),
    OHLCV(103.0, 104.0, 102.0, 103.0),  # Doji
    OHLCV(100.0, 110.0, 100.0, 110.0),  # Marubozu
]

for (i, candle) in enumerate(candles)
    fit!(detector, candle)

    result = value(detector)
    println("After candle $i:")

    # Check single-candle patterns
    for pattern in result.single_patterns
        if pattern.confidence > 0.5
            println("  $(pattern.pattern): $(pattern.direction), confidence: $(pattern.confidence)")
        end
    end

    # Check two-candle patterns
    for pattern in result.two_patterns
        if pattern.confidence > 0.5
            println("  $(pattern.pattern): $(pattern.direction), confidence: $(pattern.confidence)")
        end
    end

    # Check three-candle patterns
    for pattern in result.three_patterns
        if pattern.confidence > 0.5
            println("  $(pattern.pattern): $(pattern.direction), confidence: $(pattern.confidence)")
        end
    end
end
```

## See Also

- [OHLCV Data Structure](ohlcv.md)
- [Technical Indicators](indicators.md)
- [Examples](../examples/pattern_recognition_example.jl)
