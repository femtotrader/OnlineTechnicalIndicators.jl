const DonchianChannels_ATR_PERIOD = 5

struct DonchianChannelsVal{Tval}
    lower::Tval
    central::Tval
    upper::Tval
end

"""
    DonchianChannels{Tohlcv,S}(; period = DonchianChannels_ATR_PERIOD)

The `DonchianChannels` type implements a Donchian Channels indicator.
"""
mutable struct DonchianChannels{Tohlcv,S} <: TechnicalIndicator{Tohlcv}
    value::Union{Missing,DonchianChannelsVal{S}}
    n::Int

    period::Integer

    input_values::CircBuff{Tohlcv}

    function DonchianChannels{Tohlcv,S}(;
        period = DonchianChannels_ATR_PERIOD,
    ) where {Tohlcv,S}
        input = CircBuff(Tohlcv, period, rev = false)
        new{Tohlcv,S}(missing, 0, period, input)
    end
end

function OnlineStatsBase._fit!(ind::DonchianChannels, candle)
    fit!(ind.input_values, candle)
    ind.n += 1
    if ind.n >= ind.period
        max_high = max([k.high for k in value(ind.input_values)]...)
        min_low = min([k.low for k in value(ind.input_values)]...)
        ind.value = DonchianChannelsVal(min_low, (max_high + min_low) / 2.0, max_high)
    else
        ind.value = missing
    end
end
