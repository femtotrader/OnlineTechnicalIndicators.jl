# Package Features

## Core Functionality
- Input new data (one observation at a time) to indicator with `fit!` function (from [OnlineStats.jl](https://joshday.github.io/OnlineStats.jl/))
- Input data which inherits `AbstractVector`
- Input data as compatible [Tables.jl](https://tables.juliadata.org/) format

## Indicator Composition
- **Sub-indicators**: Indicators can be composed internally of sub-indicators
- **Indicator chaining via OnlineStatsChains**: Create complex indicator compositions using `StatDAG` with automatic value propagation through filtered edges (see [OnlineTechnicalIndicators internals](@ref) for details)
- **Moving average factory**: Parameterize indicators with different MA types (EMA, SMA, WMA, etc.)

## Legacy Features
- Filter/transform input of indicator *(legacy - use StatDAG filtered edges for new code)*
