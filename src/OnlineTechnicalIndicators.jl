module OnlineTechnicalIndicators

# Core exports (base types, utilities)
export OHLCV, OHLCVFactory, ValueExtractor
export fit!
export SampleData

# Export Wrappers submodule (for DAGWrapper access)
export Wrappers

# Export Factories submodule (for MovingAverage access)
export Factories

# Export new submodules for indicators and patterns
export Indicators, Patterns

# Deprecated export (kept for backward compatibility warning)
export add_input_indicator!

using OnlineStatsBase
export value

# Base abstract types (needed by submodules)
abstract type TechnicalIndicator{T} <: OnlineStat{T} end
abstract type TechnicalIndicatorSingleOutput{T} <: TechnicalIndicator{T} end
abstract type TechnicalIndicatorMultiOutput{T} <: TechnicalIndicator{T} end
abstract type MovingAverageIndicator{T} <: TechnicalIndicatorSingleOutput{T} end

# Core utilities
include("stats.jl")
include("ohlcv.jl")
include("sample_data.jl")

# Include MovingAverage factory (needed by indicators)
include("factories/MovingAverage.jl")

# Include DAGWrapper (needed by SISO indicators like DEMA, TEMA, T3, TRIX)
include("wrappers/dag.jl")

# Helper functions for indicators
ismultioutput(ind::Type{O}) where {O<:TechnicalIndicator} =
    ind <: TechnicalIndicatorMultiOutput
expected_return_type(ind::O) where {O<:TechnicalIndicatorSingleOutput} =
    typeof(ind).parameters[end]
function expected_return_type(ind::O) where {O<:TechnicalIndicatorMultiOutput}
    retval = String(nameof(typeof(ind))) * "Val"  # return value as String "BBVal", "MACDVal"...
    # Look up type in the indicator's module (where the Val types are defined)
    ind_module = parentmodule(typeof(ind))
    RETVAL = getfield(ind_module, Symbol(retval))
    return RETVAL{typeof(ind).parameters[end]}
end

function expected_return_type(IND::Type{O}) where {O<:TechnicalIndicatorMultiOutput}
    retval = String(nameof(IND)) * "Val"  # return value as String "BBVal", "MACDVal"...
    # Look up type in the indicator's module (where the Val types are defined)
    ind_module = parentmodule(IND)
    RETVAL = getfield(ind_module, Symbol(retval))
    return RETVAL
end

function OnlineStatsBase._fit!(ind::O, data) where {O<:TechnicalIndicator}
    _fieldnames = fieldnames(O)
    # Only apply input_filter/input_modifier if they exist (legacy indicators)
    # StatDAG-based indicators (DEMA, TEMA, T3, TRIX) don't have these fields
    if :input_filter in _fieldnames && :input_modifier in _fieldnames
        if ind.input_filter(data)
            data = ind.input_modifier(data)
        else
            return nothing
        end
    end
    has_input_values = :input_values in _fieldnames
    if has_input_values
        fit!(ind.input_values, data)
    end
    has_sub_indicators =
        :sub_indicators in _fieldnames && length(ind.sub_indicators.stats) > 0
    if has_sub_indicators
        fit!(ind.sub_indicators, data)
    end
    ind.n += 1
    ind.value =
        (has_input_values || has_sub_indicators) ? _calculate_new_value(ind) :
        _calculate_new_value_only_from_incoming_data(ind, data)
    fit_listeners!(ind)
end

is_valid(::Missing) = false

function has_output_value(ind::O) where {O<:OnlineStat}
    return !ismissing(value(ind))
end


function has_output_value(cb::CircBuff)
    if length(cb.value) > 0
        return !ismissing(cb[end])
    else
        return false
    end
end

function has_valid_values(sequence::CircBuff, window; exact = false)
    if !exact
        return length(sequence) >= window && !ismissing(sequence[end-window+1])
    else
        return (length(sequence) == window && !ismissing(sequence[end-window+1])) || (
            length(sequence) > window &&
            !ismissing(sequence[end-window+1]) &&
            ismissing(sequence[end-window])
        )
    end
end

function fit_listeners!(ind::O) where {O<:TechnicalIndicator}
    # Legacy function - no longer used with StatDAG-based indicators
    # Kept for backward compatibility but does nothing
    return
end

"""
    add_input_indicator!(ind2, ind1)

**DEPRECATED**: This function is deprecated. Use `OnlineStatsChains.StatDAG` to chain indicators instead.

# Migration Guide
Instead of using `add_input_indicator!` to chain indicators:

```julia
# Old way (deprecated):
ema1 = EMA(period=10)
ema2 = EMA(period=10)
add_input_indicator!(ema2, ema1)
```

Use `OnlineStatsChains.StatDAG` with filtered edges:

```julia
# New way (recommended):
using OnlineStatsChains

dag = StatDAG()
add_node!(dag, :ema1, EMA(period=10))
add_node!(dag, :ema2, EMA(period=10))
connect!(dag, :ema1, :ema2, filter = !ismissing)

# Feed data to the first node
fit!(dag, :ema1 => data)

# Get values from any node
value(dag, :ema1)  # First EMA
value(dag, :ema2)  # Second EMA (automatically updated)
```

See the implementations of DEMA, TEMA, T3, and TRIX for complete examples.
"""
function add_input_indicator!(
    ind2::O1,
    ind1::O2,
) where {O1<:TechnicalIndicator,O2<:TechnicalIndicator}
    error(
        "add_input_indicator! is no longer functional as the required fields (input_indicator, output_listeners) have been removed. Use OnlineStatsChains.StatDAG to chain indicators. See documentation for migration guide.",
    )
end

always_true(x) = true

# Base function for checking if indicator requires multi-input (OHLCV) data
# Submodules extend this for their specific indicator types
ismultiinput(::Type{<:TechnicalIndicator}) = false

# Base functions for indicator calculations - extended by submodules
# These are called by _fit! and must be defined per-indicator type
function _calculate_new_value end
function _calculate_new_value_only_from_incoming_data end

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
# Note: Array convenience functions are now in Indicators module (arrays_indicators.jl)
# Use OnlineTechnicalIndicators.Indicators.SMA(array, ...) instead of OnlineTechnicalIndicators.SMA(array, ...)
include("other/iterators.jl")
include("other/tables.jl")

# Include re-export modules (must be at the end after all types are defined)
include("wrappers/Wrappers.jl")
include("factories/Factories.jl")

end
