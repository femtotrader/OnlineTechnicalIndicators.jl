using OnlineStatsChains

const TSI_FAST_PERIOD = 14
const TSI_SLOW_PERIOD = 23

"""
    TSI{T}(; fast_period = TSI_FAST_PERIOD, slow_period = TSI_SLOW_PERIOD, ma = EMA, input_modifier_return_type = T)

The `TSI` type implements a True Strength Index indicator using OnlineStatsChains with filtered edges.

# Implementation Details
Uses OnlineStatsChains.StatDAG with filtered edges to organize two parallel 2-stage MA chains:
1. Price momentum chain: slow_ma → fast_ma (for momentum)
2. Absolute momentum chain: abs_slow_ma → abs_fast_ma (for normalization)

Each connection uses `filter = !ismissing` to automatically skip missing values during propagation.

The DAG structure provides:
- Clear organization of parallel MA pipelines
- Automatic propagation through filtered edges
- Named access to each stage for debugging
- Support for any moving average type via MAFactory

# Formula
TSI = 100 * (double_smoothed_momentum / double_smoothed_absolute_momentum)
where momentum = price[t] - price[t-1]
"""
mutable struct TSI{Tval,IN,T2} <: TechnicalIndicatorSingleOutput{Tval}
    value::Union{Missing,T2}
    n::Int

    dag::StatDAG  # Stores parallel MA chains with filtered edges

    input_values::CircBuff

    function TSI{Tval}(;
        fast_period = TSI_FAST_PERIOD,
        slow_period = TSI_SLOW_PERIOD,
        ma = EMA,
        input_modifier_return_type = Tval,
    ) where {Tval}
        @assert fast_period < slow_period "slow_period must be greater than fast_period"
        T2 = input_modifier_return_type
        input_values = CircBuff(T2, 2, rev = false)

        # Create DAG with two parallel 2-stage MA chains
        dag = StatDAG()

        # Momentum chain: slow_ma → fast_ma
        add_node!(dag, :slow_ma, MAFactory(T2)(ma, period = slow_period))
        add_node!(dag, :fast_ma, MAFactory(T2)(ma, period = fast_period))
        connect!(dag, :slow_ma, :fast_ma, filter = !ismissing)

        # Absolute momentum chain: abs_slow_ma → abs_fast_ma
        add_node!(dag, :abs_slow_ma, MAFactory(T2)(ma, period = slow_period))
        add_node!(dag, :abs_fast_ma, MAFactory(T2)(ma, period = fast_period))
        connect!(dag, :abs_slow_ma, :abs_fast_ma, filter = !ismissing)

        new{Tval,false,T2}(missing, 0, dag, input_values)
    end
end

function TSI(;
    fast_period = TSI_FAST_PERIOD,
    slow_period = TSI_SLOW_PERIOD,
    ma = EMA,
    input_modifier_return_type = Float64,
)
    TSI{input_modifier_return_type}(;
        fast_period = fast_period,
        slow_period = slow_period,
        ma = ma,
        input_modifier_return_type = input_modifier_return_type,
    )
end

function _calculate_new_value(ind::TSI)
    if ind.n > 1
        # Calculate momentum (price change)
        momentum = ind.input_values[end] - ind.input_values[end-1]

        # Feed into both parallel chains
        fit!(ind.dag, :slow_ma => momentum)
        fit!(ind.dag, :abs_slow_ma => abs(momentum))

        # Check if both chains have produced values
        val_fast = value(ind.dag, :fast_ma)
        val_abs_fast = value(ind.dag, :abs_fast_ma)

        if !ismissing(val_fast) && !ismissing(val_abs_fast) && val_abs_fast != 0
            return 100 * (val_fast / val_abs_fast)
        else
            return missing
        end
    else
        return missing
    end
end
