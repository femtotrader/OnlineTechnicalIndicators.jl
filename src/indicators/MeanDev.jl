const MeanDev_PERIOD = 3

"""
    MeanDev{T}(; period = MeanDev_PERIOD, ma = SMA, input_modifier_return_type = T)

The `MeanDev` type implements a Mean Deviation indicator.

Mean Deviation (also called Mean Absolute Deviation) measures the average distance
of data points from their mean. It's a measure of dispersion similar to standard
deviation but uses absolute values instead of squares.

# Parameters
- `period::Integer = $MeanDev_PERIOD`: The lookback period for the calculation
- `ma::Type = SMA`: The moving average type to use for the mean
- `input_modifier_return_type::Type = T`: Output value type (defaults to input type)

# Formula
`MeanDev = Σ|price_i - MA(price)| / period`

# Returns
`Union{Missing,T}` - The mean deviation value, or `missing` during the warm-up period.

See also: [`StdDev`](@ref), [`CCI`](@ref), [`SMA`](@ref)
"""
mutable struct MeanDev{Tval,IN,T2} <: TechnicalIndicatorSingleOutput{Tval}
    value::Union{Missing,T2}
    n::Int

    period::Integer

    sub_indicators::Series  # field ma needs to be available for CCI calculation
    ma::MovingAverageIndicator  # SMA
    input_values::CircBuff

    function MeanDev{Tval}(;
        period = MeanDev_PERIOD,
        ma = SMA,
        input_modifier_return_type = Tval,
    ) where {Tval}
        T2 = input_modifier_return_type
        input_values = CircBuff(T2, period, rev = false)
        _ma = MovingAverage(T2)(ma, period = period)
        sub_indicators = Series(_ma)
        new{Tval,false,T2}(missing, 0, period, sub_indicators, _ma, input_values)
    end
end

function MeanDev(; period = MeanDev_PERIOD, ma = SMA, input_modifier_return_type = Float64)
    MeanDev{input_modifier_return_type}(;
        period = period,
        ma = ma,
        input_modifier_return_type = input_modifier_return_type,
    )
end

function _calculate_new_value(ind::MeanDev)
    _ma = value(ind.ma)
    return sum(abs.(value(ind.input_values) .- _ma)) / ind.period
end
