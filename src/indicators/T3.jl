using OnlineStatsChains

const T3_PERIOD = 5
const T3_FACTOR = 0.7

"""
    T3{T}(; period = T3_PERIOD, factor = T3_FACTOR, ma = EMA, input_modifier_return_type = T)

The `T3` type implements a T3 Moving Average indicator using OnlineStatsChains v0.2.0 with filtered edges.

# Implementation Details
Uses OnlineStatsChains.StatDAG with filtered edges (v0.2.0 feature) to organize the 6-stage MA chain.
Each connection uses `filter = !ismissing` to automatically skip missing values during propagation,
eliminating the need for nested conditional logic.

The DAG structure provides:
- Clear organization of the 6-stage MA pipeline (:ma1 → :ma2 → ... → :ma6)
- Automatic propagation through filtered edges
- Named access to each stage for debugging and inspection
- Clean separation of concerns (structure vs computation)
- Support for any moving average type via MAFactory (EMA, SMA, WMA, etc.)

Benefits over manual chaining:
- No nested if statements for missing value handling
- No manual fit! calls in _calculate_new_value
- Clear visualization of data flow
- Easier to modify (add/remove stages, change filters)
"""
mutable struct T3{Tval,IN,T2} <: MovingAverageIndicator{Tval}
    value::Union{Missing,T2}
    n::Int

    period::Int

    dag::StatDAG  # Stores MAs with filtered edges for automatic propagation
    sub_indicators::DAGWrapper  # Wraps DAG for compatibility with fit! infrastructure

    c1::T2
    c2::T2
    c3::T2
    c4::T2

    input_values::CircBuff

    function T3{Tval}(;
        period = T3_PERIOD,
        factor = T3_FACTOR,
        ma = EMA,
        input_modifier_return_type = Tval,
    ) where {Tval}
        T2 = input_modifier_return_type
        input_values = CircBuff(T2, 2, rev = false)

        # Create DAG structure for the 6-stage MA chain with filtered edges
        # Use MAFactory to support any moving average type (EMA, SMA, WMA, etc.)
        dag = StatDAG()
        add_node!(dag, :ma1, MAFactory(T2)(ma, period = period))
        add_node!(dag, :ma2, MAFactory(T2)(ma, period = period))
        add_node!(dag, :ma3, MAFactory(T2)(ma, period = period))
        add_node!(dag, :ma4, MAFactory(T2)(ma, period = period))
        add_node!(dag, :ma5, MAFactory(T2)(ma, period = period))
        add_node!(dag, :ma6, MAFactory(T2)(ma, period = period))

        # Connect with filtered edges - only propagate non-missing values
        # This enables automatic propagation without nested conditionals!
        connect!(dag, :ma1, :ma2, filter = !ismissing)
        connect!(dag, :ma2, :ma3, filter = !ismissing)
        connect!(dag, :ma3, :ma4, filter = !ismissing)
        connect!(dag, :ma4, :ma5, filter = !ismissing)
        connect!(dag, :ma5, :ma6, filter = !ismissing)

        # Wrap DAG for compatibility with existing fit! infrastructure
        sub_indicators = DAGWrapper(dag, :ma1, [dag.nodes[:ma1].stat])

        c1 = -(factor^3)
        c2 = 3 * factor^2 + 3 * factor^3
        c3 = -6 * factor^2 - 3 * factor - 3 * factor^3
        c4 = 1 + 3 * factor + factor^3 + 3 * factor^2
        new{Tval,false,T2}(
            missing,  # value
            0,        # n
            period,
            dag,
            sub_indicators,
            c1,
            c2,
            c3,
            c4,
            input_values,
        )
    end
end

function T3(; period = T3_PERIOD, factor = T3_FACTOR, ma = EMA, input_modifier_return_type = Float64)
    T3{input_modifier_return_type}(;
        period = period,
        factor = factor,
        ma = ma,
        input_modifier_return_type = input_modifier_return_type,
    )
end

function _calculate_new_value(ind::T3)
    # With OnlineStatsChains v0.2.0 filtered edges, propagation is fully automatic!
    # The DAG has already propagated values through the chain via filtered edges.
    # We just read the final values and compute the T3 result.

    val6 = value(ind.dag, :ma6)
    if !ismissing(val6)
        # All MAs have values - compute T3 from stages 3-6
        return ind.c1 * val6 +
               ind.c2 * value(ind.dag, :ma5) +
               ind.c3 * value(ind.dag, :ma4) +
               ind.c4 * value(ind.dag, :ma3)
    else
        # Not enough data yet - chain hasn't fully warmed up
        return missing
    end
end
