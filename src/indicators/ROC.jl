const ROC_PERIOD = 3

"""
    ROC{T}(; period = ROC_PERIOD, input_filter = always_true, input_modifier = identity, input_modifier_return_type = T)

The `ROC` type implements a Rate Of Change indicator.
"""
mutable struct ROC{Tval,IN,T2} <: TechnicalIndicatorSingleOutput{Tval}
    value::Union{Missing,T2}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    period::Integer

    input_modifier::Function
    input_filter::Function
    input_values::CircBuff

    function ROC{Tval}(;
        period = ROC_PERIOD,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tval,
    ) where {Tval}
        T2 = input_modifier_return_type
        input_values = CircBuff(T2, period + 1, rev = false)
        new{Tval,false,T2}(
            initialize_indicator_common_fields()...,
            period,
            input_modifier,
            input_filter,
            input_values,
        )
    end
end

function ROC(;
    period = ROC_PERIOD,
    input_filter = always_true,
    input_modifier = identity,
    input_modifier_return_type = Float64,
)
    ROC{input_modifier_return_type}(;
        period=period,
        input_filter=input_filter,
        input_modifier=input_modifier,
        input_modifier_return_type=input_modifier_return_type)
end

function _calculate_new_value(ind::ROC{T,IN,S}) where {T,IN,S}
    if ind.n >= ind.period + 1
        return 100 * one(S) * (ind.input_values[end] - ind.input_values[end-ind.period]) /
               ind.input_values[end-ind.period]
    else
        return missing
    end
end
