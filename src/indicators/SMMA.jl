const SMMA_PERIOD = 3

"""
    SMMA{T}(; period = SMA_PERIOD)

The SMMA type implements a SMoothed Moving Average indicator.
"""
mutable struct SMMA{Tval} <: OnlineStat{Tval}
    value::Union{Missing,Tval}
    n::Int

    period::Integer

    rolling::Bool

    input::CircBuff

    function SMMA{Tval}(; period = SMMA_PERIOD) where {Tval}
        value = missing
        rolling = false
        input = CircBuff(Tval, period, rev=false)
        new{Tval}(value, 0, period, rolling, input)
    end
end


function OnlineStatsBase._fit!(ind::SMMA, val)
    fit!(ind.input, val)
    if ind.rolling  # CircBuff is full and rolling
        out_val = (ind.value * (ind.period - 1) + val) / ind.period
    else
        if ind.n + 1 == ind.period # CircBuff is full but not rolling
            ind.rolling = true
            out_val = sum(ind.input.value) / ind.period
        else  # CircBuff is filling up
            ind.n += 1
            out_val = missing
        end
    end
    ind.value = out_val
    return out_val
end


#=
function OnlineStatsBase._fit!(ind::SMMA, val)
    fit!(ind.input, val)
    if ind.rolling  # CircBuff is full and rolling
        out_val = 2.0

    else
        if ind.n == ind.period - 1 # CircBuff is full but not rolling
            ind.rolling = true
            out_val = 1.0

        else  # CircBuff is filling up
            ind.n += 1
            out_val = missing
        end
    end
    ind.value = out_val
    return out_val
end
=#

#=
function Base.push!(ind::SMMA{Tval}, val::Tval) where {Tval}
    push!(ind.input, val)
    N = length(ind.input)

    if N < ind.period
        out_val = missing
    else
        if !ind.rolling
            ind.rolling = true
            out_val = sum(ind.input) / ind.period
        else
            out_val = (ind.value[end] * (ind.period - 1) + val) / ind.period
        end
    end
    push!(ind.value, out_val)
    return out_val
end
=#

#=
function output(ind::SMMA)
    try
        return ind.value[ind.period]
    catch e
        if isa(e, BoundsError)
            return missing
        end
    end
end
=#