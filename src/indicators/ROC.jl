const ROC_PERIOD = 3

"""
    ROC{T}(; period = ROC_PERIOD)

The `ROC` type implements a Rate Of Change indicator.
"""
mutable struct ROC{Tval} <: TechnicalIndicator{Tval}
    value::Union{Missing,Tval}
    n::Int

    period::Integer

    input::CircBuff{Tval}

    function ROC{Tval}(; period = ROC_PERIOD) where {Tval}
        input = CircBuff(Tval, period + 1, rev = false)
        new{Tval}(missing, 0, period, input)
    end
end

function OnlineStatsBase._fit!(ind::ROC, data)
    fit!(ind.input, data)
    if ind.n == ind.period
        ind.value =
            100.0 * (ind.input[end] - ind.input[end-ind.period]) / ind.input[end-ind.period]
    else
        ind.n += 1
        ind.value = missing
    end
    return ind.value
end
