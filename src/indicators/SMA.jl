const SMA_PERIOD = 3

"""
    SMA{T}(; period = SMA_PERIOD, output_listeners = Series())

The `SMA` type implements a Simple Moving Average indicator.
"""
mutable struct SMA{Tval} <: MovingAverageIndicator{Tval}
    value::Union{Missing,Tval}
    n::Int

    output_listeners::Series

    period::Int
    # sub_indicators::Series

    input_indicator::Union{Missing,TechnicalIndicator}
    input_values::CircBuff{Tval}

    #function SMA{Tval}(; period = SMA_PERIOD, output_listeners = Series()) where {Tval}
    function SMA{Tval}(; period = SMA_PERIOD) where {Tval}
    # function SMA{Tval}(; period = SMA_PERIOD) where {Tval}
        input_values = CircBuff(Tval, period, rev = false) 
        output_listeners = Series()
        input_indicator = missing
        new{Tval}(missing, 0, output_listeners, period, input_indicator, input_values)
    end
end

function _calculate_new_value(ind::SMA)
    if ind.n < ind.period
        ind.n += 1
    end
    # data = ind.input_values[end]
    # values = value(ind.input_values)
    values = ind.input_values.value
    return sum(values) / length(values)  # mean(values)
end

function OnlineStatsBase._fit!(ind::SMA, data)
    #println(ind, " ", data)
    #if !ismissing(ind.input_indicator)
    #    fit!(ind.input_indicator, data)
    #end
    fit!(ind.input_values, data)
    ind.value = _calculate_new_value(ind)
    fit_listeners!(ind)
end
