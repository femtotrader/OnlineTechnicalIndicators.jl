using OnlineStatsChains

const TEMA_PERIOD = 20

"""
    TEMA{T}(; period = TEMA_PERIOD, ma = EMA, input_modifier_return_type = T)

The `TEMA` type implements a Triple Exponential Moving Average indicator using OnlineStatsChains v0.2.0 with filtered edges.

# Implementation Details
Uses OnlineStatsChains.StatDAG with filtered edges (v0.2.0 feature) to organize the 3-stage MA chain.
Each connection uses `filter = !ismissing` to automatically skip missing values during propagation,
eliminating the need for nested conditional logic.

The DAG structure provides:
- Clear organization of the 3-stage MA pipeline (:ma1 → :ma2 → :ma3)
- Automatic propagation through filtered edges
- Named access to each stage for debugging and inspection
- Clean separation of concerns (structure vs computation)
- Support for any moving average type via MAFactory (EMA, SMA, WMA, etc.)

Benefits over manual chaining:
- No nested if statements for missing value handling
- No manual fit! calls in _calculate_new_value
- Clear visualization of data flow
- Easier to modify (add/remove stages, change filters)

# Formula
TEMA = 3 * MA1 - 3 * MA2 + MA3
where MA1 is the MA of price, MA2 is the MA of MA1, and MA3 is the MA of MA2.
The type of moving average (EMA, SMA, etc.) is specified by the `ma` parameter.
"""
mutable struct TEMA{Tval,IN,T2} <: MovingAverageIndicator{Tval}
    value::Union{Missing,T2}
    n::Int

    period::Integer

    dag::StatDAG  # Stores EMAs with filtered edges for automatic propagation
    sub_indicators::DAGWrapper  # Wraps DAG for compatibility with fit! infrastructure

    input_values::CircBuff

    function TEMA{Tval}(;
        period = TEMA_PERIOD,
        ma = EMA,
        input_modifier_return_type = Tval,
    ) where {Tval}
        T2 = input_modifier_return_type
        input_values = CircBuff(T2, 2, rev = false)

        # Create DAG structure for the 3-stage MA chain with filtered edges
        # Use MAFactory to support any moving average type (EMA, SMA, WMA, etc.)
        dag = StatDAG()
        add_node!(dag, :ma1, MAFactory(T2)(ma, period = period))
        add_node!(dag, :ma2, MAFactory(T2)(ma, period = period))
        add_node!(dag, :ma3, MAFactory(T2)(ma, period = period))

        # Connect with filtered edges - only propagate non-missing values
        # This enables automatic propagation without nested conditionals!
        connect!(dag, :ma1, :ma2, filter = !ismissing)
        connect!(dag, :ma2, :ma3, filter = !ismissing)

        # Wrap DAG for compatibility with existing fit! infrastructure
        sub_indicators = DAGWrapper(dag, :ma1, [dag.nodes[:ma1].stat])

        new{Tval,false,T2}(
            missing,  # value
            0,        # n
            period,
            dag,
            sub_indicators,
            input_values,
        )
    end
end

function TEMA(;
    period = TEMA_PERIOD,
    ma = EMA,
    input_modifier_return_type = Float64,
)
    TEMA{input_modifier_return_type}(;
        period=period,
        ma=ma,
        input_modifier_return_type=input_modifier_return_type)
end

function _calculate_new_value(ind::TEMA)
    # With OnlineStatsChains v0.2.0 filtered edges, propagation is fully automatic!
    # The DAG has already propagated values through the chain via filtered edges.
    # We just read the final values and compute the TEMA result.

    val3 = value(ind.dag, :ma3)
    if !ismissing(val3)
        # All MAs have values - compute TEMA: 3*MA1 - 3*MA2 + MA3
        return 3.0 * value(ind.dag, :ma1) - 3.0 * value(ind.dag, :ma2) + val3
    else
        # Not enough data yet - chain hasn't fully warmed up
        return missing
    end
end
