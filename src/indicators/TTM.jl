const TTM_PERIOD = 20
const TTM_BB_STD_DEV_MULT = 2.0
const TTM_KC_ATR_MULT = 2.0# 1.5

struct TTMVal{Tval}
    squeeze::Bool  # squeeze is on (=True) or off (=False)
    histogram::Tval  # histogram of the linear regression
end

"""
    TTM{Tohlcv,S}(; atr_period = TTM_ATR_PERIOD, std_dev_period = TTM_STD_DEV_PERIOD, std_dev_smoothing_period = TTM_STD_DEV_SMOOTHING_PERIOD, ma = SMA)

The `TTM` type implements a TTM indicator.
"""
mutable struct TTM{Tohlcv,S} <: TechnicalIndicator{Tohlcv}
    value::Union{Missing,TTMVal}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    period::Int
    sub_indicators::Series
    bb::BB
    dc::DonchianChannels
    kc::KeltnerChannels
    ma::MovingAverageIndicator  # default=SMA

    deltas::CircBuff
    mean_x::S
    denom::S

    input_modifier::Function
    input_filter::Function
    input_values::CircBuff

    function TTM{Tohlcv}(;
        period = TTM_PERIOD,
        bb_std_dev_mult = TTM_BB_STD_DEV_MULT,
        kc_atr_mult = TTM_KC_ATR_MULT,
        ma = SMA,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        S = fieldtype(T2, :close)
        input_values = CircBuff(T2, 1, rev = false)  # (maybe) a bit overkilled! but that's to keep the same interface
        _bb = BB{S}(;
            period = period,
            std_dev_mult = bb_std_dev_mult,
            input_modifier = ValueExtractor.extract_close,
        )
        _dc = DonchianChannels{T2}(; period = period)
        _kc = KeltnerChannels{T2}(;
            ma_period = period,
            atr_period = period,
            atr_mult_up = kc_atr_mult,
            atr_mult_down = kc_atr_mult,
        )  # ma = EMA by default
        _ma =
            MAFactory(S)(ma, period = period, input_modifier = ValueExtractor.extract_close)
        sub_indicators = Series(_bb, _dc, _kc, _ma)
        deltas = CircBuff(S, period, rev = false)
        mean_x = sum(1:period-1) / period
        denom = 0
        for x = 0:period-1
            denom += (x - mean_x)^2
        end
        new{Tohlcv,S}(
            initialize_indicator_common_fields()...,
            period,
            sub_indicators,
            _bb,
            _dc,
            _kc,
            _ma,
            deltas,
            mean_x,
            denom,
            input_modifier,
            input_filter,
            input_values,
        )
    end
end

function _calculate_new_value(ind::TTM)
    if has_output_value(ind.bb) && has_output_value(ind.kc)

        # squeeze is on if BB is entirely encompassed in KC
        squeeze =
            value(ind.bb).upper < value(ind.kc).upper &&
            value(ind.bb).lower > value(ind.kc).lower

        if has_output_value(ind.ma) && has_output_value(ind.dc)
            candle = ind.input_values[end]
            fit!(ind.deltas, candle.close - (value(ind.dc).central + value(ind.ma)) / 2.0)
        end

        hist = missing
        if length(ind.deltas) >= ind.period
            # calculate linear regression y = ax + b
            mean_y = sum(ind.deltas.value) / ind.period

            numer = 0.0
            for (x, y) in zip(0:ind.period-1, value(ind.deltas))
                numer += (x - ind.mean_x) * (y - mean_y)
            end
            a = numer / ind.denom
            b = mean_y - (a * ind.mean_x)

            hist = a * (ind.period - 1) + b
        end

        return TTMVal(squeeze, hist)

    else
        return missing
    end

end
