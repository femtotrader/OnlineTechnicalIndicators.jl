# Candlestick Pattern Recognition Module

This directory contains the implementation of candlestick pattern recognition indicators for OnlineTechnicalIndicators.jl.

## Architecture

### Core Components

1. **PatternTypes.jl** - Defines enumerations for all pattern types
   - `SingleCandlePatternType`: Enumerations for single-candle patterns
   - `TwoCandlePatternType`: Enumerations for two-candle patterns
   - `ThreeCandlePatternType`: Enumerations for three-candle patterns
   - `PatternDirection`: Direction enumeration (BULLISH, BEARISH, NEUTRAL)

2. **PatternValues.jl** - Return value types for pattern detectors
   - `SingleCandlePatternVal{T}`: Return type for single-candle patterns
   - `TwoCandlePatternVal{T}`: Return type for two-candle patterns
   - `ThreeCandlePatternVal{T}`: Return type for three-candle patterns
   - `AllPatternsVal{T}`: Aggregated return type for CandlestickPatternDetector

### Pattern Detectors

#### Single-Candle Patterns

- **Doji.jl** - Detects Doji patterns (open ≈ close)
  - Standard Doji
  - Dragonfly Doji (long lower shadow)
  - Gravestone Doji (long upper shadow)

- **Hammer.jl** - Detects Hammer patterns
  - Small body at top
  - Long lower shadow (≥2x body)
  - Minimal upper shadow

- **ShootingStar.jl** - Detects Shooting Star patterns
  - Small body at bottom
  - Long upper shadow (≥2x body)
  - Minimal lower shadow

- **Marubozu.jl** - Detects Marubozu patterns
  - Bullish Marubozu (no/minimal shadows, close at high)
  - Bearish Marubozu (no/minimal shadows, close at low)

- **SpinningTop.jl** - Detects Spinning Top patterns
  - Small body (≤25% of range)
  - Long shadows on both sides

#### Two-Candle Patterns

- **Engulfing.jl** - Detects Engulfing patterns
  - Bullish Engulfing (up candle engulfs down candle)
  - Bearish Engulfing (down candle engulfs up candle)

- **Harami.jl** - Detects Harami patterns
  - Bullish Harami (small candle inside large down candle)
  - Bearish Harami (small candle inside large up candle)

- **PiercingDarkCloud.jl** - Detects Piercing Line and Dark Cloud Cover
  - Piercing Line (up candle closes above 50% of down candle)
  - Dark Cloud Cover (down candle closes below 50% of up candle)

- **Tweezer.jl** - Detects Tweezer patterns
  - Tweezer Top (matching highs)
  - Tweezer Bottom (matching lows)

#### Three-Candle Patterns

- **Star.jl** - Detects Star patterns
  - Morning Star (bearish + star + bullish)
  - Evening Star (bullish + star + bearish)

- **ThreeSoldiersCrows.jl** - Detects three-consecutive-candle patterns
  - Three White Soldiers (three bullish with progressive closes)
  - Three Black Crows (three bearish with progressive closes)

- **ThreeInside.jl** - Detects Three Inside patterns
  - Three Inside Up (Harami + bullish confirmation)
  - Three Inside Down (Harami + bearish confirmation)

#### Comprehensive Detector

- **CandlestickPatternDetector.jl** - Aggregates all pattern detectors
  - Detects all patterns simultaneously
  - Returns `AllPatternsVal` with all detected patterns
  - Configurable to enable/disable pattern categories

## Design Principles

### 1. Incremental/Online Processing

All pattern detectors use an incremental approach:
- Maintain minimal state (1-3 candles via `CircBuff`)
- Process one candle at a time with `fit!()`
- No need to reprocess entire history

### 2. Type Safety

- Strong typing with Julia's type system
- Enums for pattern types prevent invalid states
- Parametric types for price precision

### 3. Confidence Scoring

Each pattern includes a confidence score (0.0 to 1.0):
- Based on how well the pattern matches ideal characteristics
- Allows filtering low-quality patterns
- Considers factors like body ratios, shadow lengths, etc.

### 4. Consistent Interface

