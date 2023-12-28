const RSI_PERIOD = 3

"""
    RSI{T}(; period = SMA_PERIOD)

The RSI type implements a Relative Strength Index indicator.
"""
mutable struct RSI{Tval} <: TechnicalIndicator{Tval}
    value::Union{Missing,Tval}
    n::Int

    period::Integer

    gains::SMMA{Tval}
    losses::SMMA{Tval}

    input::CircBuff{Tval}

    function RSI{Tval}(; period = RSI_PERIOD) where {Tval}
        input = CircBuff(Tval, 2, rev = false)
        value = missing
        gains = SMMA{Tval}(period = period)
        losses = SMMA{Tval}(period = period)
        new{Tval}(value, 0, period, gains, losses, input)
    end
end

function OnlineStatsBase._fit!(ind::RSI, val)
    fit!(ind.input, val)
    if ind.n < ind.period
        ind.n += 1
    end

    if length(ind.input) < 2
        ind.value = missing
        return ind.value
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
        rsi = 100.0
    else
        rs = value(ind.gains) / _losses
        rsi = 100.0 - 100.0 / (1.0 + rs)
    end
    ind.value = rsi
    return ind.value

end
