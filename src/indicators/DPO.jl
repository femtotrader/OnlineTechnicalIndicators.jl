const DPO_PERIOD = 20

"""
    DPO{T}(; period = DPO_PERIOD, input_modifier_return_type = T)

The `DPO` type implements a Detrended Price Oscillator indicator.
"""
mutable struct DPO{Tval,IN,T2} <: TechnicalIndicatorSingleOutput{Tval}
    value::Union{Missing,T2}
    n::Int

    period::Int
    semi_period::Int

    sub_indicators::Series
    ma::MovingAverageIndicator # SMA
    input_values::CircBuff

    function DPO{Tval}(;
        period = DPO_PERIOD,
        ma = SMA,
        input_modifier_return_type = Tval) where {Tval}
        T2 = input_modifier_return_type
        input_values = CircBuff(T2, period, rev = false)
        _ma = MAFactory(T2)(ma, period = period)
        sub_indicators = Series(_ma)
        semi_period = floor(Int, period / 2)
        new{Tval,false,T2}(
            missing,
            0,
            period,
            semi_period,
            sub_indicators,
            _ma,
            input_values)
    end
end

function DPO(;
    period = DPO_PERIOD,
    ma = SMA,
    input_modifier_return_type = Float64)
    DPO{input_modifier_return_type}(;
        period=period,
        ma=ma,
        input_modifier_return_type=input_modifier_return_type)
end

function _calculate_new_value(ind::DPO)
    if length(ind.input_values) >= ind.semi_period + 2 && length(ind.ma.input_values) >= 1
        return ind.input_values[end-ind.semi_period-1] - value(ind.ma)
    else
        return missing
    end
end
