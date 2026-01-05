module OnlineTechnicalIndicators

# Export only submodule names - no types or functions directly
export Candlesticks, Internals
export Indicators, Patterns
export Wrappers, Factories
export SampleData

using OnlineStatsBase

# Base abstract types (needed by submodules)
abstract type TechnicalIndicator{T} <: OnlineStat{T} end
abstract type TechnicalIndicatorSingleOutput{T} <: TechnicalIndicator{T} end
abstract type TechnicalIndicatorMultiOutput{T} <: TechnicalIndicator{T} end
abstract type MovingAverageIndicator{T} <: TechnicalIndicatorSingleOutput{T} end

# Core utilities
include("stats.jl")

# Include Candlesticks submodule (OHLCV, OHLCVFactory, ValueExtractor)
include("candlesticks/Candlesticks.jl")

# Include Internals submodule (internal utility functions)
include("internals/Internals.jl")

# Import Internals functions for use in this module and submodules
using .Internals: is_multi_input, is_multi_output, expected_return_type
using .Internals: has_output_value, has_valid_values, always_true, is_valid
using .Internals: _calculate_new_value, _calculate_new_value_only_from_incoming_data

# Include sample data module
include("sample_data.jl")

# Include MovingAverage factory (needed by indicators)
include("factories/MovingAverage.jl")

# Include DAGWrapper (needed by SISO indicators like DEMA, TEMA, T3, TRIX)
include("wrappers/dag.jl")

# CircBuff setindex! extensions
function Base.setindex!(o::CircBuff, val, i::Int)
    if nobs(o) ≤ length(o.rng.rng)
        o.value[i] = val
    else
        o.value[o.rng[nobs(o)+i]] = val
    end
end
function Base.setindex!(o::CircBuff{<:Any,true}, val, i::Int)
    i = length(o.value) - i + 1
    if nobs(o) ≤ length(o.rng.rng)
        o.value[i] = val
    else
        o.value[o.rng[nobs(o)+i]] = val
    end
end

# Include Indicators submodule (defines all technical indicators)
include("indicators/Indicators.jl")

# Include Patterns submodule (defines all pattern recognition)
include("patterns/Patterns.jl")

# Other stuff
include("resample.jl")

# Integration with Julia ecosystem (Iterators, Tables)
include("other/iterators.jl")
include("other/tables.jl")

# Include re-export modules (must be at the end after all types are defined)
include("wrappers/Wrappers.jl")
include("factories/Factories.jl")

end
