"""
Advanced Pattern Recognition Example: Trading Signals

This example demonstrates how to use pattern recognition indicators to generate
trading signals by combining multiple patterns and filtering by confidence.
"""

using OnlineTechnicalIndicators
using OnlineStatsBase: value, fit!

println("=== Trading Signal Generation with Pattern Recognition ===\n")

# Define a simple signal type
@enum Signal BUY SELL HOLD

# Structure to hold trading signals
struct TradingSignal
    signal::Signal
    pattern_name::String
    confidence::Float64
    direction::String
end

# Function to generate trading signals from pattern detection
function generate_signal(
    result::AllPatternsVal,
    min_confidence::Float64 = 0.6,
)::Vector{TradingSignal}
    signals = TradingSignal[]

    # Process single-candle patterns
    for pattern in result.single_patterns
        if pattern.confidence >= min_confidence
            signal = if pattern.direction == PatternDirection.BULLISH
                BUY
            elseif pattern.direction == PatternDirection.BEARISH
                SELL
            else
                HOLD
            end

            push!(
                signals,
                TradingSignal(
                    signal,
                    string(pattern.pattern),
                    pattern.confidence,
                    string(pattern.direction),
                ),
            )
        end
    end

    # Process two-candle patterns (usually stronger signals)
    for pattern in result.two_patterns
        if pattern.confidence >= min_confidence
            signal = if pattern.direction == PatternDirection.BULLISH
                BUY
            elseif pattern.direction == PatternDirection.BEARISH
                SELL
            else
                HOLD
            end

            push!(
                signals,
                TradingSignal(
                    signal,
                    string(pattern.pattern),
                    pattern.confidence,
                    string(pattern.direction),
                ),
            )
        end
    end

    # Process three-candle patterns (strongest signals)
    for pattern in result.three_patterns
        if pattern.confidence >= min_confidence
            signal = if pattern.direction == PatternDirection.BULLISH
                BUY
            elseif pattern.direction == PatternDirection.BEARISH
                SELL
            else
                HOLD
            end

            push!(
                signals,
                TradingSignal(
                    signal,
                    string(pattern.pattern),
                    pattern.confidence,
                    string(pattern.direction),
                ),
            )
        end
    end

    return signals
end

# Simulated price data for a bullish reversal scenario
println("Scenario 1: Bullish Reversal Detection")
println("-"^70)

candles_bullish = [
    # Downtrend
    OHLCV(120.0, 121.0, 115.0, 116.0),
    OHLCV(116.0, 117.0, 112.0, 113.0),
    OHLCV(113.0, 114.0, 109.0, 110.0),
    # Potential hammer (bullish reversal)
    OHLCV(110.0, 111.0, 105.0, 109.5),
    # Confirmation
    OHLCV(109.0, 115.0, 108.0, 114.0),
    # Bullish engulfing
    OHLCV(114.0, 118.0, 113.0, 117.5),
]

detector = CandlestickPatternDetector{OHLCV{Missing,Float64,Missing}}()

for (i, candle) in enumerate(candles_bullish)
    fit!(detector, candle)
    println(
        "Candle $i: O=$(candle.open) H=$(candle.high) L=$(candle.low) C=$(candle.close)",
    )

    result = value(detector)
    signals = generate_signal(result, 0.5)  # 50% minimum confidence

    if !isempty(signals)
        println("  📊 Signals Generated:")
        for sig in signals
            emoji = sig.signal == BUY ? "📈" : (sig.signal == SELL ? "📉" : "⏸️")
            println(
                "     $emoji $(sig.signal): $(sig.pattern_name) ($(round(sig.confidence * 100, digits=1))% confidence, $(sig.direction))",
            )
        end
    end
end
println()

# Simulated price data for a bearish reversal scenario
println("Scenario 2: Bearish Reversal Detection")
println("-"^70)

candles_bearish = [
    # Uptrend
    OHLCV(100.0, 105.0, 99.0, 104.0),
    OHLCV(104.0, 108.0, 103.0, 107.0),
    OHLCV(107.0, 111.0, 106.0, 110.0),
    # Shooting star (bearish reversal)
    OHLCV(110.0, 115.0, 109.0, 110.5),
    # Confirmation with dark cloud cover
    OHLCV(111.0, 112.0, 106.0, 107.0),
    # Bearish continuation
    OHLCV(107.0, 108.0, 102.0, 103.0),
]

detector2 = CandlestickPatternDetector{OHLCV{Missing,Float64,Missing}}()

