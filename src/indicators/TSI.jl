const TSI_FAST_PERIOD = 14
const TSI_SLOW_PERIOD = 23

"""
    TSI{T}(; fast_period = TSI_FAST_PERIOD, slow_period = TSI_SLOW_PERIOD, ma = EMA)

The `TSI` type implements a True Strength Index indicator.
"""
mutable struct TSI{Tval} <: TechnicalIndicator{Tval}
    value::Union{Missing,Tval}
    n::Int

    output_listeners::Series

    fast_ma::MovingAverageIndicator
    slow_ma::MovingAverageIndicator
    
    abs_fast_ma::MovingAverageIndicator
    abs_slow_ma::MovingAverageIndicator

    input_indicator::Union{Missing,TechnicalIndicator}
    input_values::CircBuff

    function TSI{Tval}(; fast_period = TSI_FAST_PERIOD, slow_period = TSI_SLOW_PERIOD, ma = EMA) where {Tval}
        @assert fast_period < slow_period "slow_period must be greater than fast_period"

        input_values = CircBuff(Tval, 2, rev = false)

        slow_ma = MAFactory(Tval)(ma, period = slow_period)
        fast_ma = MAFactory(Union{Missing,Tval})(ma, period = fast_period, input_filter=!ismissing)
        add_input_indicator!(fast_ma, slow_ma)  # <-

        abs_slow_ma = MAFactory(Tval)(ma, period = slow_period)
        abs_fast_ma = MAFactory(Union{Missing,Tval})(ma, period = fast_period, input_filter=!ismissing)
        add_input_indicator!(abs_fast_ma, abs_slow_ma)  # <-

        output_listeners = Series()
        input_indicator = missing
        new{Tval}(
            missing,
            0,
            output_listeners,
            fast_ma,
            slow_ma,
            abs_fast_ma,
            abs_slow_ma,
            input_indicator,
            input_values,
        )
    end
end

function _calculate_new_value(ind::TSI)
    if ind.n > 1
        fit!(ind.slow_ma, ind.input_values[end] - ind.input_values[end-1])
        fit!(ind.abs_slow_ma, abs(ind.input_values[end] - ind.input_values[end-1]))

        if !has_output_value(ind.fast_ma)
            return missing
        end

        if value(ind.abs_fast_ma) != 0
            return 100.0 * (value(ind.fast_ma) / value(ind.abs_fast_ma))
        else
            return missing
        end
    else
        return missing
    end
end
