const SMOOTHER_PERIOD = 14

"""
    Smoother(InnerType::Type{<:TechnicalIndicator}; period = SMOOTHER_PERIOD, ma = SMA, input_modifier_return_type = OHLCV{Missing,Float64,Float64})

The `Smoother` type implements a generic smoothing wrapper that applies a moving average to any indicator's output.

Smoother wraps an inner indicator (e.g., TrueRange, IntradayRange, OBV) and applies a configurable
moving average to smooth its output values. This provides a reusable pattern for creating "averaged"
versions of indicators like ATR, ADR, ARDR, and SOBV.

# Parameters
- `InnerType::Type{<:TechnicalIndicator}`: The type of inner indicator to smooth (passed as first argument)
- `period::Integer = $SMOOTHER_PERIOD`: The number of periods for the moving average
- `ma::Type = SMA`: The moving average type to use (SMA, EMA, SMMA, WMA, etc.)
- `input_modifier_return_type::Type = OHLCV{Missing,Float64,Float64}`: Input OHLCV type

# Formula
```
Smoother = MA(InnerIndicator, period)
```

# Input
[`OHLCV`](@ref) candlestick data compatible with the inner indicator's requirements.

# Returns
`Union{Missing,T}` - The smoothed value, or `missing` during the warm-up period.

# Examples
```julia
# Create a smoother that applies SMA(14) to TrueRange (similar to ATR with SMA)
smoother = Smoother(TrueRange; period=14, ma=SMA)

# Create a smoother that applies SMMA(14) to TrueRange (like standard ATR)
smoother = Smoother(TrueRange; period=14, ma=SMMA)

# Create a smoother for IntradayRange with EMA(10)
smoother = Smoother(IntradayRange; period=10, ma=EMA)

# Feed data
for candle in ohlcv_data
    fit!(smoother, candle)
end
println(value(smoother))
```

See also: [`ATR`](@ref), [`ADR`](@ref), [`ARDR`](@ref), [`SOBV`](@ref), [`TrueRange`](@ref), [`IntradayRange`](@ref), [`OBV`](@ref)
"""
mutable struct Smoother{Tohlcv,IN,S,Inner<:TechnicalIndicator} <: TechnicalIndicatorSingleOutput{Tohlcv}
    value::Union{Missing,S}
    n::Int

    period::Number

    inner::Inner
    ma::MovingAverageIndicator

    input_values::CircBuff

    function Smoother{Tohlcv}(
        InnerType::Type{<:TechnicalIndicator};
        period = SMOOTHER_PERIOD,
        ma = SMA,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        if hasfield(T2, :close)
            S = fieldtype(T2, :close)
        else
            S = Float64
        end
        inner = InnerType{input_modifier_return_type}()
        _ma = MAFactory(S)(ma, period = period)
        input_values = CircBuff(T2, 1, rev = false)
        new{Tohlcv,true,S,typeof(inner)}(missing, 0, period, inner, _ma, input_values)
    end
end

function Smoother(
    InnerType::Type{<:TechnicalIndicator};
    period = SMOOTHER_PERIOD,
    ma = SMA,
    input_modifier_return_type = OHLCV{Missing,Float64,Float64},
)
    Smoother{input_modifier_return_type}(
        InnerType;
        period = period,
        ma = ma,
        input_modifier_return_type = input_modifier_return_type,
    )
end

function _calculate_new_value(ind::Smoother)
    candle = ind.input_values[end]
    fit!(ind.inner, candle)
    inner_val = value(ind.inner)
    if !ismissing(inner_val)
        fit!(ind.ma, inner_val)
    end
    return value(ind.ma)
end