for (i, candle) in enumerate(candles_bearish)
    fit!(detector2, candle)
    println(
        "Candle $i: O=$(candle.open) H=$(candle.high) L=$(candle.low) C=$(candle.close)",
    )

    result = value(detector2)
    signals = generate_signal(result, 0.5)

    if !isempty(signals)
        println("  📊 Signals Generated:")
        for sig in signals
            emoji = sig.signal == BUY ? "📈" : (sig.signal == SELL ? "📉" : "⏸️")
            println(
                "     $emoji $(sig.signal): $(sig.pattern_name) ($(round(sig.confidence * 100, digits=1))% confidence, $(sig.direction))",
            )
        end
    end
end
println()

# Simulated consolidation/indecision scenario
println("Scenario 3: Market Indecision Detection")
println("-"^70)

candles_indecision = [
    OHLCV(105.0, 107.0, 103.0, 105.5),
    # Doji - indecision
    OHLCV(105.5, 107.0, 104.0, 105.5),
    # Spinning top - indecision
    OHLCV(105.5, 108.0, 103.0, 106.0),
    # Another spinning top
    OHLCV(106.0, 108.5, 104.0, 105.5),
]

detector3 = CandlestickPatternDetector{OHLCV{Missing,Float64,Missing}}()

for (i, candle) in enumerate(candles_indecision)
    fit!(detector3, candle)
    println(
        "Candle $i: O=$(candle.open) H=$(candle.high) L=$(candle.low) C=$(candle.close)",
    )

    result = value(detector3)
    signals = generate_signal(result, 0.5)

    if !isempty(signals)
        println("  📊 Signals Generated:")
        for sig in signals
            emoji = sig.signal == BUY ? "📈" : (sig.signal == SELL ? "📉" : "⏸️")
            println(
                "     $emoji $(sig.signal): $(sig.pattern_name) ($(round(sig.confidence * 100, digits=1))% confidence, $(sig.direction))",
            )
        end
    end
end
println()

# Advanced: Signal aggregation and consensus
println("Scenario 4: Signal Consensus Analysis")
println("-"^70)

# Morning star pattern (strong bullish reversal)
morning_star = [
    OHLCV(110.0, 111.0, 105.0, 106.0),  # Bearish
    OHLCV(104.0, 105.0, 103.0, 104.0),  # Star
    OHLCV(105.0, 112.0, 104.0, 111.0),  # Bullish
]

detector4 = CandlestickPatternDetector{OHLCV{Missing,Float64,Missing}}()
all_signals = TradingSignal[]

for (i, candle) in enumerate(morning_star)
    fit!(detector4, candle)
    println(
        "Candle $i: O=$(candle.open) H=$(candle.high) L=$(candle.low) C=$(candle.close)",
    )

    result = value(detector4)
    signals = generate_signal(result, 0.5)
    append!(all_signals, signals)

    if !isempty(signals)
        println("  📊 Signals Generated:")
        for sig in signals
            emoji = sig.signal == BUY ? "📈" : (sig.signal == SELL ? "📉" : "⏸️")
            println(
                "     $emoji $(sig.signal): $(sig.pattern_name) ($(round(sig.confidence * 100, digits=1))% confidence, $(sig.direction))",
            )
        end
    end
end

# Analyze consensus
println("\n  🎯 Signal Consensus Analysis:")
buy_signals = count(s -> s.signal == BUY, all_signals)
sell_signals = count(s -> s.signal == SELL, all_signals)
hold_signals = count(s -> s.signal == HOLD, all_signals)
avg_confidence =
    isempty(all_signals) ? 0.0 :
    sum(s.confidence for s in all_signals) / length(all_signals)

println("     Total Signals: $(length(all_signals))")
println("     BUY signals: $buy_signals")
println("     SELL signals: $sell_signals")
println("     HOLD signals: $hold_signals")
println("     Average Confidence: $(round(avg_confidence * 100, digits=1))%")

if buy_signals > sell_signals && avg_confidence > 0.6
    println("     ✅ STRONG BUY CONSENSUS")
elseif sell_signals > buy_signals && avg_confidence > 0.6
    println("     ❌ STRONG SELL CONSENSUS")
elseif hold_signals > buy_signals + sell_signals
    println("     ⏸️  HOLD - MARKET INDECISION")
else
    println("     ⚠️  MIXED SIGNALS - NO CLEAR CONSENSUS")
end

println("\n=== Trading Signal Generation Complete ===")
println("\n💡 Tips:")
println("  1. Use higher confidence thresholds (>0.7) for stronger signals")
println("  2. Combine patterns with trend indicators for better accuracy")
println("  3. Three-candle patterns are typically more reliable than single-candle")
println("  4. Always use stop-losses and risk management")
println("  5. Pattern recognition is one tool - use with other analysis methods")
