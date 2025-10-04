const VWMA_PERIOD = 3

"""
    VWMA{Tohlcv}(; period = VWMA_PERIOD, input_modifier_return_type = Tohlcv)

The `VWMA` type implements a Volume Weighted Moving Average indicator.
"""
mutable struct VWMA{Tohlcv,IN,S} <: MovingAverageIndicator{Tohlcv}
    value::Union{Missing,S}
    n::Int

    period::Integer
    input_values::CircBuff

    function VWMA{Tohlcv}(;
        period = VWMA_PERIOD,
        input_modifier_return_type = Tohlcv) where {Tohlcv}
        T2 = input_modifier_return_type
        S = fieldtype(T2, :close)
        input_values = CircBuff(T2, period, rev = false)
        new{Tohlcv,true,S}(
            missing,
            0,
            period,
            input_values)
    end
end

function VWMA(;
    period = VWMA_PERIOD,
    input_modifier_return_type = OHLCV{Missing,Float64,Float64})
    VWMA{input_modifier_return_type}(;
        period=period,
        input_modifier_return_type=input_modifier_return_type)
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
