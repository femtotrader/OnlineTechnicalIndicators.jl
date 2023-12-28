const HMA_PERIOD = 20

"""
    HMA{T}(; period = HMA_PERIOD)

The `HMA` type implements a Hull Moving Average indicator.
"""
mutable struct HMA{Tval} <: MovingAverageIndicator{Tval}
    value::Union{Missing,Tval}
    n::Int

    period::Integer

    sub_indicators::Series
    #wma::WMA
    #wma2::WMA

    hma::WMA

    function HMA{Tval}(; period = HMA_PERIOD) where {Tval}
        wma = WMA{Tval}(period = period)
        wma2 = WMA{Tval}(period = floor(Int, period / 2))
        sub_indicators = Series(wma, wma2)
        hma = WMA{Tval}(period = floor(Int, sqrt(period)))
        new{Tval}(missing, 0, period, sub_indicators, hma)
    end
end

function OnlineStatsBase._fit!(ind::HMA, data)
    fit!(ind.sub_indicators, data)
    # fit!(ind.wma, data)
    # fit!(ind.wma2, data)
    wma, wma2 = ind.sub_indicators.stats
    if ind.n != ind.period
        ind.n += 1
    end
    if has_output_value(wma)
        fit!(ind.hma, 2.0 * value(wma2) - value(wma))
        if has_output_value(ind.hma)
            ind.value = value(ind.hma)
        else
            ind.value = missing
        end
    else
        ind.value = missing
    end
    return ind.value
end
