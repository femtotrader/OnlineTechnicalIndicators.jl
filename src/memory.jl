mutable struct Memory{T} <: OnlineStat{T}
    value::Union{Missing,T}
    n::Int
    ind::OnlineStat{T}
    history::CircBuff
    function Memory(ind::OnlineStat{T}; n = 3) where {T}
        history = CircBuff(T, n, rev=false)
        new{T}(missing, 0, ind, history)
    end
end

function OnlineStatsBase._fit!(memory::Memory, val)
    if memory.n <= length(memory.history.value)
        memory.n += 1
    end
    fit!(memory.ind, val)
    val = value(memory.ind)
    fit!(memory.history, val)
    memory.value = val
end

Base.lastindex(ind::Memory) = length(ind.history.value)

Base.getindex(ind::Memory, index) = ind.history[index]
