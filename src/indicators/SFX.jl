const SFX_ATR_PERIOD = 12
const SFX_STD_DEV_PERIOD = 12
const SFX_STD_DEV_SMOOTHING_PERIOD = 3

"""
    SFXVal{Tval}

Return value type for SFX indicator.

# Fields
- `atr::Union{Missing,Tval}`: Average True Range
- `std_dev::Tval`: Standard deviation of price
- `ma_std_dev::Union{Missing,Tval}`: Moving average of standard deviation

See also: [`SFX`](@ref)
"""
struct SFXVal{Tval}
    atr::Union{Missing,Tval}
    std_dev::Tval
    ma_std_dev::Union{Missing,Tval}
end

"""
    SFX{Tohlcv}(; atr_period = SFX_ATR_PERIOD, std_dev_period = SFX_STD_DEV_PERIOD, std_dev_smoothing_period = SFX_STD_DEV_SMOOTHING_PERIOD, ma = SMA, input_modifier_return_type = Tohlcv)

The `SFX` type implements an SFX (Smoothed Forex) volatility indicator.

SFX combines Average True Range with standard deviation to measure market volatility.
Comparing ATR to smoothed standard deviation helps identify when volatility is expanding
or contracting, useful for timing entries and setting stop losses.

# Parameters
- `atr_period::Integer = $SFX_ATR_PERIOD`: Period for ATR calculation
- `std_dev_period::Integer = $SFX_STD_DEV_PERIOD`: Period for standard deviation
- `std_dev_smoothing_period::Integer = $SFX_STD_DEV_SMOOTHING_PERIOD`: Period for smoothing std dev
- `ma::Type = SMA`: Moving average type for smoothing
- `input_modifier_return_type::Type = Tohlcv`: Input OHLCV type

# Formula
```
ATR = Average True Range over atr_period
StdDev = Standard Deviation of close over std_dev_period
MA_StdDev = SMA(StdDev, std_dev_smoothing_period)
```

# Input
Requires OHLCV data with `high`, `low`, and `close` fields.

# Output
- [`SFXVal`](@ref): Contains `atr`, `std_dev`, and `ma_std_dev` values

# Returns
`Union{Missing,SFXVal}` - The SFX values. `std_dev` available early, others after warm-up.

See also: [`ATR`](@ref), [`StdDev`](@ref), [`BB`](@ref)
"""
mutable struct SFX{Tohlcv,IN,S} <: TechnicalIndicatorMultiOutput{Tohlcv}
    value::Union{Missing,SFXVal}
    n::Int

    atr::ATR
    std_dev::StdDev

    ma_std_dev::MovingAverageIndicator

    function SFX{Tohlcv}(;
        atr_period = SFX_ATR_PERIOD,
        std_dev_period = SFX_STD_DEV_PERIOD,
        std_dev_smoothing_period = SFX_STD_DEV_SMOOTHING_PERIOD,
        ma = SMA,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        S = fieldtype(T2, :close)
        atr = ATR{T2}(period = atr_period)
        std_dev = StdDev{Float64}(period = std_dev_period)
        ma_std_dev = MAFactory(S)(ma, period = std_dev_smoothing_period)
        new{Tohlcv,true,S}(missing, 0, atr, std_dev, ma_std_dev)
    end
end

function SFX(;
    atr_period = SFX_ATR_PERIOD,
    std_dev_period = SFX_STD_DEV_PERIOD,
    std_dev_smoothing_period = SFX_STD_DEV_SMOOTHING_PERIOD,
    ma = SMA,
    input_modifier_return_type = OHLCV{Missing,Float64,Float64},
)
    SFX{input_modifier_return_type}(;
        atr_period = atr_period,
        std_dev_period = std_dev_period,
        std_dev_smoothing_period = std_dev_smoothing_period,
        ma = ma,
        input_modifier_return_type = input_modifier_return_type,
    )
end

function OnlineStatsBase._fit!(ind::SFX, data)
    # Feed ATR with full OHLCV
    fit!(ind.atr, data)
    # Feed std_dev with close price only
    fit!(ind.std_dev, ValueExtractor.extract_close(data))
    # Update the indicator state
    ind.n += 1
    ind.value = _calculate_new_value(ind)
    nothing
end

function _calculate_new_value(ind::SFX)
    if has_output_value(ind.std_dev)
        fit!(ind.ma_std_dev, value(ind.std_dev))
    end

    _atr = value(ind.atr)
    _std_dev = value(ind.std_dev)
    _ma_std_dev = value(ind.ma_std_dev)

    return SFXVal(_atr, _std_dev, _ma_std_dev)
end
