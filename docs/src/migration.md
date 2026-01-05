# Migration Guide

This guide helps you migrate to the new version of OnlineTechnicalIndicators.jl.

## Version 0.2.0: Module Reorganization

Version 0.2.0 reorganizes the module structure so that the main module only exports submodule names. Types and functions must now be imported from their respective submodules.

### Breaking Changes

**OHLCV and related types** are now in the `Candlesticks` submodule:

```julia
# Old (no longer works)
using OnlineTechnicalIndicators: OHLCV, OHLCVFactory, ValueExtractor

# New
using OnlineTechnicalIndicators.Candlesticks: OHLCV, OHLCVFactory, ValueExtractor
```

**Internal utility functions** are now in the `Internals` submodule with renamed functions:

```julia
# Old (no longer works)
using OnlineTechnicalIndicators: ismultiinput, ismultioutput, expected_return_type

# New
using OnlineTechnicalIndicators.Internals: is_multi_input, is_multi_output, expected_return_type
```

**`fit!` and `value`** are no longer re-exported from the main module. Import them from `OnlineStatsBase`:

```julia
# Old (no longer works)
using OnlineTechnicalIndicators: fit!, value

# New
using OnlineStatsBase: fit!, value
```

### Function Renames

| Old Name | New Name | Module |
|----------|----------|--------|
| `ismultiinput` | `is_multi_input` | `Internals` |
| `ismultioutput` | `is_multi_output` | `Internals` |

### Complete Import Examples

**Working with indicators:**
```julia
using OnlineTechnicalIndicators.Indicators: SMA, EMA, RSI
using OnlineStatsBase: fit!, value

ind = SMA{Float64}(period=10)
fit!(ind, 100.0)
println(value(ind))
```

**Working with OHLCV data:**
```julia
using OnlineTechnicalIndicators.Candlesticks: OHLCV
using OnlineTechnicalIndicators.Indicators: ATR
using OnlineStatsBase: fit!, value

candle = OHLCV(100.0, 105.0, 95.0, 102.0, volume=1000.0)
ind = ATR{OHLCV{Missing,Float64,Float64}}(period=14)
fit!(ind, candle)
```

**Working with patterns:**
```julia
using OnlineTechnicalIndicators.Candlesticks: OHLCV
using OnlineTechnicalIndicators.Patterns: Doji, SingleCandlePatternType
using OnlineStatsBase: fit!, value

candle = OHLCV(100.0, 102.0, 98.0, 100.0)
ind = Doji{OHLCV{Missing,Float64,Missing}}()
fit!(ind, candle)
result = value(ind)
```

**Custom indicator implementation:**
```julia
using OnlineTechnicalIndicators.Internals: is_multi_input, expected_return_type, has_output_value
```

---

## Migrating from `add_input_indicator!`

This section helps you migrate from the deprecated `add_input_indicator!` API to the new OnlineStatsChains-based approach using `StatDAG`.

## Why Migrate?

