using OnlineStatsChains

const T3_PERIOD = 5
const T3_FACTOR = 0.7

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

"""
    T3{T}(; period = T3_PERIOD, factor = T3_FACTOR, input_filter = always_true, input_modifier = identity, input_modifier_return_type = T)

The `T3` type implements a T3 Moving Average indicator using OnlineStatsChains v0.2.0 with filtered edges.

# Implementation Details
Uses OnlineStatsChains.StatDAG with filtered edges (v0.2.0 feature) to organize the 6-stage EMA chain.
Each connection uses `filter = !ismissing` to automatically skip missing values during propagation,
eliminating the need for nested conditional logic.

The DAG structure provides:
- Clear organization of the 6-stage EMA pipeline (:ema1 → :ema2 → ... → :ema6)
- Automatic propagation through filtered edges
- Named access to each stage for debugging and inspection
- Clean separation of concerns (structure vs computation)

Benefits over manual chaining:
- No nested if statements for missing value handling
- No manual fit! calls in _calculate_new_value
- Clear visualization of data flow
- Easier to modify (add/remove stages, change filters)
"""
mutable struct T3{Tval,IN,T2} <: MovingAverageIndicator{Tval}
    value::Union{Missing,T2}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    period::Int

    dag::StatDAG  # Stores EMAs with filtered edges for automatic propagation
    sub_indicators::DAGWrapper  # Wraps DAG for compatibility with fit! infrastructure

    c1::T2
    c2::T2
    c3::T2
    c4::T2

    input_modifier::Function
    input_filter::Function
    input_values::CircBuff

    function T3{Tval}(;
        period = T3_PERIOD,
        factor = T3_FACTOR,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tval,
    ) where {Tval}
        T2 = input_modifier_return_type
        input_values = CircBuff(T2, 2, rev = false)

        # Create DAG structure for the 6-stage EMA chain with filtered edges
        dag = StatDAG()
        add_node!(dag, :ema1, EMA{T2}(period = period))
        add_node!(dag, :ema2, EMA{T2}(period = period))
        add_node!(dag, :ema3, EMA{T2}(period = period))
        add_node!(dag, :ema4, EMA{T2}(period = period))
        add_node!(dag, :ema5, EMA{T2}(period = period))
        add_node!(dag, :ema6, EMA{T2}(period = period))

        # Connect with filtered edges - only propagate non-missing values
        # This enables automatic propagation without nested conditionals!
        connect!(dag, :ema1, :ema2, filter = !ismissing)
        connect!(dag, :ema2, :ema3, filter = !ismissing)
        connect!(dag, :ema3, :ema4, filter = !ismissing)
        connect!(dag, :ema4, :ema5, filter = !ismissing)
        connect!(dag, :ema5, :ema6, filter = !ismissing)

        # Wrap DAG for compatibility with existing fit! infrastructure
        sub_indicators = DAGWrapper(dag, :ema1, [dag.nodes[:ema1].stat])

        c1 = -(factor^3)
        c2 = 3 * factor^2 + 3 * factor^3
        c3 = -6 * factor^2 - 3 * factor - 3 * factor^3
        c4 = 1 + 3 * factor + factor^3 + 3 * factor^2
        new{Tval,false,T2}(
            initialize_indicator_common_fields()...,
            period,
            dag,
            sub_indicators,
            c1,
            c2,
            c3,
            c4,
            input_modifier,
            input_filter,
            input_values,
        )
    end
end

function T3(;
    period = T3_PERIOD,
    factor = T3_FACTOR,
    input_filter = always_true,
    input_modifier = identity,
    input_modifier_return_type = Float64,
)
    T3{input_modifier_return_type}(;
        period=period,
        factor=factor,
        input_filter=input_filter,
        input_modifier=input_modifier,
        input_modifier_return_type=input_modifier_return_type)
end

function _calculate_new_value(ind::T3)
    # With OnlineStatsChains v0.2.0 filtered edges, propagation is fully automatic!
    # The DAG has already propagated values through the chain via filtered edges.
    # We just read the final values and compute the T3 result.

    val6 = value(ind.dag, :ema6)
    if !ismissing(val6)
        # All EMAs have values - compute T3 from stages 3-6
        return ind.c1 * val6 +
               ind.c2 * value(ind.dag, :ema5) +
               ind.c3 * value(ind.dag, :ema4) +
               ind.c4 * value(ind.dag, :ema3)
    else
        # Not enough data yet - chain hasn't fully warmed up
        return missing
    end
end
