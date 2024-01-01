const SOBV_PERIOD = 20

"""
    SOBV{Tohlcv,S}(; period = SOBV_PERIOD, ma = SMA, input_filter = always_true, input_modifier = identity, input_modifier_return_type = Tohlcv)

The `SOBV` type implements a Smoothed On Balance Volume indicator.
"""
mutable struct SOBV{Tohlcv,S} <: TechnicalIndicator{Tohlcv}
    value::Union{Missing,S}
    n::Int

    output_listeners::Series

    period::Integer

    sub_indicators::Series
    obv::OBV
    obv_ma::SMA

    input_modifier::Function
    input_filter::Function
    input_indicator::Union{Missing,TechnicalIndicator}

    function SOBV{Tohlcv,S}(;
        period = SOBV_PERIOD,
        ma = SMA,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv,S}
        T2 = input_modifier_return_type
        obv = OBV{T2,S}()
        # obv_ma = SMA{S}(period = period)
        obv_ma = MAFactory(S)(ma, period = period)
        sub_indicators = Series(obv)
        output_listeners = Series()
        input_indicator = missing
        new{Tohlcv,S}(
            missing,
            0,
            output_listeners,
            period,
            sub_indicators,
            obv,
            obv_ma,
            input_modifier,
            input_filter,
            input_indicator,
        )
    end
end

function _calculate_new_value(ind::SOBV)
    fit!(ind.obv_ma, value(ind.obv))
    if has_output_value(ind.obv_ma)
        return value(ind.obv_ma)
    else
        return missing
    end
end
