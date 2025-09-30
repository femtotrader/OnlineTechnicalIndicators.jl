const MeanDev_PERIOD = 3

"""
    MeanDev{T}(; period = MeanDev_PERIOD, ma = SMA, input_filter = always_true, input_modifier = identity, input_modifier_return_type = T)

The `MeanDev` type implements a Mean Deviation indicator.
"""
mutable struct MeanDev{Tval,IN,T2} <: TechnicalIndicatorSingleOutput{Tval}
    value::Union{Missing,T2}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    period::Integer

    sub_indicators::Series  # field ma needs to be available for CCI calculation
    ma::MovingAverageIndicator  # SMA

    input_modifier::Function
    input_filter::Function
    input_values::CircBuff

    function MeanDev{Tval}(;
        period = MeanDev_PERIOD,
        ma = SMA,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tval,
    ) where {Tval}
        T2 = input_modifier_return_type
        input_values = CircBuff(T2, period, rev = false)
        _ma = MAFactory(T2)(ma, period = period)
        sub_indicators = Series(_ma)
        new{Tval,false,T2}(
            initialize_indicator_common_fields()...,
            period,
            sub_indicators,
            _ma,
            input_modifier,
            input_filter,
            input_values,
        )
    end
end

function MeanDev(;
    period = MeanDev_PERIOD,
    ma = SMA,
    input_filter = always_true,
    input_modifier = identity,
    input_modifier_return_type = Float64,
)
    MeanDev{input_modifier_return_type}(;
        period=period,
        ma=ma,
        input_filter=input_filter,
        input_modifier=input_modifier,
        input_modifier_return_type=input_modifier_return_type)
end

function _calculate_new_value(ind::MeanDev)
    _ma = value(ind.ma)
    return sum(abs.(value(ind.input_values) .- _ma)) / ind.period
end
