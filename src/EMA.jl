struct EMA{Tval<:Number} <: AbstractIncTAIndicator
    period::Integer
    
    input::CircularBuffer{Tval}
    output::CircularBuffer{Tval}
    
    function EMA{Tval}(period) where {Tval}
        new{Tval}(period, CircularBuffer{Tval}(period), CircularBuffer{Tval}(period))
    end
end
    
function Base.push!(ind::EMA, value)
    push!(ind.input, value)
    if length(ind.output) == capacity(ind.output)
        mult = 2.0 / (ind.period + 1.0)
        new_val = mult * ind.input[end] + (1.0 - mult) * ind.output[end]
    else
        new_val = sum(ind.input) / ind.period
    end
    push!(ind.output, new_val)
    #ind.output[end]
    output(ind)
end

function output(ind::EMA)
    try
        return ind.output[ind.period]
    catch e
        if isa(e, BoundsError)
            return missing
        end
    end    
end