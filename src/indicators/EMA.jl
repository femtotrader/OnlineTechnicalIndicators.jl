const EMA_PERIOD = 3


"""
    EMA{T}(; period = EMA_PERIOD)

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
    input_indicator::Union{Missing,TechnicalIndicator}
    input_values::CircBuff{Tval}

    function EMA{Tval}(; period = EMA_PERIOD) where {Tval}
        input_values = CircBuff(Tval, period, rev = false)
        mult = Tval(2) / (period + Tval(1))
        mult_complement = Tval(1) - mult
        output_listeners = Series()
        input_indicator = missing
        new{Tval}(
            missing,
            0,
            output_listeners,
            period,
            mult,
            mult_complement,
            false,
            input_indicator,
            input_values,
        )
    end
end

function _calculate_new_value(ind::EMA)
    if ind.rolling  # CircBuff is full and rolling
        return ind.mult * ind.input_values[end] + ind.mult_complement * ind.value
    else
        if ind.n == ind.period # CircBuff is full but not rolling
            ind.rolling = true
            return sum(ind.input_values.value) / ind.period
        else  # CircBuff is filling up
            return missing
        end
    end
end