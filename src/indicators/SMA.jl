const SMA_PERIOD = 3

"""
    SMA{T}(; period = SMA_PERIOD)

The `SMA` type implements a Simple Moving Average indicator.
"""
mutable struct SMA{Tval} <: MovingAverageIndicator{Tval}
    value::Union{Missing,Tval}
    n::Int

    output_listeners::Series

    period::Int
    # sub_indicators::Series

    input_values::CircBuff{Tval}

    function SMA{Tval}(; period = SMA_PERIOD, output_listeners = Series()) where {Tval}
    # function SMA{Tval}(; period = SMA_PERIOD, input_indicator::Union{Missing,O} = missing) where {Tval, O <: TechnicalIndicator}
    # function SMA{Tval}(; period = SMA_PERIOD) where {Tval}
        input_values = CircBuff(Tval, period, rev = false)
        #=
        if !ismissing(input_indicator)
            sub_indicators = Series(input_indicator)  # and sub_indicators
        else
            sub_indicators = Series()
        end
        new{Tval}(missing, 0, period, sub_indicators, input)
        =#
        #input_indicator.output_listeners = 
        #output_listeners = Series()
        new{Tval}(missing, 0, output_listeners, period, input_values)
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
    fit!(ind.input_values, data)
    ind.value = _calculate_new_value(ind)
    fit_listeners!(ind)
end
