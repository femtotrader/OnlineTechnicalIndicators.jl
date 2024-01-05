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
mutable struct DonchianChannels{Tohlcv} <: TechnicalIndicatorMultiOutput{Tohlcv}
    value::Union{Missing,DonchianChannelsVal}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    period::Integer

    input_modifier::Function
    input_filter::Function
    input_values::CircBuff

    function DonchianChannels{Tohlcv}(;
        period = DonchianChannels_ATR_PERIOD,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        S = fieldtype(T2, :close)
        input_values = CircBuff(T2, period, rev = false)
        new{Tohlcv}(
            initialize_indicator_common_fields()...,
            period,
            input_modifier,
            input_filter,
            input_values,
        )
    end
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
