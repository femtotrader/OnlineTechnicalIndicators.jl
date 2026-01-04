const MACD_FAST_PERIOD = 12
const MACD_SLOW_PERIOD = 26
const MACD_SIGNAL_PERIOD = 9

"""
    MACDVal{Tval}

Return value type for Moving Average Convergence Divergence indicator.

# Fields
- `macd::Union{Missing,Tval}`: MACD line (fast MA - slow MA)
- `signal::Union{Missing,Tval}`: Signal line (MA of MACD line)
- `histogram::Union{Missing,Tval}`: MACD histogram (MACD - signal)

See also: [`MACD`](@ref)
"""
struct MACDVal{Tval}
    macd::Union{Missing,Tval}
    signal::Union{Missing,Tval}
    histogram::Union{Missing,Tval}
end

function is_valid(macd_val::MACDVal)
    return !ismissing(macd_val.macd) &&
           !ismissing(macd_val.signal) &&
           !ismissing(macd_val.histogram)
end

"""
    MACD{T}(; fast_period = MACD_FAST_PERIOD, slow_period = MACD_SLOW_PERIOD, signal_period = MACD_SIGNAL_PERIOD, ma = EMA, input_modifier_return_type = T)

The `MACD` type implements a Moving Average Convergence Divergence indicator.

MACD shows the relationship between two moving averages. The MACD line crossing above
the signal line is a bullish signal, while crossing below is bearish. The histogram
visualizes the difference between MACD and signal for easier trend identification.

# Parameters
- `fast_period::Integer = $MACD_FAST_PERIOD`: Period for the fast moving average
- `slow_period::Integer = $MACD_SLOW_PERIOD`: Period for the slow moving average
- `signal_period::Integer = $MACD_SIGNAL_PERIOD`: Period for the signal line
- `ma::Type = EMA`: Moving average type (typically EMA)
- `input_modifier_return_type::Type = T`: Output value type

# Formula
```
MACD Line = EMA(fast_period) - EMA(slow_period)
Signal Line = EMA(MACD Line, signal_period)
Histogram = MACD Line - Signal Line
```

# Output
- [`MACDVal`](@ref): Contains `macd`, `signal`, and `histogram` values

# Returns
`Union{Missing,MACDVal}` - The MACD values, or `missing` during warm-up.

See also: [`EMA`](@ref), [`RSI`](@ref), [`Aroon`](@ref)
"""
mutable struct MACD{Tval,IN,S} <: TechnicalIndicatorMultiOutput{Tval}
    value::Union{Missing,MACDVal}
    n::Int

    sub_indicators::Series
    fast_ma::MovingAverageIndicator  # EMA
    slow_ma::MovingAverageIndicator  # EMA

    signal_line::MovingAverageIndicator  # EMA

    function MACD{Tval}(;
        fast_period = MACD_FAST_PERIOD,
        slow_period = MACD_SLOW_PERIOD,
        signal_period = MACD_SIGNAL_PERIOD,
        ma = EMA,
        input_modifier_return_type = Tval,
    ) where {Tval}
        T2 = input_modifier_return_type
        fast_ma = MAFactory(T2)(ma, period = fast_period)
        slow_ma = MAFactory(T2)(ma, period = slow_period)
        sub_indicators = Series(fast_ma, slow_ma)
        signal_line = MAFactory(T2)(ma, period = signal_period)
        new{Tval,false,T2}(missing, 0, sub_indicators, fast_ma, slow_ma, signal_line)
    end
end

function MACD(;
    fast_period = MACD_FAST_PERIOD,
    slow_period = MACD_SLOW_PERIOD,
    signal_period = MACD_SIGNAL_PERIOD,
    ma = EMA,
    input_modifier_return_type = Float64,
)
    MACD{input_modifier_return_type}(;
        fast_period = fast_period,
        slow_period = slow_period,
        signal_period = signal_period,
        ma = ma,
        input_modifier_return_type = input_modifier_return_type,
    )
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
