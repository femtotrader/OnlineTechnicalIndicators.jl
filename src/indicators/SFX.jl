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
    SFX{Tohlcv}(; atr_period = SFX_ATR_PERIOD, std_dev_period = SFX_STD_DEV_PERIOD, std_dev_smoothing_period = SFX_STD_DEV_SMOOTHING_PERIOD, ma = SMA, input_modifier_return_type = T)

The `SFX` type implements a SFX indicator.

# Output
- [`SFXVal`](@ref): A value containing `atr`, `std_dev`, and `ma_std_dev` values
"""
mutable struct SFX{Tohlcv,IN,S} <: TechnicalIndicatorMultiOutput{Tohlcv}
    value::Union{Missing,SFXVal}
    n::Int

    sub_indicators::Series
    atr::ATR
    std_dev::StdDev

    ma_std_dev::MovingAverageIndicator

    function SFX{Tohlcv}(;
        atr_period = SFX_ATR_PERIOD,
        std_dev_period = SFX_STD_DEV_PERIOD,
        std_dev_smoothing_period = SFX_STD_DEV_SMOOTHING_PERIOD,
        ma = SMA,
        input_modifier_return_type = Tohlcv) where {Tohlcv}
        T2 = input_modifier_return_type
        S = fieldtype(T2, :close)
        atr = ATR{T2}(period = atr_period)
        std_dev = StdDev{Float64}(
            period = std_dev_period)
        sub_indicators = Series(atr)  # Only ATR receives OHLCV data, std_dev is fed manually
        ma_std_dev = MAFactory(S)(ma, period = std_dev_smoothing_period)
        new{Tohlcv,true,S}(
            missing,
            0,
            sub_indicators,
            atr,
            std_dev,
            ma_std_dev)
    end
end

function SFX(;
    atr_period = SFX_ATR_PERIOD,
    std_dev_period = SFX_STD_DEV_PERIOD,
    std_dev_smoothing_period = SFX_STD_DEV_SMOOTHING_PERIOD,
    ma = SMA,
    input_modifier_return_type = OHLCV{Missing,Float64,Float64})
    SFX{input_modifier_return_type}(;
        atr_period=atr_period,
        std_dev_period=std_dev_period,
        std_dev_smoothing_period=std_dev_smoothing_period,
        ma=ma,
        input_modifier_return_type=input_modifier_return_type)
end

function OnlineStatsBase._fit!(ind::SFX, data)
    # Feed ATR with full OHLCV
    fit!(ind.atr, data)
    # Feed std_dev with close price only
    fit!(ind.std_dev, ValueExtractor.extract_close(data))
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
