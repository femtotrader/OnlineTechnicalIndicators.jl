const ARDR_PERIOD = 14

"""
    ARDR{Tohlcv}(; period = ARDR_PERIOD, ma = SMA, input_modifier_return_type = Tohlcv)

The `ARDR` type implements an Average Relative Day Range indicator.

ARDR measures the average percentage price range by calculating the moving average of
RelativeIntradayRange ((High - Low) * 100 / Open) over a specified period. This enables
cross-asset volatility comparison by normalizing the range as a percentage.

# Parameters
- `period::Integer = $ARDR_PERIOD`: The number of periods for averaging the Relative Intraday Range
- `ma::Type = SMA`: The moving average type to use (default: Simple Moving Average)
- `input_modifier_return_type::Type = Tohlcv`: Input type (must be OHLCV-compatible)

# Input
[`OHLCV`](@ref) candlestick data with `open`, `high`, and `low` fields.

# Formula
```
RelativeIntradayRange = (High - Low) * 100 / Open
ARDR = MA(RelativeIntradayRange, period)
```

# Returns
`Union{Missing,T}` - The average relative day range as a percentage, or `missing` during
the warm-up period. Bars with Open=0 are skipped in the average.

See also: [`Smoother`](@ref), [`ADR`](@ref), [`RelativeIntradayRange`](@ref), [`ATR`](@ref), [`NATR`](@ref), [`OHLCV`](@ref)
"""
mutable struct ARDR{Tohlcv,IN,S} <: TechnicalIndicatorSingleOutput{Tohlcv}
    value::Union{Missing,S}
    n::Int

    period::Number

    smoother::Smoother

    input_values::CircBuff

    function ARDR{Tohlcv}(;
        period = ARDR_PERIOD,
        ma = SMA,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        if hasfield(T2, :close)
            S = fieldtype(T2, :close)
        else
            S = Float64
        end
        smoother = Smoother{T2}(RelativeIntradayRange; period = period, ma = ma, input_modifier_return_type = T2)
        input_values = CircBuff(T2, 1, rev = false)
        new{Tohlcv,true,S}(missing, 0, period, smoother, input_values)
    end
end

function ARDR(;
    period = ARDR_PERIOD,
    ma = SMA,
    input_modifier_return_type = OHLCV{Missing,Float64,Float64},
)
    ARDR{input_modifier_return_type}(;
        period = period,
        ma = ma,
        input_modifier_return_type = input_modifier_return_type,
    )
end

function _calculate_new_value(ind::ARDR)
    candle = ind.input_values[end]
    fit!(ind.smoother, candle)
    return value(ind.smoother)
end
