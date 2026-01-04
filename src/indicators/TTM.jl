const TTM_PERIOD = 20
const TTM_BB_STD_DEV_MULT = 2.0
const TTM_KC_ATR_MULT = 2.0  # 1.5

"""
    TTMVal{Tval}

Return value type for TTM Squeeze indicator.

# Fields
- `squeeze::Bool`: Squeeze status (true = squeeze on, false = squeeze off)
- `histogram::Tval`: Momentum histogram value

See also: [`TTM`](@ref)
"""
struct TTMVal{Tval}
    squeeze::Bool  # squeeze is on (=True) or off (=False)
    histogram::Tval  # histogram of the linear regression
end

"""
    TTM{Tohlcv}(; atr_period = TTM_ATR_PERIOD, std_dev_period = TTM_STD_DEV_PERIOD, std_dev_smoothing_period = TTM_STD_DEV_SMOOTHING_PERIOD, ma = SMA)

The `TTM` type implements a TTM indicator.

# Output
- [`TTMVal`](@ref): A value containing `squeeze` and `histogram` values
"""
mutable struct TTM{Tohlcv,IN,S} <: TechnicalIndicatorMultiOutput{Tohlcv}
    value::Union{Missing,TTMVal}
    n::Int

    period::Int
    sub_indicators::Series
    bb::BB
    dc::DonchianChannels
    kc::KeltnerChannels
    ma::MovingAverageIndicator  # default=SMA

    deltas::CircBuff
    mean_x::S
    denom::S
    input_values::CircBuff

    function TTM{Tohlcv}(;
        period = TTM_PERIOD,
        bb_std_dev_mult = TTM_BB_STD_DEV_MULT,
        kc_atr_mult = TTM_KC_ATR_MULT,
        ma = SMA,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        S = fieldtype(T2, :close)
        input_values = CircBuff(T2, 1, rev = false)  # (maybe) a bit overkilled! but that's to keep the same interface
        _bb = BB{S}(; period = period, std_dev_mult = bb_std_dev_mult)
        _dc = DonchianChannels{T2}(; period = period)
        _kc = KeltnerChannels{T2}(;
            ma_period = period,
            atr_period = period,
            atr_mult_up = kc_atr_mult,
            atr_mult_down = kc_atr_mult,
        )  # ma = EMA by default
        _ma = MAFactory(S)(ma, period = period)
        sub_indicators = Series(_dc, _kc)  # _bb and _ma receive close price, fed manually
        deltas = CircBuff(S, period, rev = false)
        mean_x = sum(1:period-1) / period
        denom = 0
        for x = 0:period-1
            denom += (x - mean_x)^2
        end
        new{Tohlcv,true,S}(
            missing,
            0,
            period,
            sub_indicators,
            _bb,
            _dc,
            _kc,
            _ma,
            deltas,
            mean_x,
            denom,
            input_values,
        )
    end
end

function TTM(;
    period = TTM_PERIOD,
    bb_std_dev_mult = TTM_BB_STD_DEV_MULT,
    kc_atr_mult = TTM_KC_ATR_MULT,
    ma = SMA,
    input_modifier_return_type = OHLCV{Missing,Float64,Float64},
)
    TTM{input_modifier_return_type}(;
        period = period,
        bb_std_dev_mult = bb_std_dev_mult,
        kc_atr_mult = kc_atr_mult,
        ma = ma,
        input_modifier_return_type = input_modifier_return_type,
    )
end

function OnlineStatsBase._fit!(ind::TTM, data)
    # Store input data
    fit!(ind.input_values, data)
    # Feed DC and KC with full OHLCV (via sub_indicators)
    fit!(ind.sub_indicators, data)
    # Feed BB and MA with close price only
    close_price = ValueExtractor.extract_close(data)
    fit!(ind.bb, close_price)
    fit!(ind.ma, close_price)
    # Update the indicator state
    ind.n += 1
    ind.value = _calculate_new_value(ind)
    nothing
end

function _calculate_new_value(ind::TTM{T,IN,S}) where {T,IN,S}
    if has_output_value(ind.bb) && has_output_value(ind.kc)

        # squeeze is on if BB is entirely encompassed in KC
        squeeze =
            value(ind.bb).upper < value(ind.kc).upper &&
            value(ind.bb).lower > value(ind.kc).lower

        if has_output_value(ind.ma) && has_output_value(ind.dc)
            candle = ind.input_values[end]
            fit!(ind.deltas, candle.close - (value(ind.dc).central + value(ind.ma)) / 2)
        end

        hist = missing
        if length(ind.deltas) >= ind.period
            # calculate linear regression y = ax + b
            mean_y = sum(ind.deltas.value) / ind.period

            numer = zero(S)
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
