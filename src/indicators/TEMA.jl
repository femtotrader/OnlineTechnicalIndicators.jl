const TEMA_PERIOD = 20

"""
    TEMA{T}(; period = TEMA_PERIOD, ma = EMA, input_filter = always_true, input_modifier = identity, input_modifier_return_type = T)

The `TEMA` type implements a Triple Exponential Moving Average indicator.
"""
mutable struct TEMA{Tval,IN,T2} <: MovingAverageIndicator{Tval}
    value::Union{Missing,T2}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    period::Integer

    sub_indicators::Series
    ma::MovingAverageIndicator  # EMA

    ma_ma::MovingAverageIndicator  # EMA
    ma_ma_ma::MovingAverageIndicator  # EMA

    input_modifier::Function
    input_filter::Function

    function TEMA{Tval}(;
        period = TEMA_PERIOD,
        ma = EMA,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tval,
    ) where {Tval}
        T2 = input_modifier_return_type
        _ma = MAFactory(T2)(ma, period = period)
        sub_indicators = Series(_ma)
        _ma_ma = MAFactory(T2)(ma, period = period)
        _ma_ma_ma = MAFactory(T2)(ma, period = period)
        new{Tval,false,T2}(
            initialize_indicator_common_fields()...,
            period,
            sub_indicators,
            _ma,
            _ma_ma,
            _ma_ma_ma,
            input_modifier,
            input_filter,
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
