mutable struct SMA{Tvalues} <: AbstractIncTAIndicator
    period::Integer

    sum::Tvalues
    
    input::CircularBuffer{Tvalues}
    output::CircularBuffer{Tvalues}

    function SMA{Tvalues}(period) where {Tvalues}
        input = CircularBuffer{Tvalues}(period)
        output = CircularBuffer{Tvalues}(period)
        sum = zero(Tvalues)
        new{Tvalues}(period, sum, input, output)
    end
end

function Base.push!(ind::SMA{Tvalues}, data) where Tvalues
    if length(ind.input) < ind.period
        losing = zero(Tvalues)
    else
        losing = ind.input[1]
    end
    ind.sum = ind.sum - losing + data
    push!(ind.input, data)
    out_val = output(ind)
    push!(ind.output, ind.sum / ind.period)
    return out_val
end

function output(ind::SMA)
    if length(ind.input) < ind.period
        missing
    else
        return ind.sum / ind.period
    end
end
