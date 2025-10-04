"""
Example usage of candlestick pattern recognition indicators in OnlineTechnicalIndicators.jl

This example demonstrates:
1. How to use individual pattern detectors
2. How to use the comprehensive CandlestickPatternDetector
3. How patterns work incrementally with streaming data
"""

using OnlineTechnicalIndicators
using OnlineStatsBase: value, fit!

println("=== Candlestick Pattern Recognition Examples ===\n")

# Example 1: Detecting a Doji pattern
println("Example 1: Doji Pattern Detection")
println("-"^50)

doji_detector = Doji{OHLCV{Missing,Float64,Missing}}()

# Perfect doji: open = close, symmetrical shadows
doji_candle = OHLCV(100.0, 102.0, 98.0, 100.0)
fit!(doji_detector, doji_candle)

result = value(doji_detector)
if !ismissing(result) && result.pattern != SingleCandlePatternType.NONE
    println("✓ Pattern detected: $(result.pattern)")
    println("  Direction: $(result.direction)")
    println("  Confidence: $(round(result.confidence, digits=3))")
else
    println("✗ No Doji pattern detected")
end
println()

# Example 2: Detecting Engulfing patterns
println("Example 2: Bullish Engulfing Pattern")
println("-"^50)

engulfing_detector = Engulfing{OHLCV{Missing,Float64,Missing}}()

# First candle: bearish
candle1 = OHLCV(110.0, 111.0, 105.0, 106.0)
fit!(engulfing_detector, candle1)
println(
    "Candle 1: O=$( candle1.open) H=$(candle1.high) L=$(candle1.low) C=$(candle1.close)",
)

# Second candle: bullish engulfing
candle2 = OHLCV(105.0, 115.0, 104.0, 114.0)
fit!(engulfing_detector, candle2)
println("Candle 2: O=$(candle2.open) H=$(candle2.high) L=$(candle2.low) C=$(candle2.close)")

result = value(engulfing_detector)
if !ismissing(result) && result.pattern != TwoCandlePatternType.NONE
    println("✓ Pattern detected: $(result.pattern)")
    println("  Direction: $(result.direction)")
    println("  Confidence: $(round(result.confidence, digits=3))")
else
    println("✗ No Engulfing pattern detected")
end
println()

# Example 3: Detecting Three Soldiers pattern
println("Example 3: Three White Soldiers Pattern")
println("-"^50)

soldiers_detector = ThreeSoldiersCrows{OHLCV{Missing,Float64,Missing}}()

# Three consecutive bullish candles with progressive closes
candles = [
    OHLCV(100.0, 105.0, 99.0, 104.0),
    OHLCV(103.0, 108.0, 102.0, 107.0),
    OHLCV(106.0, 111.0, 105.0, 110.0),
]

for (i, candle) in enumerate(candles)
    fit!(soldiers_detector, candle)
    println(
        "Candle $i: O=$(candle.open) H=$(candle.high) L=$(candle.low) C=$(candle.close)",
    )
end

result = value(soldiers_detector)
if !ismissing(result) && result.pattern != ThreeCandlePatternType.NONE
    println("✓ Pattern detected: $(result.pattern)")
    println("  Direction: $(result.direction)")
    println("  Confidence: $(round(result.confidence, digits=3))")
else
    println("✗ No Three Soldiers pattern detected")
end
println()

# Example 4: Using the comprehensive pattern detector
println("Example 4: Comprehensive Pattern Detection")
println("-"^50)

pattern_detector = CandlestickPatternDetector{OHLCV{Missing,Float64,Missing}}()

# Stream of candles
candle_sequence = [
    OHLCV(100.0, 105.0, 98.0, 103.0),    # Normal candle
    OHLCV(103.0, 104.0, 102.0, 103.0),   # Possible Doji
    OHLCV(100.0, 110.0, 100.0, 110.0),   # Marubozu
]

for (i, candle) in enumerate(candle_sequence)
    fit!(pattern_detector, candle)
    println(
        "\nAfter candle $i: O=$(candle.open) H=$(candle.high) L=$(candle.low) C=$(candle.close)",
    )

    result = value(pattern_detector)
    if !ismissing(result)
        if length(result.single_patterns) > 0
            println("  Single-candle patterns:")
            for pattern in result.single_patterns
                println(
                    "    - $(pattern.pattern) (confidence: $(round(pattern.confidence, digits=3)), direction: $(pattern.direction))",
                )
            end
        end

        if length(result.two_patterns) > 0
            println("  Two-candle patterns:")
            for pattern in result.two_patterns
                println(
                    "    - $(pattern.pattern) (confidence: $(round(pattern.confidence, digits=3)), direction: $(pattern.direction))",
                )
            end
        end

        if length(result.three_patterns) > 0
            println("  Three-candle patterns:")
            for pattern in result.three_patterns
                println(
                    "    - $(pattern.pattern) (confidence: $(round(pattern.confidence, digits=3)), direction: $(pattern.direction))",
                )
            end
        end

        if length(result.single_patterns) == 0 &&
           length(result.two_patterns) == 0 &&
           length(result.three_patterns) == 0
            println("  No patterns detected")
        end
    end
end
println()

# Example 5: Selective pattern detection
println("Example 5: Selective Pattern Detection")
println("-"^50)
println("Detecting only three-candle patterns:\n")

selective_detector = CandlestickPatternDetector{OHLCV{Missing,Float64,Missing}}(
    enable_single = false,
    enable_two = false,
    enable_three = true,
)

# Morning star pattern
morning_star_candles = [
    OHLCV(110.0, 111.0, 105.0, 106.0),   # Bearish
    OHLCV(104.0, 105.0, 103.0, 104.0),   # Star
    OHLCV(105.0, 112.0, 104.0, 111.0),   # Bullish
]

for (i, candle) in enumerate(morning_star_candles)
    fit!(selective_detector, candle)
    println(
        "Candle $i: O=$(candle.open) H=$(candle.high) L=$(candle.low) C=$(candle.close)",
    )
end

result = value(selective_detector)
if !ismissing(result) && length(result.three_patterns) > 0
    println("\n✓ Three-candle patterns detected:")
    for pattern in result.three_patterns
        println("  - $(pattern.pattern)")
        println("    Direction: $(pattern.direction)")
        println("    Confidence: $(round(pattern.confidence, digits=3))")
    end
else
    println("\n✗ No three-candle patterns detected")
end
println()

println("=== Examples Complete ===")
