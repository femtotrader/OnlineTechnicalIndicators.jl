const RSI_PERIOD = 3

"""
    RSI{T}(; period = SMA_PERIOD)

The RSI type implements a Relative Strength Index indicator.
"""
mutable struct RSI{Tval} <: OnlineStat{Tval}
    value::Union{Missing,Tval}
    n::Integer

    period::Integer

    gains::SMMA{Tval}
    losses::SMMA{Tval}

    rolling::Bool
    input::CircBuff

    function RSI{Tval}(; period = RSI_PERIOD) where {Tval}
        input = CircBuff(Tval, 2, rev=false)
        value = missing
        gains = SMMA{Tval}(period = period)
        losses = SMMA{Tval}(period = period)
        new{Tval}(value, 0, period, gains, losses, false, input)
    end
end

function OnlineStatsBase._fit!(ind::RSI, val::Tval) where {Tval <: Number}
    fit!(ind.input, val)

    if length(ind.input) < 2
        ind.value = missing
        return ind.value
    end

    if ind.n + 1 == 2 # CircBuff is full but not rolling
        ind.rolling = true
        out_val = 1.0

    else  # CircBuff is filling up
        ind.n += 1
        out_val = missing
    end

    change = ind.input[end] - ind.input[end-1]

    gain = change > 0 ? change : 0.0
    loss = change < 0 ? -change : 0.0

    fit!(ind.gains, gain)
    fit!(ind.losses, loss)

    _losses = value(ind.losses)
    if ismissing(_losses)
        ind.value = missing
        return ind.value
    end

    if _losses == 0
        rsi = Tval(100)
    else
        rs = value(ind.gains) / _losses
        rsi = Tval(100) - Tval(100) / (Tval(1) + rs)
    end
    ind.value = rsi
    return ind.value
    
end
