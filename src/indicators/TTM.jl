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

    period::Int
    sub_indicators::Series
    # bb::BB
    # dc::DonchianChannels
    # kc::KeltnerChannels
    # ma::MovingAverageIndicator (default=SMA)

    deltas::CircBuff
    mean_x::S
    denom::S

    function TTM{Tohlcv,S}(;
        period = TTM_PERIOD,
        bb_std_dev_mult = TTM_BB_STD_DEV_MULT,
        kc_atr_mult = TTM_KC_ATR_MULT,
        ma = SMA,
    ) where {Tohlcv,S}
        _bb = BB{S}(; period = period, std_dev_mult = bb_std_dev_mult)
        _bb = FilterTransform(_bb, Tohlcv, transform = candle -> candle.close)
        _dc = DonchianChannels{Tohlcv,S}(; period=period)
        _kc = KeltnerChannels{Tohlcv,S}(; ma_period = period, atr_period = period, atr_mult_up = kc_atr_mult, atr_mult_down = kc_atr_mult)  # ma = EMA by default
        _ma = MAFactory(S)(ma, period)
        _ma = FilterTransform(_ma, Tohlcv, transform = candle -> candle.close)
        sub_indicators = Series(_bb, _dc, _kc, _ma)
        deltas = CircBuff(S, period, rev = false)
        mean_x = sum(1:period-1) / period
        denom = 0
        for x in 0:period-1
            denom += (x - mean_x)^2
        end
        new{Tohlcv,S}(missing, 0, period, sub_indicators, deltas, mean_x, denom)
    end
end

function OnlineStatsBase._fit!(ind::TTM, candle)
    fit!(ind.sub_indicators, candle)
    ind.n += 1

    bb, dc, kc, ma = ind.sub_indicators.stats

    if has_output_value(bb) && has_output_value(kc)

        # squeeze is on if BB is entirely encompassed in KC
        squeeze = value(bb).upper < value(kc).upper && value(bb).lower > value(kc).lower
    
        if has_output_value(ma) && has_output_value(dc)
            fit!(ind.deltas, candle.close - (value(dc).central + value(ma)) / 2.0)
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
    
        ind.value = TTMVal(squeeze, hist)

    else
        ind.value = missing
    end

end
