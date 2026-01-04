const EMV_PERIOD = 20
const EMV_VOLUME_DIV = 10000

"""
    EMV{Tohlcv}(; period = EMV_PERIOD, volume_div = EMV_VOLUME_DIV, ma = SMA, input_modifier_return_type = Tohlcv)

The `EMV` type implements an Ease of Movement indicator.

EMV relates price change to volume, showing how easily a price can move. High positive values
indicate the price is moving up on low volume (easy upward movement), while high negative
values indicate easy downward movement. The indicator is smoothed with a moving average.

# Parameters
- `period::Integer = $EMV_PERIOD`: The number of periods for the moving average smoothing
- `volume_div::Integer = $EMV_VOLUME_DIV`: Divisor for volume normalization (typically 10000)
- `ma::Type = SMA`: The moving average type used for smoothing
- `input_modifier_return_type::Type = Tohlcv`: Input OHLCV type

# Formula
```
Distance = ((high + low) / 2) - ((high_prev + low_prev) / 2)
Box Ratio = (volume / volume_div) / (high - low)
EMV = MA(Distance / Box Ratio, period)
```

# Input
Requires OHLCV data with `high`, `low`, and `volume` fields.

# Returns
`Union{Missing,T}` - The smoothed ease of movement value, or `missing` during warm-up.

See also: [`OBV`](@ref), [`AccuDist`](@ref)
"""
mutable struct EMV{Tohlcv,IN,S} <: TechnicalIndicatorSingleOutput{Tohlcv}
    value::Union{Missing,S}
    n::Int

    period::Integer
    volume_div::Integer

    emv_ma::MovingAverageIndicator  # SMA
    input_values::CircBuff

    function EMV{Tohlcv}(;
        period = EMV_PERIOD,
        volume_div = EMV_VOLUME_DIV,
        ma = SMA,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        S = fieldtype(T2, :close)
        _emv_ma = MovingAverage(S)(ma, period = period)
        input_values = CircBuff(T2, period, rev = false)
        new{Tohlcv,true,S}(missing, 0, period, volume_div, _emv_ma, input_values)
    end
end

function EMV(;
    period = EMV_PERIOD,
    volume_div = EMV_VOLUME_DIV,
    ma = SMA,
    input_modifier_return_type = OHLCV{Missing,Float64,Float64},
)
    EMV{input_modifier_return_type}(;
        period = period,
        volume_div = volume_div,
        ma = ma,
        input_modifier_return_type = input_modifier_return_type,
    )
end

function _calculate_new_value(ind::EMV{T,IN,S}) where {T,IN,S}
    if ind.n >= 2
        candle = ind.input_values[end]
        candle_prev = ind.input_values[end-1]
        if candle.high != candle.low
            distance =
                ((candle.high + candle.low) / 2) -
                ((candle_prev.high + candle_prev.low) / 2)
            box_ratio = (candle.volume / ind.volume_div / (candle.high - candle.low))
            emv = distance / box_ratio
        else
            emv = zero(S)
        end
        fit!(ind.emv_ma, emv)
        return value(ind.emv_ma)
    else
        return missing
    end
end
