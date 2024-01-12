const STOCH_PERIOD = 14
const STOCH_SMOOTHING_PERIOD = 3

struct StochVal{Tprice}
    k::Tprice
    d::Union{Missing,Tprice}
end

function is_valid(stoch_val::StochVal)
    return !ismissing(stoch_val.k) && !ismissing(stoch_val.d)
end

"""
    Stoch{Tohlcv}(; period = STOCH_PERIOD, smoothing_period = STOCH_SMOOTHING_PERIOD, ma = SMA, input_filter = always_true, input_modifier = identity, input_modifier_return_type = Tohlcv)

The `Stoch` type implements the Stochastic indicator.
"""
mutable struct Stoch{Tohlcv,IN,S} <: TechnicalIndicatorMultiOutput{Tohlcv}
    value::Union{Missing,StochVal}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    period::Integer
    smoothing_period::Integer

    values_d::SMA

    input_modifier::Function
    input_filter::Function
    input_values::CircBuff

    function Stoch{Tohlcv}(;
        period = STOCH_PERIOD,
        smoothing_period = STOCH_SMOOTHING_PERIOD,
        ma = SMA,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        S = fieldtype(T2, :close)
        values_d = MAFactory(S)(ma, period = smoothing_period)
        input_values = CircBuff(T2, period, rev = false)
        new{Tohlcv,true,S}(
            initialize_indicator_common_fields()...,
            period,
            smoothing_period,
            values_d,
            input_modifier,
            input_filter,
            input_values,
        )
    end
end

function _calculate_new_value(ind::Stoch{T,IN,S}) where {T,IN,S}
    # get latest received candle
    candle = ind.input_values[end]
    # get max high and min low
    max_high = max((cdl.high for cdl in value(ind.input_values))...)
    min_low = min((cdl.low for cdl in value(ind.input_values))...)
    # calculate k
    if max_high == min_low
        k = 100 * one(S)
    else
        k = 100 * one(S) * (candle.close - min_low) / (max_high - min_low)
    end
    # calculate d
    fit!(ind.values_d, k)
    d = value(ind.values_d)
    return StochVal(k, d)
end
