const DonchianChannels_ATR_PERIOD = 5

struct DonchianChannelsVal{Tval}
    lower::Tval
    central::Tval
    upper::Tval
end

"""
    DonchianChannels{Tohlcv,S}(; period = DonchianChannels_ATR_PERIOD)

The DonchianChannels type implements a Donchian Channels indicator.
"""
mutable struct DonchianChannels{Tohlcv,S} <: OnlineStat{Tohlcv}
    value::Union{Missing,DonchianChannelsVal{S}}
    n::Int

    period::Integer

    input::CircBuff{Tohlcv}

    function DonchianChannels{Tohlcv,S}(;
        period = DonchianChannels_ATR_PERIOD,
    ) where {Tohlcv,S}
        input = CircBuff(Tohlcv, period, rev = false)
        new{Tohlcv,S}(missing, 0, period, input)
    end
end

function OnlineStatsBase._fit!(ind::DonchianChannels, candle::OHLCV)
    fit!(ind.input, candle)
    ind.n += 1
    if ind.n >= ind.period
        max_high = max([k.high for k in value(ind.input)]...)
        min_low = min([k.low for k in value(ind.input)]...)
        ind.value = DonchianChannelsVal(min_low, (max_high + min_low) / 2.0, max_high)
    else
        ind.value = missing
    end
end
