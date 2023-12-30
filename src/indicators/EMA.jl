const EMA_PERIOD = 3


"""
    EMA{T}(; period=EMA_PERIOD)

The `EMA` type implements an Exponential Moving Average indicator.
"""
mutable struct EMA{Tval} <: MovingAverageIndicator{Tval}
    value::Union{Missing,Tval}
    n::Int

    output_listeners::Series

    period::Int
    mult::Tval
    mult_complement::Tval

    rolling::Bool
    input_values::CircBuff{Tval}

    function EMA{Tval}(; period = EMA_PERIOD, output_listeners = Series()) where {Tval}
        input = CircBuff(Tval, period, rev = false)
        mult = Tval(2) / (period + Tval(1))
        mult_complement = Tval(1) - mult
        new{Tval}(missing, 0, output_listeners, period, mult, mult_complement, false, input)
    end
end

function _calculate_new_value(ind::EMA)
    if ind.rolling  # CircBuff is full and rolling
        return ind.mult * ind.input_values[end] + ind.mult_complement * ind.value
    else
        if ind.n + 1 == ind.period # CircBuff is full but not rolling
            ind.rolling = true
            ind.n += 1
            return sum(ind.input_values.value) / ind.period
        else  # CircBuff is filling up
            ind.n += 1
            return missing
        end
    end
end

function OnlineStatsBase._fit!(ind::EMA, data)
    fit!(ind.input_values, data)
    ind.value = _calculate_new_value(ind)
    fit_listeners!(ind)
end
