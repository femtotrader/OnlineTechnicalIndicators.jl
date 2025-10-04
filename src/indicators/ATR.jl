const ATR_PERIOD = 3

"""
    ATR{Tohlcv}(; period = ATR_PERIOD, ma = SMMA, input_modifier_return_type = Tohlcv)

The `ATR` type implements an Average True Range indicator.
"""
mutable struct ATR{Tohlcv,IN,S} <: TechnicalIndicatorSingleOutput{Tohlcv}
    value::Union{Missing,S}
    n::Int

    period::Number

    tr::TrueRange
    tr_average::MovingAverageIndicator

    rolling::Bool
    input_values::CircBuff

    function ATR{Tohlcv}(;
        period = ATR_PERIOD,
        ma = SMMA,
        input_modifier_return_type = Tohlcv) where {Tohlcv}
        T2 = input_modifier_return_type
        if hasfield(T2, :close)
            S = fieldtype(T2, :close)
        else
            S = Float64
        end
        tr = TrueRange{input_modifier_return_type}()
        tr_average = MAFactory(S)(ma, period = period)
        input_values = CircBuff(T2, 2, rev = false)
        new{Tohlcv,true,S}(
            missing,
            0,
            period,
            tr,
            tr_average,
            false,
            input_values)
    end
end

function ATR(;
    period = ATR_PERIOD,
    ma = SMMA,
    input_modifier_return_type = OHLCV{Missing,Float64,Float64})
    ATR{input_modifier_return_type}(;
        period=period,
        ma=ma,
        input_modifier_return_type=input_modifier_return_type)
end

function _calculate_new_value(ind::ATR)
    candle = ind.input_values[end]
    fit!(ind.tr, candle)
    fit!(ind.tr_average, value(ind.tr))
    return value(ind.tr_average)
end
