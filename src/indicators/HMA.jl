const HMA_PERIOD = 20

"""
    HMA{T}(; period = HMA_PERIOD, input_modifier_return_type = T)

The `HMA` type implements a Hull Moving Average indicator.
"""
mutable struct HMA{Tval,IN,T2} <: MovingAverageIndicator{Tval}
    value::Union{Missing,T2}
    n::Int

    period::Integer

    sub_indicators::Series
    wma::WMA
    wma2::WMA

    hma::WMA

    function HMA{Tval}(;
        period = HMA_PERIOD,
        input_modifier_return_type = Tval,
    ) where {Tval}
        T2 = input_modifier_return_type
        wma = WMA{T2}(period = period)
        wma2 = WMA{T2}(period = floor(Int, period / 2))
        sub_indicators = Series(wma, wma2)
        hma = WMA{T2}(period = floor(Int, sqrt(period)))
        new{Tval,false,T2}(missing, 0, period, sub_indicators, wma, wma2, hma)
    end
end

function HMA(; period = DPO_PERIOD, input_modifier_return_type = Float64)
    HMA{input_modifier_return_type}(;
        period = period,
        input_modifier_return_type = input_modifier_return_type,
    )
end

function _calculate_new_value(ind::HMA)
    if has_output_value(ind.wma)
        fit!(ind.hma, 2 * value(ind.wma2) - value(ind.wma))
        if has_output_value(ind.hma)
            return value(ind.hma)
        else
            return missing
        end
    else
        return missing
    end
end
