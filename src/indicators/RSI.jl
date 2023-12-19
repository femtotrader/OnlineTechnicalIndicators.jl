const RSI_PERIOD = 3

"""
    RSI{T}(; period=SMA_PERIOD)

The RSI type implements a Relative Strength Index indicator.
"""
mutable struct RSI{Tval} <: AbstractIncTAIndicator
    period::Integer
    
    input::CircularBuffer{Tval}
    output::CircularBuffer{Union{Tval, Missing}}

    gains::SMMA{Tval}
    losses::SMMA{Tval}

    function RSI{Tval}(; period=RSI_PERIOD) where {Tval}
        input = CircularBuffer{Tval}(period)
        output = CircularBuffer{Union{Tval, Missing}}(period)
        gains = SMMA{Tval}(period=period)
        losses = SMMA{Tval}(period=period)
        new{Tval}(period, input, output, gains, losses)
    end
end

function Base.push!(ind::RSI{Tval}, val::Tval) where {Tval}
    push!(ind.input, val)

    if length(ind.input) < 2
        rsi = missing
        push!(ind.output, rsi)
        return rsi
    end

    change = ind.input[end] - ind.input[end - 1]

    gain = change > 0 ? change : 0.0
    loss = change < 0 ? -change : 0.0

    push!(ind.gains, gain)
    push!(ind.losses, loss)

    _losses = output(ind.losses)
    if ismissing(_losses)
        rsi = missing
        push!(ind.output, rsi)
        return rsi
    end

    if _losses == 0
        rsi = Tval(100)
    else
        rs = output(ind.gains) / _losses
        rsi = Tval(100) - Tval(100) / (Tval(1) + rs)
    end
    push!(ind.output, rsi)
    return rsi
end

function output(ind::RSI)
    try
        return ind.output[ind.period]
    catch e
        if isa(e, BoundsError)
            return missing
        end
    end    
end
