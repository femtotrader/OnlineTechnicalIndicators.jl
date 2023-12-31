const HMA_PERIOD = 20

"""
    HMA{T}(; period = HMA_PERIOD, input_filter = always_true, input_modifier = identity, input_modifier_return_type = T)

The `HMA` type implements a Hull Moving Average indicator.
"""
mutable struct HMA{Tval} <: MovingAverageIndicator{Tval}
    value::Union{Missing,Tval}
    n::Int

    period::Integer

    sub_indicators::Series
    wma::WMA
    wma2::WMA

    hma::WMA

    function HMA{Tval}(;
        period = HMA_PERIOD,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tval,
    ) where {Tval}
        wma = WMA{Tval}(period = period)
        wma2 = WMA{Tval}(period = floor(Int, period / 2))
        sub_indicators = Series(wma, wma2)
        hma = WMA{Tval}(period = floor(Int, sqrt(period)))
        new{Tval}(missing, 0, period, sub_indicators, wma, wma2, hma)
    end
end

function _calculate_new_value(ind::HMA)
    if has_output_value(ind.wma)
        fit!(ind.hma, 2.0 * value(ind.wma2) - value(ind.wma))
        if has_output_value(ind.hma)
            return value(ind.hma)
        else
            return missing
        end
    else
        return missing
    end
end
