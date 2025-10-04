const ROC_PERIOD = 3

"""
    ROC{T}(; period = ROC_PERIOD, input_modifier_return_type = T)

The `ROC` type implements a Rate Of Change indicator.
"""
mutable struct ROC{Tval,IN,T2} <: TechnicalIndicatorSingleOutput{Tval}
    value::Union{Missing,T2}
    n::Int

    period::Integer
    input_values::CircBuff

    function ROC{Tval}(;
        period = ROC_PERIOD,
        input_modifier_return_type = Tval,
    ) where {Tval}
        T2 = input_modifier_return_type
        input_values = CircBuff(T2, period + 1, rev = false)
        new{Tval,false,T2}(missing, 0, period, input_values)
    end
end

function ROC(; period = ROC_PERIOD, input_modifier_return_type = Float64)
    ROC{input_modifier_return_type}(;
        period = period,
        input_modifier_return_type = input_modifier_return_type,
    )
end

function _calculate_new_value(ind::ROC{T,IN,S}) where {T,IN,S}
    if ind.n >= ind.period + 1
        return 100 * one(S) * (ind.input_values[end] - ind.input_values[end-ind.period]) /
               ind.input_values[end-ind.period]
    else
        return missing
    end
end
