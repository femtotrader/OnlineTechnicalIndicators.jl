using OnlineStatsChains

"""
    DAGWrapper

Wrapper struct that integrates OnlineStatsChains.StatDAG with OnlineTechnicalIndicators' `fit!` infrastructure.

DAGWrapper allows composed indicators (like DEMA, TEMA, T3) to use StatDAG internally while maintaining
compatibility with the standard OnlineStat `fit!` interface. When `fit!` is called on an indicator
that uses DAGWrapper, data is automatically forwarded to the DAG's source node and propagated
through all connected edges.

# Fields
- `dag::StatDAG`: The underlying OnlineStatsChains StatDAG that manages the indicator chain
- `source_node::Symbol`: The entry point node where data is fed into the DAG
- `stats::Vector{OnlineStat}`: Vector of OnlineStats for compatibility checks with Series infrastructure

# Usage Pattern

DAGWrapper is typically used internally by composed indicators:

```julia
using OnlineStatsChains

# Inside a composed indicator constructor (e.g., DEMA)
dag = StatDAG()
add_node!(dag, :ma1, EMA{Float64}(period=10))
add_node!(dag, :ma2, EMA{Float64}(period=10))
connect!(dag, :ma1, :ma2, filter = !ismissing)

# Wrap for compatibility with fit! infrastructure
sub_indicators = DAGWrapper(dag, :ma1, [dag.nodes[:ma1].stat])
```

When `fit!(indicator, data)` is called on an indicator using DAGWrapper internally,
data flows to the source node and automatically propagates through all filtered edges.

See also: [`DEMA`](@ref), [`TEMA`](@ref), [`T3`](@ref), [`TRIX`](@ref)
"""
mutable struct DAGWrapper
    dag::StatDAG
    source_node::Symbol
    stats::Vector{OnlineStat}  # For compatibility checks
end

# Forward fit! calls to the DAG, which automatically propagates through filtered edges
function OnlineStatsBase.fit!(wrapper::DAGWrapper, data)
    fit!(wrapper.dag, wrapper.source_node => data)
end

# Length method for Series infrastructure compatibility
Base.length(wrapper::DAGWrapper) = length(wrapper.stats)
