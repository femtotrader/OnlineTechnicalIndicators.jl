const McGinleyDynamic_PERIOD = 14


"""
    McGinleyDynamic{T}(; period = McGinleyDynamic_PERIOD)

The `McGinleyDynamic` type implements a McGinley Dynamic indicator.
"""
mutable struct McGinleyDynamic{Tval} <: TechnicalIndicator{Tval}
    value::Union{Missing,Tval}
    n::Int

    period::Int

    rolling::Bool
    input_values::CircBuff

    function McGinleyDynamic{Tval}(; period = McGinleyDynamic_PERIOD) where {Tval}
        input = CircBuff(Tval, period, rev = false)
        new{Tval}(missing, 0, period, false, input)
    end
end

function OnlineStatsBase._fit!(ind::McGinleyDynamic, val)
    fit!(ind.input_values, val)
    if ind.rolling  # CircBuff is full and rolling
        ind.value = value(ind) + (val - value(ind)) / (ind.period * (val / value(ind))^4)
    else
        if ind.n + 1 == ind.period # CircBuff is full but not rolling
            ind.rolling = true
            ind.n += 1
            ind.value = sum(ind.input_values.value) / ind.period
        else  # CircBuff is filling up
            ind.n += 1
            ind.value = missing
        end
    end
end
