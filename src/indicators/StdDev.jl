const StdDev_PERIOD = 3

"""
    StdDev{T}(; period = StdDev_PERIOD, input_modifier_return_type = T)

The `StdDev` type implements a Standard Deviation indicator.

Standard Deviation measures the dispersion of data points from their mean.
Higher values indicate greater volatility. Often used with Bollinger Bands.

# Parameters
- `period::Integer = $StdDev_PERIOD`: The lookback period for the calculation
- `input_modifier_return_type::Type = T`: Output value type (defaults to input type)

# Formula
`StdDev = sqrt(Σ(price_i - mean)² / period)`

This is the population standard deviation (divides by n, not n-1).

# Returns
`Union{Missing,T}` - The standard deviation value, or `missing` during the warm-up period.

See also: [`MeanDev`](@ref), [`BB`](@ref)
"""
mutable struct StdDev{T1,IN,T2} <: TechnicalIndicatorSingleOutput{T1}
    value::Union{Missing,T2}
    n::Int

    period::Integer
    input_values::CircBuff

    function StdDev{T1}(;
        period = StdDev_PERIOD,
        input_modifier_return_type = T1,
    ) where {T1}
        T2 = input_modifier_return_type
        input_values = CircBuff(T2, period, rev = false)
        new{T1,false,T2}(missing, 0, period, input_values)
    end
end

function StdDev(; period = StdDev_PERIOD, input_modifier_return_type = Float64)
    StdDev{input_modifier_return_type}(;
        period = period,
        input_modifier_return_type = input_modifier_return_type,
    )
end

function _calculate_new_value(ind::StdDev)
    _mean = sum(value(ind.input_values)) / ind.period
    return sqrt(sum([(item - _mean)^2 for item in value(ind.input_values)]) / ind.period)
end
