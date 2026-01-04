const MassIndex_MA_PERIOD = 9
const MassIndex_MA_MA_PERIOD = 9
const MassIndex_MA_RATIO_PERIOD = 10


"""
    MassIndex{Tohlcv}(; ma_period = MassIndex_MA_PERIOD, ma_ma_period = MassIndex_MA_MA_PERIOD, ma_ratio_period = MassIndex_MA_RATIO_PERIOD, ma = EMA, input_modifier_return_type = Tohlcv)

The `MassIndex` type implements a Mass Index indicator.

The Mass Index identifies potential reversals by measuring the range between high and low
prices. It looks for "reversal bulges" where the index rises above 27 and then falls
below 26.5, which often precedes a price reversal regardless of direction.

# Parameters
- `ma_period::Integer = $MassIndex_MA_PERIOD`: Period for the first EMA of the high-low range
- `ma_ma_period::Integer = $MassIndex_MA_MA_PERIOD`: Period for the second EMA (of the first EMA)
- `ma_ratio_period::Integer = $MassIndex_MA_RATIO_PERIOD`: Period to sum the EMA ratio
- `ma::Type = EMA`: Moving average type used for smoothing
- `input_modifier_return_type::Type = Tohlcv`: Input OHLCV type

# Formula
```
Single EMA = EMA(high - low, ma_period)
Double EMA = EMA(Single EMA, ma_ma_period)
EMA Ratio = Single EMA / Double EMA
Mass Index = sum(EMA Ratio, ma_ratio_period)
```

# Input
Requires OHLCV data with `high` and `low` fields.

# Returns
`Union{Missing,T}` - The Mass Index value, or `missing` during warm-up.

See also: [`ATR`](@ref), [`ADX`](@ref)
"""
mutable struct MassIndex{Tohlcv,IN,S} <: TechnicalIndicatorSingleOutput{Tohlcv}
    value::Union{Missing,S}
    n::Int

    ma_ratio_period::Integer

    ma::MovingAverageIndicator  # EMA
    ma_ma::MovingAverageIndicator  # EMA
    ma_ratio::CircBuff{S}

    function MassIndex{Tohlcv}(;
        ma_period = MassIndex_MA_PERIOD,
        ma_ma_period = MassIndex_MA_MA_PERIOD,
        ma_ratio_period = MassIndex_MA_RATIO_PERIOD,
        ma = EMA,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        S = fieldtype(T2, :close)
        _ma = MAFactory(S)(ma, period = ma_period)
        _ma_ma = MAFactory(S)(ma, period = ma_ma_period)
        _ma_ratio = CircBuff(S, ma_ratio_period, rev = false)
        new{Tohlcv,true,S}(missing, 0, ma_ratio_period, _ma, _ma_ma, _ma_ratio)
    end
end

function MassIndex(;
    ma_period = MassIndex_MA_PERIOD,
    ma_ma_period = MassIndex_MA_MA_PERIOD,
    ma_ratio_period = MassIndex_MA_RATIO_PERIOD,
    ma = EMA,
    input_modifier_return_type = OHLCV{Missing,Float64,Float64},
)
    MassIndex{input_modifier_return_type}(;
        ma_period = ma_period,
        ma_ma_period = ma_ma_period,
        ma_ratio_period = ma_ratio_period,
        ma = ma,
        input_modifier_return_type = input_modifier_return_type,
    )
end

function _calculate_new_value_only_from_incoming_data(ind::MassIndex, candle)
    fit!(ind.ma, candle.high - candle.low)

    if !has_output_value(ind.ma)
        return missing
    end

    fit!(ind.ma_ma, value(ind.ma))

    if !has_output_value(ind.ma_ma)
        return missing
    end

    fit!(ind.ma_ratio, value(ind.ma) / value(ind.ma_ma))

    if length(ind.ma_ratio) < ind.ma_ratio_period
        return missing
    end

    return sum(value(ind.ma_ratio))
end
