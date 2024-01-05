const ForceIndex_PERIOD = 3

"""
    ForceIndex{Tohlcv,S}(; period = ForceIndex_PERIOD, ma = EMA, input_filter = always_true, input_modifier = identity, input_modifier_return_type = Tohlcv)

The `ForceIndex` type implements a Force Index indicator.
"""
mutable struct ForceIndex{Tohlcv,IN,S} <: TechnicalIndicatorSingleOutput{Tohlcv}
    value::Union{Missing,S}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    period::Integer

    ma::MovingAverageIndicator  # EMA

    input_modifier::Function
    input_filter::Function

    input_values::CircBuff

    function ForceIndex{Tohlcv}(;
        period = ForceIndex_PERIOD,
        ma = EMA,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        S = fieldtype(T2, :close)
        _ma = MAFactory(S)(ma, period = period)
        input_values = CircBuff(T2, 2, rev = false)
        new{Tohlcv,true,S}(
            initialize_indicator_common_fields()...,
            period,
            _ma,
            input_modifier,
            input_filter,
            input_values,
        )
    end
end

function _calculate_new_value(ind::ForceIndex)
    if ind.n >= 2
        fit!(
            ind.ma,
            (ind.input_values[end].close - ind.input_values[end-1].close) *
            ind.input_values[end].volume,
        )
        if has_output_value(ind.ma)
            return value(ind.ma)
        else
            return missing
        end
    else
        return missing
    end
end
