const DEMA_PERIOD = 20

"""
    DEMA{T}(; period = DEMA_PERIOD)

The `DEMA` type implements a Double Exponential Moving Average indicator.
"""
mutable struct DEMA{Tval} <: MovingAverageIndicator{Tval}
    value::Union{Missing,Tval}
    n::Int

    period::Integer

    sub_indicators::Series
    ma::MovingAverageIndicator  # EMA
    ma_ma::MovingAverageIndicator  # EMA

    function DEMA{Tval}(; period = DEMA_PERIOD, ma = EMA) where {Tval}
        # _ma = EMA{Tval}(period = period)
        _ma = MAFactory(Tval)(ma, period)
        # _ma_ma = EMA{Tval}(period = period)
        _ma_ma = MAFactory(Tval)(ma, period)
        sub_indicators = Series(_ma)
        new{Tval}(missing, 0, period, sub_indicators, _ma, _ma_ma)
    end
end

function _calculate_new_value(ind::DEMA)
    if has_output_value(ind.ma)
        fit!(ind.ma_ma, value(ind.ma))
        if has_output_value(ind.ma_ma)
            return 2.0 * value(ind.ma) - value(ind.ma_ma)
        else
            return missing
        end
    else
        return missing
    end
end
