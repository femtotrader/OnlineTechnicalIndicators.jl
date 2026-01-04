const KeltnerChannels_MA_PERIOD = 10
const KeltnerChannels_ATR_PERIOD = 10
const KeltnerChannels_ATR_MULT_UP = 2.0
const KeltnerChannels_ATR_MULT_DOWN = 3.0

"""
    KeltnerChannelsVal{Tval}

Return value type for Keltner Channels indicator.

# Fields
- `lower::Tval`: Lower channel (central - ATR * multiplier)
- `central::Tval`: Central line (moving average)
- `upper::Tval`: Upper channel (central + ATR * multiplier)

See also: [`KeltnerChannels`](@ref)
"""
struct KeltnerChannelsVal{Tval}
    lower::Tval
    central::Tval
    upper::Tval
end

"""
    KeltnerChannels{Tohlcv}(; ma_period = KeltnerChannels_MA_PERIOD, atr_period = KeltnerChannels_ATR_PERIOD, atr_mult_up = KeltnerChannels_ATR_MULT_UP, atr_mult_down = KeltnerChannels_ATR_MULT_DOWN, ma = EMA, input_modifier_return_type = Tohlcv)

The `KeltnerChannels` type implements a Keltner Channels indicator.

Keltner Channels are volatility-based envelopes set above and below a moving average.
They use ATR to determine channel width. Price touching the upper channel suggests
overbought conditions, while touching the lower channel suggests oversold conditions.

# Parameters
- `ma_period::Integer = $KeltnerChannels_MA_PERIOD`: Period for the central moving average
- `atr_period::Integer = $KeltnerChannels_ATR_PERIOD`: Period for ATR calculation
- `atr_mult_up::Number = $KeltnerChannels_ATR_MULT_UP`: ATR multiplier for upper channel
- `atr_mult_down::Number = $KeltnerChannels_ATR_MULT_DOWN`: ATR multiplier for lower channel
- `ma::Type = EMA`: Moving average type for central band
- `input_modifier_return_type::Type = Tohlcv`: Input OHLCV type

# Formula
```
Central = EMA(close, ma_period)
Upper = Central + (atr_mult_up × ATR)
Lower = Central - (atr_mult_down × ATR)
```

# Input
Requires OHLCV data with `high`, `low`, and `close` fields.

# Output
- [`KeltnerChannelsVal`](@ref): Contains `upper`, `central`, and `lower` channel values

# Returns
`Union{Missing,KeltnerChannelsVal}` - The channel values, or `missing` during warm-up.

See also: [`BB`](@ref), [`DonchianChannels`](@ref), [`ATR`](@ref)
"""
mutable struct KeltnerChannels{Tohlcv,IN,S} <: TechnicalIndicatorMultiOutput{Tohlcv}
    value::Union{Missing,KeltnerChannelsVal{S}}
    n::Int

    ma_period::Integer
    atr_period::Integer
    atr_mult_up::S
    atr_mult_down::S

    atr::ATR
    cb::MovingAverageIndicator  # EMA default

    function KeltnerChannels{Tohlcv}(;
        ma_period = KeltnerChannels_MA_PERIOD,
        atr_period = KeltnerChannels_ATR_PERIOD,
        atr_mult_up = KeltnerChannels_ATR_MULT_UP,
        atr_mult_down = KeltnerChannels_ATR_MULT_DOWN,
        ma = EMA,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        S = fieldtype(T2, :close)
        atr = ATR{T2}(period = atr_period)
        _cb = MovingAverage(S)(ma, period = ma_period)
        new{Tohlcv,true,S}(
            missing,
            0,
            ma_period,
            atr_period,
            atr_mult_up,
            atr_mult_down,
            atr,
            _cb,
        )
    end
end

function KeltnerChannels(;
    ma_period = KeltnerChannels_MA_PERIOD,
    atr_period = KeltnerChannels_ATR_PERIOD,
    atr_mult_up = KeltnerChannels_ATR_MULT_UP,
    atr_mult_down = KeltnerChannels_ATR_MULT_DOWN,
    ma = EMA,
    input_modifier_return_type = OHLCV{Missing,Float64,Float64},
)
    KeltnerChannels{input_modifier_return_type}(;
        ma_period = ma_period,
        atr_period = atr_period,
        atr_mult_up = atr_mult_up,
        atr_mult_down = atr_mult_down,
        ma = ma,
        input_modifier_return_type = input_modifier_return_type,
    )
end

function OnlineStatsBase._fit!(ind::KeltnerChannels, data)
    # Feed ATR with full OHLCV
    fit!(ind.atr, data)
    # Feed central band MA with close price only
    fit!(ind.cb, ValueExtractor.extract_close(data))
    # Update the indicator state
    ind.n += 1
    ind.value = _calculate_new_value(ind)
    nothing
end

function _calculate_new_value(ind::KeltnerChannels)
    if has_output_value(ind.atr) && has_output_value(ind.cb)
        return KeltnerChannelsVal(
            value(ind.cb) - ind.atr_mult_down * value(ind.atr),
            value(ind.cb),
            value(ind.cb) + ind.atr_mult_up * value(ind.atr),
        )
    else
        return missing
    end
end
