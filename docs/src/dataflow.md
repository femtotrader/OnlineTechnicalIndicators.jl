# Data Flow

This page explains how data flows through indicators in OnlineTechnicalIndicators.jl.

## Overview

OnlineTechnicalIndicators.jl uses **online algorithms** - indicators process data one observation at a time without requiring the entire dataset in memory. This is achieved through:

1. **Circular buffers** for fixed-size rolling windows
2. **Incremental calculations** that update state efficiently
3. **Sub-indicator composition** for complex calculations

## The `fit!` Pipeline

When you call `fit!(indicator, data)`, the following sequence occurs:

```@raw html
<pre class="mermaid">
sequenceDiagram
    participant User
    participant Indicator
    participant CircBuff as CircularBuffer
    participant SubInd as Sub-Indicators
    participant Calc as _calculate_new_value

    User->>Indicator: fit!(indicator, data)

    alt Has input_filter/input_modifier (legacy)
        Indicator->>Indicator: Apply filter/modifier
    end

    alt Has input_values
        Indicator->>CircBuff: fit!(input_values, data)
        CircBuff-->>Indicator: Store in circular buffer
    end

    alt Has sub_indicators
        Indicator->>SubInd: fit!(sub_indicators, data)
        SubInd-->>Indicator: Update sub-indicator values
    end

    Indicator->>Indicator: n += 1

    alt Has input_values OR sub_indicators
        Indicator->>Calc: _calculate_new_value(ind)
    else No stored state
        Indicator->>Calc: _calculate_new_value_only_from_incoming_data(ind, data)
    end

    Calc-->>Indicator: new_value
    Indicator->>Indicator: value = new_value

    User->>Indicator: value(indicator)
    Indicator-->>User: Current indicator value
</pre>
```

### Step-by-Step Breakdown

1. **Input Filtering (Legacy)**: If the indicator has `input_filter` and `input_modifier` fields, the data is first filtered and transformed. This is a legacy mechanism - new indicators use StatDAG filtered edges instead.

2. **Circular Buffer Update**: If the indicator has an `input_values` field (a `CircBuff`), the incoming data is stored. The circular buffer automatically discards old values when full.

3. **Sub-indicator Update**: If the indicator has `sub_indicators` (a `Series` or `DAGWrapper`), the data is propagated to all sub-indicators via their own `fit!` calls.

4. **Observation Count**: The indicator's observation counter `n` is incremented.

5. **Value Calculation**: The new indicator value is calculated:
   - If the indicator maintains state (`input_values` or `sub_indicators`), `_calculate_new_value(ind)` is called
   - Otherwise, `_calculate_new_value_only_from_incoming_data(ind, data)` is called

6. **Value Storage**: The calculated value is stored in `ind.value`

## Indicator Lifecycle

### 1. Construction

When an indicator is created, it initializes:
- `value = missing` (no output yet)
- `n = 0` (no observations)
- Circular buffers with appropriate sizes
- Sub-indicators (if any)

```julia
sma = SMA{Float64}(period=14)
# sma.value = missing
# sma.n = 0
# sma.input_values = CircBuff(Float64, 15)
```

### 2. Warm-up Period

During the warm-up period, the indicator accumulates enough data to produce a valid output. Until then, `value()` returns `missing`.

```julia
sma = SMA{Float64}(period=3)

fit!(sma, 100.0)  # n=1, value=missing
fit!(sma, 101.0)  # n=2, value=missing
fit!(sma, 102.0)  # n=3, value=101.0 (warm-up complete)
```

The warm-up period depends on the indicator:
- **SMA**: `period` observations
- **EMA**: 1 observation (but stabilizes after ~`period` observations)
- **RSI**: `period + 1` observations
- **MACD**: `slow_period + signal_period - 1` observations

### 3. Active Period

After warm-up, each `fit!()` call produces a valid value:

```julia
fit!(sma, 103.0)  # n=4, value=102.0
fit!(sma, 104.0)  # n=5, value=103.0
```

### 4. Rolling Computation

Circular buffers automatically manage the rolling window:

```julia
# For SMA with period=3, buffer stores 4 values
# This enables efficient incremental calculation:
# new_sma = old_sma + (new_value - oldest_value) / period
```

## Data Flow Examples

### Single Input Indicator (SMA)

```@raw html
<pre class="mermaid">
flowchart LR
    subgraph Input
        D[data: Float64]
    end

    subgraph SMA
        CB[CircBuff<br/>stores period+1 values]
        CALC[_calculate_new_value<br/>sum/period or<br/>rolling update]
        V[value: Float64]
    end

    D --> CB
    CB --> CALC
    CALC --> V
</pre>
```

