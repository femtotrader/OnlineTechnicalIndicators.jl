const SOBV_PERIOD = 20

"""
    SOBV{Tohlcv}(; period = SOBV_PERIOD, ma = SMA, input_modifier_return_type = Tohlcv)

The `SOBV` type implements a Smoothed On Balance Volume indicator.
"""
mutable struct SOBV{Tohlcv,IN,S} <: TechnicalIndicatorSingleOutput{Tohlcv}
    value::Union{Missing,S}
    n::Int

    period::Integer

    sub_indicators::Series
    obv::OBV
    obv_ma::MovingAverageIndicator

    function SOBV{Tohlcv}(;
        period = SOBV_PERIOD,
        ma = SMA,
        input_modifier_return_type = Tohlcv) where {Tohlcv}
        T2 = input_modifier_return_type
        S = fieldtype(T2, :close)
        obv = OBV{T2}()
        obv_ma = MAFactory(S)(ma, period = period)
        sub_indicators = Series(obv)
        new{Tohlcv,true,S}(
            missing,
            0,
            period,
            sub_indicators,
            obv,
            obv_ma)
    end
end

function SOBV(;
    period = SOBV_PERIOD,
    ma = SMA,
    input_modifier_return_type = OHLCV{Missing,Float64,Float64})
    SOBV{input_modifier_return_type}(;
        period=period,
        ma=ma,
        input_modifier_return_type=input_modifier_return_type)
end

function _calculate_new_value(ind::SOBV)
    fit!(ind.obv_ma, value(ind.obv))
    if has_output_value(ind.obv_ma)
        return value(ind.obv_ma)
    else
        return missing
    end
end
