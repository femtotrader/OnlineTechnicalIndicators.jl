const ROC_PERIOD = 3

"""
    ROC{T}(; period = ROC_PERIOD)

The `ROC` type implements a Rate Of Change indicator.
"""
mutable struct ROC{Tval} <: TechnicalIndicator{Tval}
    value::Union{Missing,Tval}
    n::Int

    period::Integer

    input_values::CircBuff{Tval}

    function ROC{Tval}(; period = ROC_PERIOD) where {Tval}
        input_values = CircBuff(Tval, period + 1, rev = false)
        new{Tval}(missing, 0, period, input_values)
    end
end

function OnlineStatsBase._fit!(ind::ROC, data)
    fit!(ind.input_values, data)
    if ind.n == ind.period
        ind.value =
            100.0 * (ind.input_values[end] - ind.input_values[end-ind.period]) / ind.input_values[end-ind.period]
    else
        ind.n += 1
        ind.value = missing
    end
    return ind.value
end
