"""
    OnlineTechnicalIndicators.Wrappers

The Wrappers module provides access to wrapper/decorator types for composing indicators.

Wrapper types extend or modify the behavior of other indicators without changing
their underlying implementation. They follow the decorator pattern to add functionality
like smoothing, DAG integration, or other transformations.

# Exports
- [`Smoother`](@ref): Generic wrapper that applies a moving average to any indicator's output
- [`DAGWrapper`](@ref): Wrapper for StatDAG integration with `fit!` infrastructure

# Usage

```julia
using OnlineTechnicalIndicators.Wrappers

# Create a smoother that applies SMA(14) to TrueRange
smoother = Smoother(TrueRange; period=14, ma=SMA)

# Feed data
for candle in ohlcv_data
    fit!(smoother, candle)
end
println(value(smoother))
```

See also: [`OnlineTechnicalIndicators.Factories`](@ref)
"""
module Wrappers

# Re-export DAGWrapper from parent module
using ..OnlineTechnicalIndicators: DAGWrapper
export DAGWrapper

# Re-export Smoother from Indicators submodule
using ..Indicators: Smoother
export Smoother

end  # module
