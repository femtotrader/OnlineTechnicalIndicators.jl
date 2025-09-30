const DEMA_PERIOD = 20

"""
    DEMA{T}(; period = DEMA_PERIOD, input_filter = always_true, input_modifier = identity, input_modifier_return_type = T)

The `DEMA` type implements a Double Exponential Moving Average indicator.
"""
mutable struct DEMA{Tval,IN,T2} <: MovingAverageIndicator{Tval}
    value::Union{Missing,T2}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    period::Integer

    sub_indicators::Series
    ma::MovingAverageIndicator  # EMA
    ma_ma::MovingAverageIndicator  # EMA

    input_modifier::Function
    input_filter::Function

    function DEMA{Tval}(;
        period = DEMA_PERIOD,
        ma = EMA,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tval,
    ) where {Tval}
        T2 = input_modifier_return_type
        _ma = MAFactory(T2)(ma, period = period)
        _ma_ma = MAFactory(T2)(ma, period = period)
        sub_indicators = Series(_ma)
        new{Tval,false,T2}(
            initialize_indicator_common_fields()...,
            period,
            sub_indicators,
            _ma,
            _ma_ma,
            input_modifier,
            input_filter,
        )
    end
end

function DEMA(;
    period = DEMA_PERIOD,
    ma = EMA,
    input_filter = always_true,
    input_modifier = identity,
    input_modifier_return_type = Float64,
)
    DEMA{input_modifier_return_type}(;
        period=period,
        ma=ma,
        input_filter=input_filter,
        input_modifier=input_modifier,
        input_modifier_return_type=input_modifier_return_type)
end

function _calculate_new_value(ind::DEMA)
    if has_output_value(ind.ma)
        fit!(ind.ma_ma, value(ind.ma))
        if has_output_value(ind.ma_ma)
            return 2 * value(ind.ma) - value(ind.ma_ma)
        else
            return missing
        end
    else
        return missing
    end
end
