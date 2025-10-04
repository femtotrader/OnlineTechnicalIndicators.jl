const ForceIndex_PERIOD = 3

"""
    ForceIndex{Tohlcv}(; period = ForceIndex_PERIOD, ma = EMA, input_modifier_return_type = Tohlcv)

The `ForceIndex` type implements a Force Index indicator.
"""
mutable struct ForceIndex{Tohlcv,IN,S} <: TechnicalIndicatorSingleOutput{Tohlcv}
    value::Union{Missing,S}
    n::Int

    period::Integer

    ma::MovingAverageIndicator  # EMA

    input_values::CircBuff

    function ForceIndex{Tohlcv}(;
        period = ForceIndex_PERIOD,
        ma = EMA,
        input_modifier_return_type = Tohlcv) where {Tohlcv}
        T2 = input_modifier_return_type
        S = fieldtype(T2, :close)
        _ma = MAFactory(S)(ma, period = period)
        input_values = CircBuff(T2, 2, rev = false)
        new{Tohlcv,true,S}(
            missing,
            0,
            period,
            _ma,
            input_values)
    end
end

function ForceIndex(;
    period = ForceIndex_PERIOD,
    ma = EMA,
    input_modifier_return_type = OHLCV{Missing,Float64,Float64})
    ForceIndex{input_modifier_return_type}(;
        period=period,
        ma=ma,
        input_modifier_return_type=input_modifier_return_type)
end

function _calculate_new_value(ind::ForceIndex)
    if ind.n >= 2
        fit!(
            ind.ma,
            (ind.input_values[end].close - ind.input_values[end-1].close) *
            ind.input_values[end].volume)
        if has_output_value(ind.ma)
            return value(ind.ma)
        else
            return missing
        end
    else
        return missing
    end
end