The library has migrated to use [OnlineStatsChains.jl](https://github.com/femtotrader/OnlineStatsChains.jl) for composing indicators. This provides:

- **Cleaner architecture**: Directed acyclic graph (DAG) structure for organizing indicator chains
- **Automatic propagation**: Filtered edges automatically skip missing values
- **Better debugging**: Named access to each stage for inspection
- **Easier composition**: Clear separation between structure and computation

The old `add_input_indicator!` function has been deprecated and will throw an error if called.

## Background: What Changed

Previously, indicators could be chained using `add_input_indicator!` which manually managed `output_listeners` and `input_indicator` fields. These fields have been removed from all indicators.

The new approach uses `OnlineStatsChains.StatDAG` with filtered edges to create indicator chains. Built-in composed indicators like `DEMA`, `TEMA`, `T3`, and `TRIX` now use this architecture internally.

## Before/After Examples

### Simple 2-Indicator Chain

**Old approach (deprecated - will throw error):**
```julia
# This NO LONGER WORKS
ema1 = EMA(period=10)
ema2 = EMA(period=10)
add_input_indicator!(ema2, ema1)  # ERROR!

# Then fitting data
for price in prices
    fit!(ema1, price)
    # ema2 would be automatically updated
end
```

**New approach (recommended):**
```julia
using OnlineStatsChains

# Create a StatDAG to organize the chain
dag = StatDAG()

# Add indicator nodes
add_node!(dag, :ema1, EMA(period=10))
add_node!(dag, :ema2, EMA(period=10))

# Connect with filtered edge - only propagates non-missing values
connect!(dag, :ema1, :ema2, filter = !ismissing)

# Fit data to the source node
for price in prices
    fit!(dag, :ema1 => price)
end

# Get values from any node
value(dag, :ema1)  # First EMA value
value(dag, :ema2)  # Second EMA value (automatically updated)
```

### Complex 3-Stage Chain (like TEMA)

**New approach for a TEMA-like chain:**
```julia
using OnlineStatsChains

dag = StatDAG()

# Add three EMA stages
add_node!(dag, :ma1, EMA(period=20))
add_node!(dag, :ma2, EMA(period=20))
add_node!(dag, :ma3, EMA(period=20))

# Connect in sequence with filtered edges
connect!(dag, :ma1, :ma2, filter = !ismissing)
connect!(dag, :ma2, :ma3, filter = !ismissing)

# Fit data
for price in prices
    fit!(dag, :ma1 => price)
end

# Access any stage
val1 = value(dag, :ma1)
val2 = value(dag, :ma2)
val3 = value(dag, :ma3)

# Compute TEMA: 3*MA1 - 3*MA2 + MA3
if !ismissing(val3)
    tema = 3.0 * val1 - 3.0 * val2 + val3
end
```

## Common StatDAG Patterns

### Basic Pattern

```julia
using OnlineStatsChains

# 1. Create the DAG
dag = StatDAG()

# 2. Add indicator nodes with symbolic names
add_node!(dag, :source, SomeIndicator(...))
add_node!(dag, :derived, AnotherIndicator(...))

# 3. Connect nodes with filtered edges
connect!(dag, :source, :derived, filter = !ismissing)

# 4. Fit data to source node
fit!(dag, :source => data)

# 5. Read values from any node
value(dag, :source)
value(dag, :derived)
```

### Using MAFactory for Flexible Moving Averages

The `MAFactory` allows you to parameterize which type of moving average is used:

```julia
using OnlineStatsChains

dag = StatDAG()

# Use MAFactory to support any MA type (EMA, SMA, WMA, etc.)
add_node!(dag, :ma1, MAFactory(Float64)(EMA, period=10))
add_node!(dag, :ma2, MAFactory(Float64)(EMA, period=10))

connect!(dag, :ma1, :ma2, filter = !ismissing)
```

## Troubleshooting

### Error: "add_input_indicator! is no longer functional"

If you see this error:
```
ERROR: add_input_indicator! is no longer functional as the required fields
(input_indicator, output_listeners) have been removed.
Use OnlineStatsChains.StatDAG to chain indicators.
```

**Solution:** Replace `add_input_indicator!` with a StatDAG-based approach as shown in the Before/After examples above.

### Migrating Custom Indicators with input_filter/input_modifier

If you have custom indicators that use `input_filter` and `input_modifier` fields, you have two options:

**Option 1: Keep legacy fields** (backward compatible)

The library still supports `input_filter` and `input_modifier` for custom indicators. If your indicator struct defines these fields, they will continue to work:

```julia
mutable struct MyCustomIndicator <: TechnicalIndicator{Float64}
    value::Union{Missing,Float64}
    n::Int
    input_filter::Function    # Legacy: still supported
    input_modifier::Function  # Legacy: still supported
    # ... other fields
end
```

**Option 2: Migrate to StatDAG** (recommended)

For better architecture and maintainability, convert to StatDAG:

```julia
# Old approach with input_filter/input_modifier
mutable struct OldIndicator <: TechnicalIndicator{Float64}
    value::Union{Missing,Float64}
    n::Int
    input_filter::Function     # e.g., x -> x > 0
    input_modifier::Function   # e.g., x -> log(x)
    sub_indicator::SomeIndicator
end

# New approach with StatDAG
mutable struct NewIndicator <: TechnicalIndicator{Float64}
    value::Union{Missing,Float64}
    n::Int
    dag::StatDAG
    sub_indicators::DAGWrapper
end

function NewIndicator()
    dag = StatDAG()
    add_node!(dag, :source, SomeIndicator())

    # Use custom filter and transform in the edge
    connect!(dag, :source, :derived,
        filter = x -> !ismissing(x) && x > 0,  # Combined filter
        transform = x -> log(x)                 # Transform function
    )

    sub_indicators = DAGWrapper(dag, :source, [dag.nodes[:source].stat])
    new(missing, 0, dag, sub_indicators)
end
```

### Common Migration Patterns

| Old Pattern | New Pattern |
|-------------|-------------|
| `add_input_indicator!(ind2, ind1)` | `connect!(dag, :ind1, :ind2, filter = !ismissing)` |
| `input_filter = x -> condition(x)` | `connect!(..., filter = x -> !ismissing(x) && condition(x))` |
| `input_modifier = x -> transform(x)` | `connect!(..., transform = x -> transform(x))` |
| `ind.output_listeners` | Not needed - edges handle propagation |
| `ind.input_indicator` | Not needed - DAG tracks connections |

## Reference Implementations

See how built-in composed indicators use StatDAG:

- **DEMA** (`src/indicators/DEMA.jl`): 2-stage MA chain
- **TEMA** (`src/indicators/TEMA.jl`): 3-stage MA chain
- **T3** (`src/indicators/T3.jl`): 6-stage MA chain with factor coefficients
- **TRIX** (`src/indicators/TRIX.jl`): 3-stage MA chain with ROC calculation

These implementations demonstrate:
- DAG structure setup
- Filtered edge connections
- DAGWrapper integration with `fit!` infrastructure
- Value computation from DAG nodes

## Need Help?

If you encounter issues during migration:

1. Check the reference implementations listed above
2. Review the [OnlineTechnicalIndicators internals](@ref) documentation for architecture details
3. Open an issue on GitHub with your specific use case
