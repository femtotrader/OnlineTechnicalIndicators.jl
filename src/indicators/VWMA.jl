const VWMA_PERIOD = 3

"""
    VWMA{Tohlcv,S}(; period = VWMA_PERIOD)

The `VWMA` type implements a Volume Weighted Moving Average indicator.
"""
mutable struct VWMA{Tohlcv,S} <: MovingAverageIndicator{Tohlcv}
    value::Union{Missing,S}
    n::Int

    period::Integer

    input_values::CircBuff

    function VWMA{Tohlcv,S}(; period = VWMA_PERIOD) where {Tohlcv,S}
        input_values = CircBuff(Tohlcv, period, rev = false)
        new{Tohlcv,S}(missing, 0, period, input_values)
    end
end

function _calculate_new_value(ind::VWMA)
    if ind.n >= ind.period
        s = 0
        v = 0
        for candle_prev in value(ind.input_values)
            s += candle_prev.close * candle_prev.volume
            v += candle_prev.volume
        end
        return s / v
    else
        return missing
    end
end