```julia
sma = SMA{Float64}(period=3)
for price in [100.0, 101.0, 102.0, 103.0]
    fit!(sma, price)
    println("n=$(sma.n), value=$(value(sma))")
end
# n=1, value=missing
# n=2, value=missing
# n=3, value=101.0
# n=4, value=102.0
```

### Multi-Input Indicator (ATR)

```@raw html
<pre class="mermaid">
flowchart LR
    subgraph Input
        OHLCV[candle: OHLCV]
    end

    subgraph ATR
        TR[TrueRange<br/>sub-indicator]
        SMMA_IND[SMMA<br/>sub-indicator]
        V[value: Float64]
    end

    OHLCV --> TR
    TR --> SMMA_IND
    SMMA_IND --> V
</pre>
```

```julia
atr = ATR{OHLCV{Missing,Float64,Float64}}(period=14)
for candle in candles
    fit!(atr, candle)
    # Internally: TrueRange calculates TR, SMMA smooths it
end
```

### Composed Indicator (DEMA via StatDAG)

```@raw html
<pre class="mermaid">
flowchart LR
    subgraph Input
        D[data: Float64]
    end

    subgraph StatDAG
        EMA1[:ema1<br/>EMA]
        EMA2[:ema2<br/>EMA]
    end

    subgraph DEMA
        CALC[_calculate_new_value<br/>2*ema1 - ema2]
        V[value: Float64]
    end

    D --> EMA1
    EMA1 -->|"filter: !ismissing"| EMA2
    EMA1 --> CALC
    EMA2 --> CALC
    CALC --> V
</pre>
```

```julia
dema = DEMA{Float64}(period=10)
for price in prices
    fit!(dema, price)
    # Internally: data flows through StatDAG
    # ema1 receives data, ema2 receives ema1's output (when not missing)
    # DEMA = 2 * ema1 - ema2
end
```

### Multi-Output Indicator (MACD)

```@raw html
<pre class="mermaid">
flowchart LR
    subgraph Input
        D[data: Float64]
    end

    subgraph MACD
        FAST[fast_ma<br/>EMA 12]
        SLOW[slow_ma<br/>EMA 26]
        SIG[signal_line<br/>EMA 9]
        CALC[_calculate_new_value]
        V[value: MACDVal]
    end

    D --> FAST
    D --> SLOW
    FAST --> CALC
    SLOW --> CALC
    CALC -->|macd line| SIG
    SIG --> CALC
    CALC --> V
</pre>
```

```julia
macd = MACD{Float64}(fast_period=12, slow_period=26, signal_period=9)
for price in prices
    fit!(macd, price)
    result = value(macd)
    if !ismissing(result)
        println("MACD: $(result.macd), Signal: $(result.signal)")
    end
end
```

## Circular Buffer Mechanics

### Basic Operation

```julia
# CircBuff with capacity 4
buffer = CircBuff(Float64, 4)

fit!(buffer, 1.0)  # [1.0, _, _, _], length=1
fit!(buffer, 2.0)  # [1.0, 2.0, _, _], length=2
fit!(buffer, 3.0)  # [1.0, 2.0, 3.0, _], length=3
fit!(buffer, 4.0)  # [1.0, 2.0, 3.0, 4.0], length=4
fit!(buffer, 5.0)  # [5.0, 2.0, 3.0, 4.0], length=4 (wraps around)

# Accessing values (logical indexing)
buffer[1]   # 2.0 (oldest)
buffer[end] # 5.0 (newest)
```

### Efficient Rolling Calculations

Instead of recalculating from scratch, many indicators use incremental updates:

```julia
# SMA rolling update
# When buffer is full and rolling:
new_value = old_value - (dropped_value - added_value) / period

# This is O(1) instead of O(period)
```

## Memory Efficiency

Online algorithms are memory-efficient because they only store what's necessary:

| Indicator | Memory Usage |
|-----------|--------------|
| SMA(14) | ~15 values (period + 1) |
| EMA(14) | ~3 values (current value + smoothing factor) |
| RSI(14) | ~2 values + 2 SMMA sub-indicators |
| MACD | ~3 EMA sub-indicators |
| ATR(14) | TrueRange + SMMA(14) |

Compare this to batch processing which would require storing all historical data.

## See Also

- [Architecture](architecture.md) for module organization
- [OnlineTechnicalIndicators internals](@ref) for implementation details
- [Implementing your own indicator](@ref) for creating custom indicators
