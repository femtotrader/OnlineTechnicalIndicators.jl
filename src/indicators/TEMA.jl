const TEMA_PERIOD = 20

"""
    TEMA{T}(; period = TEMA_PERIOD, ma = EMA)

The `TEMA` type implements a Triple Exponential Moving Average indicator.
"""
mutable struct TEMA{Tval} <: MovingAverageIndicator{Tval}
    value::Union{Missing,Tval}
    n::Int

    period::Integer

    sub_indicators::Series
    ma::Any  # EMA

    ma_ma::MovingAverageIndicator  # EMA
    ma_ma_ma::MovingAverageIndicator  # EMA

    function TEMA{Tval}(; period = TEMA_PERIOD, ma = EMA) where {Tval}
        # _ma = EMA{Tval}(period = period)
        _ma = MAFactory(Tval)(ma, period)
        sub_indicators = Series(_ma)
        # _ma_ma = EMA{Tval}(period = period)
        _ma_ma = MAFactory(Tval)(ma, period)
        # _ma_ma_ma = EMA{Tval}(period = period)
        _ma_ma_ma = MAFactory(Tval)(ma, period)
        new{Tval}(missing, 0, period, sub_indicators, _ma, _ma_ma, _ma_ma_ma)
    end
end

function _calculate_new_value(ind::TEMA)
    if has_output_value(ind.ma)
        fit!(ind.ma_ma, value(ind.ma))
        if has_output_value(ind.ma_ma)
            fit!(ind.ma_ma_ma, value(ind.ma_ma))
            if has_output_value(ind.ma_ma_ma)
                return 3.0 * value(ind.ma) - 3.0 * value(ind.ma_ma) + value(ind.ma_ma_ma)
            else
                return missing
            end
        else
            return missing
        end
    else
        return missing
    end
end
