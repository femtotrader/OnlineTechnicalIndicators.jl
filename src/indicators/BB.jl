const BB_PERIOD = 5
const BB_STD_DEV_MULT = 2.0

struct BBVal{Tval}
    lower::Tval
    central::Tval
    upper::Tval
end

"""
    BB{T}(; period = BB_PERIOD, std_dev_mult = BB_STD_DEV_MULT, ma = SMA, input_filter = always_true, input_modifier = identity, input_modifier_return_type = T)

The `BB` type implements Bollinger Bands indicator.
"""
mutable struct BB{T1,T2} <: TechnicalIndicator{T1}
    value::Union{Missing,BBVal}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    period::Integer
    std_dev_mult::T2

    sub_indicators::Series
    central_band::MovingAverageIndicator  # default SMA
    std_dev::StdDev

    input_modifier::Function
    input_filter::Function

    function BB{T1}(;
        period = BB_PERIOD,
        std_dev_mult = BB_STD_DEV_MULT,
        ma = SMA,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = T1,
    ) where {T1}
        T2 = input_modifier_return_type
        _central_band = MAFactory(T2)(ma, period = period)
        _std_dev = StdDev{T2}(period = period)
        sub_indicators = Series(_central_band, _std_dev)
        new{T1,T2}(
            initialize_indicator_common_fields()...,
            period,
            std_dev_mult,
            sub_indicators,
            _central_band,
            _std_dev,
            input_modifier,
            input_filter,
        )
    end
end

function _calculate_new_value(ind::BB)
    if has_output_value(ind.central_band)
        lower = value(ind.central_band) - ind.std_dev_mult * value(ind.std_dev)
        central = value(ind.central_band)
        upper = value(ind.central_band) + ind.std_dev_mult * value(ind.std_dev)
        return BBVal(lower, central, upper)
    else
        return missing
    end
end
