const GANN_SWING_MIN_BARS = 2

"""
    GannSwingChartVal{T}

A struct representing the result of the Gann Swing Chart calculation.
- `trend`: Current trend state (:uptrend or :downtrend)
- `swing_high`: Current swing high value or missing
- `swing_low`: Current swing low value or missing
- `trend_changed`: Boolean indicating if trend changed in this period
"""
struct GannSwingChartVal{T}
    trend::Symbol
    swing_high::Union{Missing,T}
    swing_low::Union{Missing,T}
    trend_changed::Bool

    # Inner constructor that allows specifying type explicitly
    function GannSwingChartVal{T}(
        trend::Symbol,
        swing_high::Union{Missing,T},
        swing_low::Union{Missing,T},
        trend_changed::Bool,
    ) where {T}
        new{T}(trend, swing_high, swing_low, trend_changed)
    end

    # Outer constructor that infers type from non-missing values
    function GannSwingChartVal(
        trend::Symbol,
        swing_high::T,
        swing_low::Union{Missing,T},
        trend_changed::Bool,
    ) where {T}
        new{T}(trend, swing_high, swing_low, trend_changed)
    end

    function GannSwingChartVal(
        trend::Symbol,
        swing_high::Union{Missing,T},
        swing_low::T,
        trend_changed::Bool,
    ) where {T}
        new{T}(trend, swing_high, swing_low, trend_changed)
    end
end

"""
    GannSwingChart{T}(; min_bars=GANN_SWING_MIN_BARS, input_modifier_return_type = T)

The `GannSwingChart` type implements Gann Swing Chart analysis for trend detection.

This indicator identifies:
- Upswings: Two consecutive higher highs
- Downswings: Two consecutive lower lows
- Trend changes: When prices break previous swing peaks/valleys

# Parameters
- `min_bars`: Minimum number of bars to confirm a swing (default: 2)

# Output
- [`GannSwingChartVal`](@ref): Contains trend state, swing levels, and change signals
"""
mutable struct GannSwingChart{Tval,IN,T2} <: TechnicalIndicatorMultiOutput{Tval}
    value::Union{Missing,GannSwingChartVal}
    n::Int

    min_bars::Int
    current_trend::Symbol

    # Swing tracking
    last_swing_high::Union{Missing,T2}
    last_swing_low::Union{Missing,T2}
    last_high::Union{Missing,T2}
    last_low::Union{Missing,T2}

    # Consecutive tracking for swing detection
    consecutive_higher_highs::Int
    consecutive_lower_lows::Int
    input_values::CircBuff

    function GannSwingChart{Tval}(;
        min_bars = GANN_SWING_MIN_BARS,
        input_modifier_return_type = Tval,
    ) where {Tval}
        T2 = input_modifier_return_type
        S = fieldtype(T2, :close)
        input_values = CircBuff(T2, min_bars + 2, rev = false)

        new{Tval,false,S}(
            missing,
            0,
            min_bars,
            :downtrend,  # Default start with downtrend
            missing,     # last_swing_high
            missing,     # last_swing_low
            missing,     # last_high
            missing,     # last_low
            0,           # consecutive_higher_highs
            0,           # consecutive_lower_lows
            input_values,
        )
    end
end

function _calculate_new_value(ind::GannSwingChart)
    # Always update state, even if we don't have enough data for a result yet
    bars = value(ind.input_values)
    current_bar = bars[end]

    # Need at least one bar to update state
    if length(bars) < 1
        return missing
    end

    # For the first bar, initialize tracking
    if length(bars) == 1
        ind.last_high = current_bar.high
        ind.last_low = current_bar.low
        ind.consecutive_higher_highs = 1
        ind.consecutive_lower_lows = 1
        return missing  # Need more data for swing analysis
    end

    # For subsequent bars, compare to previous bars
    prev_bar = bars[end-1]
    trend_changed = false

    # Update last high/low tracking
    if ismissing(ind.last_high) || current_bar.high > ind.last_high
        if !ismissing(ind.last_high) && current_bar.high > ind.last_high
            ind.consecutive_higher_highs += 1
        else
            ind.consecutive_higher_highs = 1
        end
        ind.last_high = current_bar.high
        ind.consecutive_lower_lows = 0
    elseif current_bar.high < prev_bar.high
        ind.consecutive_higher_highs = 0
    end

    if ismissing(ind.last_low) || current_bar.low < ind.last_low
        if !ismissing(ind.last_low) && current_bar.low < ind.last_low
            ind.consecutive_lower_lows += 1
        else
            ind.consecutive_lower_lows = 1
        end
        ind.last_low = current_bar.low
        ind.consecutive_higher_highs = 0
    elseif current_bar.low > prev_bar.low
        ind.consecutive_lower_lows = 0
    end

    # REQ-020: Upswing detection (two consecutive higher highs)
    if ind.consecutive_higher_highs >= ind.min_bars
        # Store previous swing high before updating
        previous_swing_high = ind.last_swing_high
        ind.last_swing_high = ind.last_high

        # REQ-030: Change to uptrend if breaking previous peak and was downtrend
        # OR establish initial uptrend if no previous swing exists
        if ismissing(previous_swing_high)
            # First swing detected, establish uptrend
            ind.current_trend = :uptrend
            trend_changed = true
        elseif ind.current_trend == :downtrend
            if current_bar.high > previous_swing_high
                ind.current_trend = :uptrend
                trend_changed = true
            end
        end
    end

    # REQ-021: Downswing detection (two consecutive lower lows)
    if ind.consecutive_lower_lows >= ind.min_bars
        # Store previous swing low before updating
        previous_swing_low = ind.last_swing_low
        ind.last_swing_low = ind.last_low

        # REQ-031: Change to downtrend if breaking previous valley and was uptrend
        # OR establish initial downtrend if no previous swing exists
        if ismissing(previous_swing_low)
            # First swing detected, establish downtrend
            ind.current_trend = :downtrend
            trend_changed = true
        elseif ind.current_trend == :uptrend
            if current_bar.low < previous_swing_low
                ind.current_trend = :downtrend
                trend_changed = true
            end
        end
    end

    # Only return a result if we have enough data for swing analysis
    if length(bars) < ind.min_bars + 1
        return missing
    end

    # Extract price type from the OHLCV input
    PriceType = typeof(current_bar.high)
    return GannSwingChartVal{PriceType}(
        ind.current_trend,
        ind.last_swing_high,
        ind.last_swing_low,
        trend_changed,
    )
end

# Constructor for vector input
function GannSwingChart(data::Vector{T}; min_bars = GANN_SWING_MIN_BARS) where {T}
    ind = GannSwingChart{T}(min_bars = min_bars)
    for val in data
        fit!(ind, val)
    end
    return ind
end
