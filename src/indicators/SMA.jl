const SMA_PERIOD = 3

"""
    SMA{T}(; period = SMA_PERIOD)

The `SMA` type implements a Simple Moving Average indicator.
"""
mutable struct SMA{Tval} <: MovingAverageIndicator{Tval}
    value::Union{Missing,Tval}
    n::Int

    period::Int
    # sub_indicators::Series

    input_values::CircBuff{Tval}

    # function SMA{Tval}(; period = SMA_PERIOD, input_indicator = missing) where {Tval}
    function SMA{Tval}(; period = SMA_PERIOD) where {Tval}
        input = CircBuff(Tval, period, rev = false)
        #=
        if !ismissing(input_indicator)
            sub_indicators = Series(input_indicator)  # and sub_indicators
        else
            sub_indicators = Series()
        end
        new{Tval}(missing, 0, period, sub_indicators, input)
        =#
        new{Tval}(missing, 0, period, input)
    end
end

function OnlineStatsBase._fit!(ind::SMA, data)
    #=
    if !isempty(ind.sub_indicators.stats)
        for sub_indicator in ind.sub_indicators
            fit!(sub_indicator, data)
        end
    end
    =#
    if ind.n < ind.period
        ind.n += 1
    end
    fit!(ind.input_values, data)
    # values = value(ind.input_values)
    values = ind.input_values.value
    ind.value = sum(values) / length(values)  # mean(values)
end
