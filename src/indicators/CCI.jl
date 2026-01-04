const CCI_PERIOD = 3

"""
    CCI{Tohlcv}(; period = CCI_PERIOD, input_modifier_return_type = Tohlcv)

The `CCI` type implements a Commodity Channel Index.

CCI measures how far the current typical price deviates from its statistical mean.
Developed by Donald Lambert, it's used to identify cyclical trends and overbought/oversold conditions.

# Parameters
- `period::Integer = $CCI_PERIOD`: The lookback period for the moving average and mean deviation
- `input_modifier_return_type::Type = Tohlcv`: Input type (must be OHLCV-compatible)

# Input
[`OHLCV`](@ref) candlestick data with `high`, `low`, and `close` fields.

# Formula
```
Typical Price = (High + Low + Close) / 3
CCI = (Typical Price - SMA(Typical Price)) / (0.015 * Mean Deviation)
```
The constant 0.015 ensures that approximately 70-80% of CCI values fall between -100 and +100.

# Returns
`Union{Missing,T}` - The CCI value, or `missing` during the warm-up period.
Values above +100 indicate overbought, below -100 indicate oversold.

See also: [`MeanDev`](@ref), [`OHLCV`](@ref)
"""
mutable struct CCI{Tohlcv,IN,S} <: TechnicalIndicatorSingleOutput{Tohlcv}
    value::Union{Missing,S}
    n::Int

    period::Integer

    mean_dev::MeanDev

    function CCI{Tohlcv}(;
        period = CCI_PERIOD,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        S = fieldtype(T2, :close)
        mean_dev = MeanDev{S}(period = period)
        new{Tohlcv,true,S}(missing, 0, period, mean_dev)
    end
end

function CCI(;
    period = CCI_PERIOD,
    input_modifier_return_type = OHLCV{Missing,Float64,Float64},
)
    CCI{input_modifier_return_type}(;
        period = period,
        input_modifier_return_type = input_modifier_return_type,
    )
end

function _calculate_new_value_only_from_incoming_data(ind::CCI, candle)
    typical_price = (candle.high + candle.low + candle.close) / 3.0
    fit!(ind.mean_dev, typical_price)
    return has_output_value(ind.mean_dev) ?
           (typical_price - value(ind.mean_dev.ma)) / (0.015 * value(ind.mean_dev)) :
           missing
end
