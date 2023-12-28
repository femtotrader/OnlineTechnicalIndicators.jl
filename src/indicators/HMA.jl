const HMA_PERIOD = 20

"""
    HMA{T}(; period = HMA_PERIOD)

The HMA type implements a Hull Moving Average indicator.
"""
mutable struct HMA{Tval} <: TechnicalIndicator{Tval}
    value::Union{Missing,Tval}
    n::Int

    period::Integer

    wma::WMA{Tval}
    wma2::WMA{Tval}
    hma::WMA{Tval}

    function HMA{Tval}(; period = HMA_PERIOD) where {Tval}
        wma = WMA{Tval}(period = period)
        wma2 = WMA{Tval}(period = floor(Int, period / 2))
        hma = WMA{Tval}(period = floor(Int, sqrt(period)))
        new{Tval}(missing, 0, period, wma, wma2, hma)
    end
end

function OnlineStatsBase._fit!(ind::HMA, data)
    fit!(ind.wma, data)
    fit!(ind.wma2, data)
    if ind.n != ind.period
        ind.n += 1
    end
    if has_output_value(ind.wma)
        fit!(ind.hma, 2.0 * value(ind.wma2) - value(ind.wma))
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
