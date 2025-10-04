using OnlineStatsChains

const TRIX_PERIOD = 10

"""
    TRIX{T}(; period = TRIX_PERIOD, ma = EMA, input_filter = always_true, input_modifier = identity, input_modifier_return_type = T)

The `TRIX` type implements a TRIX Moving Average indicator using OnlineStatsChains v0.2.0 with filtered edges.

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
TRIX = 10000 * (MA3_current - MA3_previous) / MA3_previous
where MA1 is the MA of price, MA2 is the MA of MA1, and MA3 is the MA of MA2.
The type of moving average (EMA, SMA, etc.) is specified by the `ma` parameter.
The result is expressed as a percentage rate of change (* 10000 for basis points).
"""
mutable struct TRIX{Tval,IN,T2} <: MovingAverageIndicator{Tval}
    value::Union{Missing,T2}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    output_history::CircBuff

    period::Int

    dag::StatDAG  # Stores EMAs with filtered edges for automatic propagation
    sub_indicators::DAGWrapper  # Wraps DAG for compatibility with fit! infrastructure

    input_modifier::Function
    input_filter::Function
    input_values::CircBuff

    function TRIX{Tval}(;
        period = TRIX_PERIOD,
        ma = EMA,
        input_filter = always_true,
        input_modifier = identity,
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

        output_history = CircBuff(T2, 2, rev = false)

        new{Tval,false,T2}(
            initialize_indicator_common_fields()...,
            output_history,
            period,
            dag,
            sub_indicators,
            input_modifier,
            input_filter,
            input_values,
        )
    end
end

function TRIX(;
    period = TRIX_PERIOD,
    ma = EMA,
    input_filter = always_true,
    input_modifier = identity,
    input_modifier_return_type = Float64,
)
    TRIX{input_modifier_return_type}(;
        period=period,
        ma=ma,
        input_filter=input_filter,
        input_modifier=input_modifier,
        input_modifier_return_type=input_modifier_return_type)
end

function _calculate_new_value(ind::TRIX)
    # With OnlineStatsChains v0.2.0 filtered edges, propagation is fully automatic!
    # The DAG has already propagated values through the chain via filtered edges.
    # We just read the final MA3 value and compute the rate of change.

    val3 = value(ind.dag, :ma3)
    if !ismissing(val3)
        # Store MA3 value in history
        fit!(ind.output_history, val3)
        if length(ind.output_history.value) == 2
            # Calculate rate of change: (current - previous) / previous * 10000
            return 10000 * (ind.output_history[end] - ind.output_history[end-1]) /
                   ind.output_history[end-1]
        else
            return missing
        end
    else
        # Not enough data yet - chain hasn't fully warmed up
        return missing
    end
end
