const TSI_FAST_PERIOD = 14
const TSI_SLOW_PERIOD = 23

"""
    TSI{T}(; fast_period = TSI_FAST_PERIOD, slow_period = TSI_SLOW_PERIOD, ma = EMA, input_filter = always_true, input_modifier = identity, input_modifier_return_type = T)

The `TSI` type implements a True Strength Index indicator.
"""
mutable struct TSI{Tval,IN,T2} <: TechnicalIndicatorSingleOutput{Tval}
    value::Union{Missing,T2}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    fast_ma::MovingAverageIndicator
    slow_ma::MovingAverageIndicator

    abs_fast_ma::MovingAverageIndicator
    abs_slow_ma::MovingAverageIndicator

    input_modifier::Function
    input_filter::Function
    input_values::CircBuff

    function TSI{Tval}(;
        fast_period = TSI_FAST_PERIOD,
        slow_period = TSI_SLOW_PERIOD,
        ma = EMA,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tval,
    ) where {Tval}
        @assert fast_period < slow_period "slow_period must be greater than fast_period"
        T2 = input_modifier_return_type
        input_values = CircBuff(T2, 2, rev = false)

        slow_ma = MAFactory(T2)(ma, period = slow_period)
        fast_ma = MAFactory(Union{Missing,T2})(
            ma,
            period = fast_period,
            input_filter = !ismissing,
        )
        add_input_indicator!(fast_ma, slow_ma)  # <-

        abs_slow_ma = MAFactory(T2)(ma, period = slow_period)
        abs_fast_ma = MAFactory(Union{Missing,T2})(
            ma,
            period = fast_period,
            input_filter = !ismissing,
        )
        add_input_indicator!(abs_fast_ma, abs_slow_ma)  # <-

        new{Tval,false,T2}(
            initialize_indicator_common_fields()...,
            fast_ma,
            slow_ma,
            abs_fast_ma,
            abs_slow_ma,
            input_modifier,
            input_filter,
            input_values,
        )
    end
end

function TSI(;
    fast_period = TSI_FAST_PERIOD,
    slow_period = TSI_SLOW_PERIOD,
    ma = EMA,
    input_filter = always_true,
    input_modifier = identity,
    input_modifier_return_type = Float64,
)
    TSI{input_modifier_return_type}(;
        fast_period=fast_period,
        slow_period=slow_period,
        ma=ma,
        input_filter=input_filter,
        input_modifier=input_modifier,
        input_modifier_return_type=input_modifier_return_type)
end

function _calculate_new_value(ind::TSI)
    if ind.n > 1
        fit!(ind.slow_ma, ind.input_values[end] - ind.input_values[end-1])
        fit!(ind.abs_slow_ma, abs(ind.input_values[end] - ind.input_values[end-1]))

        if !has_output_value(ind.fast_ma)
            return missing
        end

        if value(ind.abs_fast_ma) != 0
            return 100 * (value(ind.fast_ma) / value(ind.abs_fast_ma))
        else
            return missing
        end
    else
        return missing
    end
end
