const TEMA_PERIOD = 20

"""
    TEMA{T}(; period = TEMA_PERIOD, ma = EMA, input_filter = always_true, input_modifier = identity, input_modifier_return_type = T)

The `TEMA` type implements a Triple Exponential Moving Average indicator.
"""
mutable struct TEMA{Tval,T2} <: MovingAverageIndicator{Tval}
    value::Union{Missing,T2}
    n::Int

    output_listeners::Series

    period::Integer

    sub_indicators::Series
    ma::Any  # EMA

    ma_ma::MovingAverageIndicator  # EMA
    ma_ma_ma::MovingAverageIndicator  # EMA

    input_modifier::Function
    input_filter::Function
    input_indicator::Union{Missing,TechnicalIndicator}

    function TEMA{Tval}(;
        period = TEMA_PERIOD,
        ma = EMA,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tval,
    ) where {Tval}
        T2 = input_modifier_return_type
        # _ma = EMA{Tval}(period = period)
        _ma = MAFactory(T2)(ma, period = period)
        sub_indicators = Series(_ma)
        # _ma_ma = EMA{Tval}(period = period)
        _ma_ma = MAFactory(T2)(ma, period = period)
        # _ma_ma_ma = EMA{Tval}(period = period)
        _ma_ma_ma = MAFactory(T2)(ma, period = period)
        output_listeners = Series()
        input_indicator = missing
        new{Tval,T2}(
            missing,
            0,
            output_listeners,
            period,
            sub_indicators,
            _ma,
            _ma_ma,
            _ma_ma_ma,
            input_modifier,
            input_filter,
            input_indicator,
        )
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