All detectors follow the same interface:
```julia
detector = Pattern{OHLCV{Missing,Float64,Missing}}(parameters...)
fit!(detector, candle)
result = value(detector)
```

### 5. Direction Indication

Each pattern specifies its directional bias:
- `BULLISH`: Indicates potential upward movement
- `BEARISH`: Indicates potential downward movement
- `NEUTRAL`: Indicates indecision/consolidation

## Usage Examples

### Single Pattern Detection

```julia
using OnlineTechnicalIndicators

# Detect Doji patterns
doji = Doji{OHLCV{Missing,Float64,Missing}}()
fit!(doji, candle)

result = value(doji)
if result.pattern != SingleCandlePatternType.NONE
    println("Doji detected with confidence: $(result.confidence)")
end
```

### Comprehensive Detection

```julia
# Detect all patterns
detector = CandlestickPatternDetector{OHLCV{Missing,Float64,Missing}}()

for candle in candle_stream
    fit!(detector, candle)
    result = value(detector)

    # Process detected patterns
    for pattern in result.single_patterns
        println("$(pattern.pattern): $(pattern.confidence)")
    end
end
```

### Selective Detection

```julia
# Only detect three-candle patterns
detector = CandlestickPatternDetector{OHLCV{Missing,Float64,Missing}}(
    enable_single = false,
    enable_two = false,
    enable_three = true
)
```

## Implementation Details

### CircBuff Usage

Each pattern detector uses `CircBuff` to maintain lookback windows:
- Single-candle: `CircBuff(OHLCV, 1)`
- Two-candle: `CircBuff(OHLCV, 2)`
- Three-candle: `CircBuff(OHLCV, 3)`

This ensures:
- O(1) memory usage
- O(1) insertion time
- Efficient access to recent candles

### Confidence Calculation

Confidence scores are calculated based on multiple factors:

**Example (Hammer):**
```julia
shadow_confidence = min(shadow_to_body_ratio / (threshold * 2), 1.0)
body_confidence = 1.0 - (body_to_range / max_body_ratio)
upper_confidence = 1.0 - (upper_to_range / tolerance)
confidence = (shadow_confidence + body_confidence + upper_confidence) / 3
```

### Pattern Validation

Each detector validates:
1. Sufficient candles received (`ind.n >= required_candles`)
2. Non-zero ranges/bodies (avoid division by zero)
3. Pattern criteria met
4. Returns `missing` or `NONE` pattern if invalid

## Testing

Comprehensive tests are available in `test/test_patterns.jl`:
- Individual pattern detection
- Confidence scoring validation
- Incremental processing verification
- Edge cases and boundary conditions

Run tests:
```bash
julia --project=. test/test_patterns.jl
```

## Performance Considerations

- **Memory**: O(1) per detector (fixed lookback window)
- **Time**: O(1) per candle processed
- **Scalability**: Can process millions of candles in streaming fashion

### Benchmarks (approximate)

- Single pattern detector: ~100-500 ns per candle
- Comprehensive detector: ~1-5 μs per candle (all patterns)
- Memory per detector: ~1-3 KB

## Future Enhancements

Potential additions:
1. Chart patterns (Head & Shoulders, Triangles, etc.)
2. Volume-weighted pattern confidence
3. Trend context integration
4. Pattern invalidation tracking
5. Multi-timeframe pattern detection

## References

- [Candlestick Charting Explained by Gregory Morris](https://www.amazon.com/Candlestick-Charting-Explained-Gregory-Morris/dp/0071444343)
- [Japanese Candlestick Charting Techniques by Steve Nison](https://www.amazon.com/Japanese-Candlestick-Charting-Techniques-Second/dp/0735201811)
- [Technical Analysis of the Financial Markets by John Murphy](https://www.amazon.com/Technical-Analysis-Financial-Markets-Comprehensive/dp/0735200661)

## Contributing

When adding new pattern detectors:
1. Add enum to `PatternTypes.jl`
2. Create detector file following naming convention
3. Implement `_calculate_new_value` method
4. Add to `PATTERN_INDICATORS` in main module
5. Add `ismultiinput` declaration
6. Write tests in `test_patterns.jl`
7. Update documentation

See existing detectors for reference implementation.
