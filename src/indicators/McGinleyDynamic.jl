const McGinleyDynamic_PERIOD = 14


"""
    McGinleyDynamic{T}(; period = McGinleyDynamic_PERIOD, input_filter = always_true, input_modifier = identity, input_modifier_return_type = T)

The `McGinleyDynamic` type implements a McGinley Dynamic indicator.
"""
mutable struct McGinleyDynamic{Tval} <: TechnicalIndicator{Tval}
    value::Union{Missing,Tval}
    n::Int

    period::Int

    rolling::Bool
    input_values::CircBuff

    function McGinleyDynamic{Tval}(;
        period = McGinleyDynamic_PERIOD,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tval,
    ) where {Tval}
        input = CircBuff(Tval, period, rev = false)
        new{Tval}(missing, 0, period, false, input)
    end
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
