using OnlineStatsBase: name

"""
    StatLag(ind, b)

Track a moving window (previous `b` copies) of `ind`.

# Example

    ind = SMA{Float64}(period = 3)
    prices = [10.81, 10.58, 10.07, 10.58, 10.56, 10.4, 10.74, 10.16, 10.29, 9.4, 9.62]
    ind = StatLag(ind, 4)
    fit!(ind, prices)
    ind.lag[end-1]
"""
struct StatLag{T,O<:OnlineStat{T}} <: OnlineStatsBase.StatWrapper{T}
    lag::CircBuff{O}
    stat::O
end

function StatLag(stat::O, b::Integer) where {T,O<:OnlineStat{T}}
    StatLag{T,O}(CircBuff(O, b), stat)
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
