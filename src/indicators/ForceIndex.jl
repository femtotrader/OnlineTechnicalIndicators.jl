const ForceIndex_PERIOD = 3

"""
    ForceIndex{Tohlcv}(; period = ForceIndex_PERIOD, ma = EMA, input_modifier_return_type = Tohlcv)

The `ForceIndex` type implements a Force Index indicator.

The Force Index combines price change and volume to measure the strength behind price
movements. Large positive values indicate strong buying pressure, while large negative
values indicate strong selling pressure. The raw values are smoothed with a moving average.

# Parameters
- `period::Integer = $ForceIndex_PERIOD`: The period for the moving average smoothing
- `ma::Type = EMA`: The moving average type used for smoothing
- `input_modifier_return_type::Type = Tohlcv`: Input OHLCV type

# Formula
```
Raw Force = (close - close_prev) × volume
Force Index = MA(Raw Force, period)
```

# Input
Requires OHLCV data with `close` and `volume` fields.

# Returns
`Union{Missing,T}` - The smoothed force index value, or `missing` during warm-up.

See also: [`OBV`](@ref), [`AccuDist`](@ref), [`KVO`](@ref)
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
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        S = fieldtype(T2, :close)
        _ma = MAFactory(S)(ma, period = period)
        input_values = CircBuff(T2, 2, rev = false)
        new{Tohlcv,true,S}(missing, 0, period, _ma, input_values)
    end
end

function ForceIndex(;
    period = ForceIndex_PERIOD,
    ma = EMA,
    input_modifier_return_type = OHLCV{Missing,Float64,Float64},
)
    ForceIndex{input_modifier_return_type}(;
        period = period,
        ma = ma,
        input_modifier_return_type = input_modifier_return_type,
    )
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
