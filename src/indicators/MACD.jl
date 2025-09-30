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
    MACD{T}(; fast_period = MACD_FAST_PERIOD, slow_period = MACD_SLOW_PERIOD, signal_period = MACD_SIGNAL_PERIOD, ma = EMA, input_filter = always_true, input_modifier = identity, input_modifier_return_type = T)

The `MACD` type implements Moving Average Convergence Divergence indicator.

# Output
- [`MACDVal`](@ref): A value containing `macd`, `signal`, and `histogram` values
"""
mutable struct MACD{Tval,IN,S} <: TechnicalIndicatorMultiOutput{Tval}
    value::Union{Missing,MACDVal}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    sub_indicators::Series
    fast_ma::MovingAverageIndicator  # EMA
    slow_ma::MovingAverageIndicator  # EMA

    signal_line::MovingAverageIndicator  # EMA

    input_modifier::Function
    input_filter::Function

    function MACD{Tval}(;
        fast_period = MACD_FAST_PERIOD,
        slow_period = MACD_SLOW_PERIOD,
        signal_period = MACD_SIGNAL_PERIOD,
        ma = EMA,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tval,
    ) where {Tval}
        T2 = input_modifier_return_type
        fast_ma = MAFactory(T2)(ma, period = fast_period)
        slow_ma = MAFactory(T2)(ma, period = slow_period)
        sub_indicators = Series(fast_ma, slow_ma)
        signal_line = MAFactory(T2)(ma, period = signal_period)
        new{Tval,false,T2}(
            initialize_indicator_common_fields()...,
            sub_indicators,
            fast_ma,
            slow_ma,
            signal_line,
            input_modifier,
            input_filter,
        )
    end
end

function MACD(;
    fast_period = MACD_FAST_PERIOD,
    slow_period = MACD_SLOW_PERIOD,
    signal_period = MACD_SIGNAL_PERIOD,
    ma = EMA,
    input_filter = always_true,
    input_modifier = identity,
    input_modifier_return_type = Float64,
)
    MACD{input_modifier_return_type}(;
        fast_period=fast_period,
        slow_period=slow_period,
        signal_period=signal_period,
        ma=ma,
        input_filter=input_filter,
        input_modifier=input_modifier,
        input_modifier_return_type=input_modifier_return_type)
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
