"""
    MovingAverage

Factory for creating moving average indicators with a specific type parameter.

# Fields
- `T::Type`: The type parameter to use when constructing the moving average indicator

# Usage
```julia
factory = MovingAverage(Float64)
ma = factory(SMA, period = 10)  # Creates SMA{Float64}(period = 10)
```

See also: [`SMA`](@ref), [`EMA`](@ref), [`SMMA`](@ref), [`WMA`](@ref), [`DEMA`](@ref), [`TEMA`](@ref), [`KAMA`](@ref), [`HMA`](@ref), [`McGinleyDynamic`](@ref)
"""
struct MovingAverage
    T::Type
end

function (f::MovingAverage)(ma::Type{MA}, args...; kwargs...) where {MA<:TechnicalIndicator}
    return ma{f.T}(args...; kwargs...)
end

"""
    MAFactory

**DEPRECATED**: Use `MovingAverage` instead.

`MAFactory` is a deprecated alias for `MovingAverage`. It is maintained for backward compatibility
but will be removed in a future version.

# Migration
```julia
# Old (deprecated):
factory = MAFactory(Float64)

# New (recommended):
factory = MovingAverage(Float64)
```
"""
const MAFactory = MovingAverage
