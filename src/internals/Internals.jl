"""
    Internals

Submodule containing internal utility functions for indicator implementation.

**Note**: These are internal implementation details. While exported for advanced use cases,
the API may change between minor versions.

# Exports
## Type Queries
- `is_multi_input`: Check if an indicator requires OHLCV input
- `is_multi_output`: Check if an indicator produces multiple output values
- `expected_return_type`: Get the expected return type of an indicator

## Value Utilities
- `has_output_value`: Check if an indicator has a valid output value
- `has_valid_values`: Check if a circular buffer has enough valid values
- `always_true`: Utility function that always returns true
- `is_valid`: Check if a value is not missing

## Calculation Functions
- `_fit!`: Internal fit function for OnlineStatsBase integration
- `_calculate_new_value`: Calculate new value from internal state
- `_calculate_new_value_only_from_incoming_data`: Calculate value from incoming data only
"""
module Internals

import OnlineStatsBase
using OnlineStatsBase: OnlineStat, CircBuff, nobs, fit!, value

# Import parent module types for type annotations
using ..OnlineTechnicalIndicators: TechnicalIndicator, TechnicalIndicatorSingleOutput, TechnicalIndicatorMultiOutput

export is_multi_input, is_multi_output, expected_return_type
export has_output_value, has_valid_values, always_true, is_valid
export _fit!, _calculate_new_value, _calculate_new_value_only_from_incoming_data

"""
    is_multi_output(ind::Type{<:TechnicalIndicator}) -> Bool

Check if an indicator type produces multiple output values (e.g., MACD, Bollinger Bands).

Returns `true` if the indicator is a subtype of `TechnicalIndicatorMultiOutput`.
"""
is_multi_output(ind::Type{O}) where {O<:TechnicalIndicator} =
    ind <: TechnicalIndicatorMultiOutput

"""
    is_multi_input(ind::Type{<:TechnicalIndicator}) -> Bool

Check if an indicator type requires OHLCV (multi-field) input data.

Returns `false` by default. Indicator submodules extend this for specific types.
"""
is_multi_input(::Type{<:TechnicalIndicator}) = false

"""
    expected_return_type(ind::TechnicalIndicatorSingleOutput) -> Type

Get the expected return type for a single-output indicator instance.
"""
expected_return_type(ind::O) where {O<:TechnicalIndicatorSingleOutput} =
    typeof(ind).parameters[end]

"""
    expected_return_type(ind::TechnicalIndicatorMultiOutput) -> Type

Get the expected return type for a multi-output indicator instance.

For multi-output indicators, this returns the corresponding `*Val` type
(e.g., `MACDVal` for `MACD`).
"""
function expected_return_type(ind::O) where {O<:TechnicalIndicatorMultiOutput}
    retval = String(nameof(typeof(ind))) * "Val"
    ind_module = parentmodule(typeof(ind))
    RETVAL = getfield(ind_module, Symbol(retval))
    return RETVAL{typeof(ind).parameters[end]}
end

"""
    expected_return_type(IND::Type{<:TechnicalIndicatorMultiOutput}) -> Type

Get the expected return type for a multi-output indicator type.
"""
function expected_return_type(IND::Type{O}) where {O<:TechnicalIndicatorMultiOutput}
    retval = String(nameof(IND)) * "Val"
    ind_module = parentmodule(IND)
    RETVAL = getfield(ind_module, Symbol(retval))
    return RETVAL
end

"""
    is_valid(x) -> Bool

Check if a value is valid (not missing).

Returns `false` for `missing`, `true` for any other value.
"""
is_valid(::Missing) = false
is_valid(x) = true

"""
    has_output_value(ind::OnlineStat) -> Bool

Check if an indicator has a valid (non-missing) output value.
"""
function has_output_value(ind::O) where {O<:OnlineStat}
    return !ismissing(value(ind))
end

"""
    has_output_value(cb::CircBuff) -> Bool

Check if a circular buffer has a valid (non-missing) last value.
"""
function has_output_value(cb::CircBuff)
    if length(cb.value) > 0
        return !ismissing(cb[end])
    else
        return false
    end
end

"""
    has_valid_values(sequence::CircBuff, window; exact=false) -> Bool

Check if a circular buffer has enough valid (non-missing) values for a given window.

# Arguments
- `sequence`: The circular buffer to check
- `window`: The required number of valid values
- `exact`: If `true`, checks that exactly `window` values are valid (for initialization)
"""
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

"""
    always_true(x) -> Bool

Utility function that always returns `true`. Used as default input filter.
"""
always_true(x) = true

"""
    _calculate_new_value(ind)

Calculate a new indicator value from internal state.

This is an abstract function that must be implemented by each indicator type.
"""
function _calculate_new_value end

"""
    _calculate_new_value_only_from_incoming_data(ind, data)

Calculate a new indicator value directly from incoming data (without using internal state).

This is an abstract function that must be implemented by indicators that don't maintain input history.
"""
function _calculate_new_value_only_from_incoming_data end

"""
    _fit!(ind::TechnicalIndicator, data)

Internal fit function that processes incoming data through the indicator pipeline.

This function:
1. Applies input filter and modifier (if present)
2. Updates input values circular buffer (if present)
3. Fits sub-indicators (if present)
4. Calculates and stores the new indicator value
"""
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
end

"""
    Base.setindex!(o::CircBuff, val, i::Int)

Set the value at index `i` in the circular buffer `o` to `val`.
"""
function Base.setindex!(o::CircBuff, val, i::Int)
    if nobs(o) ≤ length(o.rng.rng)
        o.value[i] = val
    else
        o.value[o.rng[nobs(o)+i]] = val
    end
end

"""
    Base.setindex!(o::CircBuff{<:Any,true}, val, i::Int)    

Set the value at index `i` in the reversed circular buffer `o` to `val`.
"""
function Base.setindex!(o::CircBuff{<:Any,true}, val, i::Int)
    i = length(o.value) - i + 1
    if nobs(o) ≤ length(o.rng.rng)
        o.value[i] = val
    else
        o.value[o.rng[nobs(o)+i]] = val
    end
end

end # module Internals
