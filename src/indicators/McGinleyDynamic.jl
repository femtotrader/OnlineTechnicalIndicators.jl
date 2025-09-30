const McGinleyDynamic_PERIOD = 14


"""
    McGinleyDynamic{T}(; period = McGinleyDynamic_PERIOD, input_filter = always_true, input_modifier = identity, input_modifier_return_type = T)

The `McGinleyDynamic` type implements a McGinley Dynamic indicator.
"""
mutable struct McGinleyDynamic{Tval,IN,T2} <: TechnicalIndicatorSingleOutput{Tval}
    value::Union{Missing,T2}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    period::Int

    rolling::Bool

    input_modifier::Function
    input_filter::Function
    input_values::CircBuff

    function McGinleyDynamic{Tval}(;
        period = McGinleyDynamic_PERIOD,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tval,
    ) where {Tval}
        T2 = input_modifier_return_type
        input_values = CircBuff(T2, period, rev = false)
        new{Tval,false,T2}(
            initialize_indicator_common_fields()...,
            period,
            false,
            input_modifier,
            input_filter,
            input_values,
        )
    end
end

function McGinleyDynamic(;
    period = McGinleyDynamic_PERIOD,
    input_filter = always_true,
    input_modifier = identity,
    input_modifier_return_type = Float64,
)
    McGinleyDynamic{input_modifier_return_type}(;
        period=period,
        input_filter=input_filter,
        input_modifier=input_modifier,
        input_modifier_return_type=input_modifier_return_type)
end

function _calculate_new_value(ind::McGinleyDynamic)
    if ind.rolling  # CircBuff is full and rolling
        val = ind.input_values[end]
        return value(ind) + (val - value(ind)) / (ind.period * (val / value(ind))^4)
    else
        if ind.n == ind.period # CircBuff is full but not rolling
            ind.rolling = true
            return sum(ind.input_values.value) / ind.period
        else  # CircBuff is filling up
            return missing
        end
    end
end
