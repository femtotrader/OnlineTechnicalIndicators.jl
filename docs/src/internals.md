# OnlineTechnicalIndicators internals

## Sub-indicator(s)

An indicator *can* be composed *internally* of sub-indicator(s). Input values catched by `fit!` calls are transmitted to each `sub_indicators` to be processed to `_calculate_new_value` function which calculates value of indicator output.

Example: Bollinger Bands (`BB`) indicator owns 2 internal sub-indicators
- `central_band` which is a simple moving average of prices,
- `std_dev` which is standard deviation of prices.

## Composing new indicators

### Indicators Chaining with OnlineStatsChains

Indicators can be **chained together** to create complex compositions - it's like building new indicators with Lego bricks.

Examples of chained indicators:
- `DEMA` : **2** moving averages chained together
- `TEMA` : **3** moving averages chained together
- `T3` : **6** moving averages chained together
- `TRIX` : **3** moving averages chained together with ROC calculation

#### Using OnlineStatsChains StatDAG (Recommended)

The recommended way to compose indicators is using `OnlineStatsChains.StatDAG`. This provides a directed acyclic graph (DAG) structure for organizing indicator chains with automatic value propagation through filtered edges.

**Basic pattern:**

```julia
using OnlineStatsChains

# 1. Create a StatDAG
dag = StatDAG()

# 2. Add indicator nodes with symbolic names
add_node!(dag, :ema1, EMA(period=10))
add_node!(dag, :ema2, EMA(period=10))

# 3. Connect nodes with filtered edges (only propagates non-missing values)
connect!(dag, :ema1, :ema2, filter = !ismissing)

# 4. Fit data to the source node - values propagate automatically
fit!(dag, :ema1 => 100.0)

# 5. Read values from any node
value(dag, :ema1)  # First EMA value
value(dag, :ema2)  # Second EMA value (automatically updated)
```

**Benefits of StatDAG:**
- **Clear structure**: Visual organization of the indicator pipeline
- **Automatic propagation**: Values flow through filtered edges without manual handling
- **Named access**: Each stage can be inspected by name for debugging
- **Flexible composition**: Easy to add/remove stages or modify connections

#### DAGWrapper: Integration with fit! Infrastructure

The `DAGWrapper` struct provides a compatibility layer between `StatDAG` and the OnlineTechnicalIndicators' `fit!` infrastructure:

```julia
mutable struct DAGWrapper
    dag::StatDAG        # The underlying StatDAG
    source_node::Symbol # Entry point for data
    stats::Vector{OnlineStat}  # For compatibility checks
end
```

When `fit!` is called on a `DAGWrapper`, it forwards the data to the DAG's source node, which then automatically propagates values through all connected edges:

```julia
function fit!(wrapper::DAGWrapper, data)
    fit!(wrapper.dag, wrapper.source_node => data)
end
```

This allows composed indicators to use StatDAG internally while maintaining compatibility with the standard `fit!` interface.

#### Example: How DEMA Uses StatDAG

The `DEMA` (Double Exponential Moving Average) indicator demonstrates the StatDAG pattern:

**Structure:**
```
Input → :ma1 (EMA) → :ma2 (EMA) → DEMA calculation
```

**Implementation:**
```julia
# In the DEMA constructor:
dag = StatDAG()
add_node!(dag, :ma1, MAFactory(Float64)(EMA, period=period))
add_node!(dag, :ma2, MAFactory(Float64)(EMA, period=period))

# Filtered edge - only propagate non-missing values
connect!(dag, :ma1, :ma2, filter = !ismissing)

# Wrap for compatibility with fit! infrastructure
sub_indicators = DAGWrapper(dag, :ma1, [dag.nodes[:ma1].stat])
```

**How it works:**
1. When `fit!(dema, data)` is called, data flows to `sub_indicators` (the DAGWrapper)
2. DAGWrapper forwards to `dag[:ma1]`
3. The filtered edge automatically propagates to `dag[:ma2]` (if value is non-missing)
4. In `_calculate_new_value`, values are read from both nodes:

```julia
function _calculate_new_value(ind::DEMA)
    val2 = value(ind.dag, :ma2)
    if !ismissing(val2)
        # DEMA formula: 2 * MA1 - MA2
        return 2.0 * value(ind.dag, :ma1) - val2
    else
        return missing  # Chain not fully warmed up
    end
end
```

**Key insight:** The filtered edge (`filter = !ismissing`) eliminates the need for nested conditionals - propagation only happens when values are available.

For migrating from the old `add_input_indicator!` API, see the [Migration Guide](@ref).

### Filtering and Transforming Input (Legacy)

!!! warning "Legacy Feature"
    The `input_filter` and `input_modifier` mechanism described below is a **legacy feature**
    that has been superseded by StatDAG filtered edges for built-in indicators.
    It remains available only for backward compatibility with custom user-defined indicators.

    For new indicator compositions, use `OnlineStatsChains.StatDAG` with filtered edges instead.
    See the [Migration Guide](@ref) for details.

The legacy mechanism allows filtering and transforming input of an indicator using functions (typically anonymous functions). Input can be filtered/transformed before being passed to sub-indicators or processed by `_calculate_new_value`.

This mechanism still exists in the codebase for backward compatibility with custom indicators that may have implemented `input_filter` and `input_modifier` fields, but is no longer used by any built-in indicators.

### Moving average factory

- `SMA`, `EMA`, ... are moving average.

Most complex indicators uses in their **original form** SMA or EMA as default moving average.

In some markets they can perform better by using instead **an other kind of moving average**.

A **moving average factory** have been implemented 

This kind of indicators have a `ma` parameter in order to **bypass** their default moving average uses.
