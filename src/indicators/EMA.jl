const EMA_PERIOD = 3


"""
    EMA{T}(; period=EMA_PERIOD)

The EMA type implements an Exponential Moving Average indicator.
"""
mutable struct EMA{Tval} <: OnlineStat{Tval}
    value::Union{Missing,Tval}
    n::Int

    period::Int

    rolling::Bool
    input::CircBuff{Tval}

    function EMA{Tval}(; period = EMA_PERIOD) where {Tval}
        input = CircBuff(Tval, period, rev = false)
        new{Tval}(missing, 0, period, false, input)
    end
end

function OnlineStatsBase._fit!(ind::EMA, val)
    fit!(ind.input, val)
    if ind.rolling  # CircBuff is full and rolling
        mult = 2.0 / (ind.period + 1.0)
        out_val = mult * ind.input[end] + (1.0 - mult) * ind.value
    else
        if ind.n + 1 == ind.period # CircBuff is full but not rolling
            ind.rolling = true
            ind.n += 1
            out_val = sum(ind.input.value) / ind.period
        else  # CircBuff is filling up
            ind.n += 1
            out_val = missing
        end
    end
    ind.value = out_val
    return out_val
end
