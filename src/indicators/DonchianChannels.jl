const DonchianChannels_ATR_PERIOD = 5

struct DonchianChannelsVal{Tval}
    lower::Tval
    central::Tval
    upper::Tval
end

"""
    DonchianChannels{Tohlcv,S}(; period = DonchianChannels_ATR_PERIOD, input_filter = always_true, input_modifier = identity, input_modifier_return_type = Tohlcv)

The `DonchianChannels` type implements a Donchian Channels indicator.
"""
mutable struct DonchianChannels{Tohlcv,S} <: TechnicalIndicator{Tohlcv}
    value::Union{Missing,DonchianChannelsVal{S}}
    n::Int

    period::Integer

    input_values::CircBuff{Tohlcv}

    function DonchianChannels{Tohlcv,S}(;
        period = DonchianChannels_ATR_PERIOD,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv,S}
        input_values = CircBuff(Tohlcv, period, rev = false)
        new{Tohlcv,S}(missing, 0, period, input_values)
    end
end

function _calculate_new_value(ind::DonchianChannels)
    if ind.n >= ind.period
        max_high = max([k.high for k in value(ind.input_values)]...)
        min_low = min([k.low for k in value(ind.input_values)]...)
        return DonchianChannelsVal(min_low, (max_high + min_low) / 2.0, max_high)
    else
        return missing
    end
end
