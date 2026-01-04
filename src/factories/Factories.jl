"""
    OnlineTechnicalIndicators.Factories

The Factories module provides access to factory functions for creating indicator instances.

Factory functions provide a convenient way to create indicators with specific type parameters
or configurations, abstracting away the details of type parameterization.

# Exports
- [`MovingAverage`](@ref): Factory function for creating moving average indicators

# Usage

```julia
using OnlineTechnicalIndicators.Factories

# Create a moving average factory with Float64 type
factory = MovingAverage(Float64)
ma = factory(SMA, period=10)  # Creates SMA{Float64}(period=10)
```

# Deprecated
- `MAFactory`: Use `MovingAverage` instead (deprecated alias maintained for backward compatibility)

See also: [`OnlineTechnicalIndicators.Wrappers`](@ref)
"""
module Factories

# Re-export from parent module
using ..OnlineTechnicalIndicators: MovingAverage, MAFactory
export MovingAverage, MAFactory

end  # module
