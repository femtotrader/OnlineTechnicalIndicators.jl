"""
    MAFactory

Factory for creating moving average indicators with a specific type parameter.

# Fields
- `T::Type`: The type parameter to use when constructing the moving average indicator

# Usage
```julia
factory = MAFactory(Float64)
ma = factory(SMA, period = 10)  # Creates SMA{Float64}(period = 10)
```
"""
struct MAFactory
    T::Type
end

function (f::MAFactory)(ma::Type{MA}, args...; kwargs...) where {MA<:TechnicalIndicator}
    return ma{f.T}(args...; kwargs...)
end
