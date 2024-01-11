"""
    StatLag(stat, b)

Track a moving window (previous `b` copies) of `stat`.

# Example

    fit!(StatLag(Mean(), 10), 1:20)
"""
struct StatLag{T, O<:OnlineStat{T}} <: OnlineStatsBase.StatWrapper{T}
    lag::CircBuff{O}
    stat::O
end

function StatLag(stat::O, b::Integer) where {T, O<:OnlineStat{T}}
    StatLag{T,O}(CircBuff(O,b), stat)
end

function OnlineStatsBase._fit!(o::StatLag, y)
    OnlineStatsBase._fit!(o.stat, y)
    OnlineStatsBase._fit!(o.lag, copy(o.stat))
end

function Base.show(io::IO, o::StatLag)
    print(io, name(o, false, false), ": ")
    print(io, "n=", nobs(o))
    print(io, " | stat_values_old_to_new= ")
    show(IOContext(io, :compact => true), value.(value(o.lag)))
end