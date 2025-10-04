using OnlineStatsChains

# Wrapper to integrate StatDAG with OnlineTechnicalIndicators' Series-based infrastructure
mutable struct DAGWrapper
    dag::StatDAG
    source_node::Symbol
    stats::Vector{OnlineStat}  # For compatibility checks
end

# Forward fit! calls to the DAG, which automatically propagates through filtered edges
function OnlineStatsBase.fit!(wrapper::DAGWrapper, data)
    fit!(wrapper.dag, wrapper.source_node => data)
end

Base.length(wrapper::DAGWrapper) = length(wrapper.stats)
