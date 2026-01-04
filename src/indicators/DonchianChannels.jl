const DonchianChannels_ATR_PERIOD = 5

"""
    DonchianChannelsVal{Tval}

Return value type for Donchian Channels indicator.

# Fields
- `lower::Tval`: Lower channel (lowest low over period)
- `central::Tval`: Central line (midpoint between upper and lower)
- `upper::Tval`: Upper channel (highest high over period)

See also: [`DonchianChannels`](@ref)
"""
struct DonchianChannelsVal{Tval}
    lower::Tval
    central::Tval
    upper::Tval
end

"""
    DonchianChannels{Tohlcv}(; period = DonchianChannels_ATR_PERIOD, input_modifier_return_type = Tohlcv)

The `DonchianChannels` type implements a Donchian Channels indicator.

Donchian Channels plot the highest high and lowest low over a period, with a central line
at the midpoint. Breakouts above the upper channel signal potential uptrends, while breaks
below the lower channel signal potential downtrends. Also known as price channels.

# Parameters
- `period::Integer = $DonchianChannels_ATR_PERIOD`: The lookback period for channel calculation
- `input_modifier_return_type::Type = Tohlcv`: Input OHLCV type

# Formula
```
Upper = highest_high(period)
Lower = lowest_low(period)
Central = (Upper + Lower) / 2
```

# Input
Requires OHLCV data with `high` and `low` fields.

# Output
- [`DonchianChannelsVal`](@ref): Contains `upper`, `central`, and `lower` channel values

# Returns
`Union{Missing,DonchianChannelsVal}` - The channel values, or `missing` during warm-up.

See also: [`KeltnerChannels`](@ref), [`BB`](@ref), [`GannHiloActivator`](@ref)
"""
mutable struct DonchianChannels{Tohlcv,IN,S} <: TechnicalIndicatorMultiOutput{Tohlcv}
    value::Union{Missing,DonchianChannelsVal}
    n::Int

    period::Integer
    input_values::CircBuff

    function DonchianChannels{Tohlcv}(;
        period = DonchianChannels_ATR_PERIOD,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        S = fieldtype(T2, :close)
        input_values = CircBuff(T2, period, rev = false)
        new{Tohlcv,true,S}(missing, 0, period, input_values)
    end
end

function DonchianChannels(;
    period = DonchianChannels_ATR_PERIOD,
    input_modifier_return_type = OHLCV{Missing,Float64,Float64},
)
    DonchianChannels{input_modifier_return_type}(;
        period = period,
        input_modifier_return_type = input_modifier_return_type,
    )
end

function _calculate_new_value(ind::DonchianChannels)
    if ind.n >= ind.period
        max_high = max((k.high for k in value(ind.input_values))...)
        min_low = min((k.low for k in value(ind.input_values))...)
        return DonchianChannelsVal(min_low, (max_high + min_low) / 2.0, max_high)
    else
        return missing
    end
end
