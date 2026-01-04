const SOBV_PERIOD = 20

"""
    SOBV{Tohlcv}(; period = SOBV_PERIOD, ma = SMA, input_modifier_return_type = Tohlcv)

The `SOBV` type implements a Smoothed On Balance Volume indicator.

SOBV applies a moving average to the On Balance Volume (OBV) indicator, reducing noise
and making the trend clearer. This helps filter out short-term fluctuations in the
cumulative volume measure.

# Parameters
- `period::Integer = $SOBV_PERIOD`: The number of periods for smoothing the OBV
- `ma::Type = SMA`: The moving average type used for smoothing
- `input_modifier_return_type::Type = Tohlcv`: Input OHLCV type

# Formula
```
SOBV = MA(OBV, period)
```
Where OBV is the On Balance Volume indicator.

# Input
Requires OHLCV data with `close` and `volume` fields.

# Returns
`Union{Missing,T}` - The smoothed on-balance volume value, or `missing` during the warm-up
period (first `period - 1` observations after OBV becomes available).

See also: [`Smoother`](@ref), [`OBV`](@ref), [`SMA`](@ref), [`EMA`](@ref)
"""
mutable struct SOBV{Tohlcv,IN,S} <: TechnicalIndicatorSingleOutput{Tohlcv}
    value::Union{Missing,S}
    n::Int

    period::Integer

    smoother::Smoother

    input_values::CircBuff

    function SOBV{Tohlcv}(;
        period = SOBV_PERIOD,
        ma = SMA,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        S = fieldtype(T2, :close)
        smoother = Smoother{T2}(OBV; period = period, ma = ma, input_modifier_return_type = T2)
        input_values = CircBuff(T2, 1, rev = false)
        new{Tohlcv,true,S}(missing, 0, period, smoother, input_values)
    end
end

function SOBV(;
    period = SOBV_PERIOD,
    ma = SMA,
    input_modifier_return_type = OHLCV{Missing,Float64,Float64},
)
    SOBV{input_modifier_return_type}(;
        period = period,
        ma = ma,
        input_modifier_return_type = input_modifier_return_type,
    )
end

function _calculate_new_value(ind::SOBV)
    candle = ind.input_values[end]
    fit!(ind.smoother, candle)
    return value(ind.smoother)
end
