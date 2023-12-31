const MACD_FAST_PERIOD = 5
const MACD_SLOW_PERIOD = 5
const MACD_SIGNAL_PERIOD = 5

struct MACDVal{Tval}
    macd::Union{Missing,Tval}
    signal::Union{Missing,Tval}
    histogram::Union{Missing,Tval}
end

"""
    MACD{T}(; fast_period = MACD_FAST_PERIOD, slow_period = MACD_SLOW_PERIOD, signal_period = MACD_SIGNAL_PERIOD, ma = EMA, output_listeners = Series())

The `MACD` type implements Moving Average Convergence Divergence indicator.
"""
mutable struct MACD{Tval} <: TechnicalIndicator{Tval}
    value::Union{Missing,MACDVal{Tval}}
    n::Int

    output_listeners::Series

    sub_indicators::Series
    fast_ma::EMA{Tval}
    slow_ma::EMA{Tval}

    signal_line::EMA{Tval}

    input_indicator::Union{Missing,TechnicalIndicator}

    function MACD{Tval}(;
        fast_period = MACD_FAST_PERIOD,
        slow_period = MACD_SLOW_PERIOD,
        signal_period = MACD_SIGNAL_PERIOD,
        ma = EMA,
    ) where {Tval}
        # fast_ma = EMA{Tval}(period = fast_period)
        # slow_ma = EMA{Tval}(period = slow_period)
        fast_ma = MAFactory(Tval)(ma, period = fast_period)
        slow_ma = MAFactory(Tval)(ma, period = slow_period)
        sub_indicators = Series(fast_ma, slow_ma)
        # signal_line = EMA{Tval}(period = signal_period)
        signal_line = MAFactory(Tval)(ma, period = signal_period)
        output_listeners = Series()
        input_indicator = missing
        new{Tval}(
            missing,
            0,
            output_listeners,
            sub_indicators,
            fast_ma,
            slow_ma,
            signal_line,
            input_indicator,
        )
    end
end

function _calculate_new_value(ind::MACD)
    if has_output_value(ind.fast_ma) && has_output_value(ind.slow_ma)
        macd = value(ind.fast_ma) - value(ind.slow_ma)
        fit!(ind.signal_line, macd)

        if has_output_value(ind.signal_line)
            signal = value(ind.signal_line)
        else
            signal = missing
        end

        histogram = missing
        if (!ismissing(macd)) && (!ismissing(signal))
            histogram = macd - signal
        end

        return MACDVal(macd, signal, histogram)
    else
        return missing
    end
end
