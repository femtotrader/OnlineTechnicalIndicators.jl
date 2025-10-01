const PEAK_VALLEY_LOOKBACK = 5

"""
    PeakValleyVal{T}

A struct representing detected peaks and valleys.
- `peak`: Current peak value or missing
- `valley`: Current valley value or missing  
- `peak_bar_index`: Index of peak bar or missing
- `valley_bar_index`: Index of valley bar or missing
- `is_new_peak`: Boolean indicating if this is a newly detected peak
- `is_new_valley`: Boolean indicating if this is a newly detected valley
"""
struct PeakValleyVal{T}
    peak::Union{Missing,T}
    valley::Union{Missing,T}
    peak_bar_index::Union{Missing,Int}
    valley_bar_index::Union{Missing,Int}
    is_new_peak::Bool
    is_new_valley::Bool
    
    # Inner constructor that allows specifying type explicitly
    function PeakValleyVal{T}(peak::Union{Missing,T}, valley::Union{Missing,T}, 
                             peak_bar_index::Union{Missing,Int}, valley_bar_index::Union{Missing,Int},
                             is_new_peak::Bool, is_new_valley::Bool) where T
        new{T}(peak, valley, peak_bar_index, valley_bar_index, is_new_peak, is_new_valley)
    end
end

"""
    PeakValleyDetector{T}(; lookback=PEAK_VALLEY_LOOKBACK, input_filter = always_true, input_modifier = identity, input_modifier_return_type = T)

The `PeakValleyDetector` type identifies significant peaks and valleys in price data.

This indicator detects:
- Peaks: Local high points where price is higher than surrounding bars
- Valleys: Local low points where price is lower than surrounding bars
- Support/Resistance levels based on these peaks and valleys

# Parameters
- `lookback`: Number of bars to look back/forward for peak/valley confirmation (default: 5)

# Output
- [`PeakValleyVal`](@ref): Contains peak/valley levels and detection signals

Implements REQ-003: Identify peaks and valleys of each swing
"""
mutable struct PeakValleyDetector{Tval,IN,T2} <: TechnicalIndicatorMultiOutput{Tval}
    value::Union{Missing,PeakValleyVal}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    lookback::Int
    
    # Current state
    current_peak::Union{Missing,T2}
    current_valley::Union{Missing,T2}
    peak_bar_index::Union{Missing,Int}
    valley_bar_index::Union{Missing,Int}
    
    # Previous state for change detection
    prev_peak::Union{Missing,T2}
    prev_valley::Union{Missing,T2}
    
    input_modifier::Function
    input_filter::Function
    input_values::CircBuff

    function PeakValleyDetector{Tval}(;
        lookback = PEAK_VALLEY_LOOKBACK,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tval,
    ) where {Tval}
        T2 = input_modifier_return_type
        S = fieldtype(T2, :close)
        buffer_size = lookback * 2 + 3  # Need enough data for lookback analysis
        input_values = CircBuff(T2, buffer_size, rev = false)
        
        new{Tval,false,S}(
            initialize_indicator_common_fields()...,
            lookback,
            missing,     # current_peak
            missing,     # current_valley
            missing,     # peak_bar_index
            missing,     # valley_bar_index
            missing,     # prev_peak
            missing,     # prev_valley
            input_modifier,
            input_filter,
            input_values,
        )
    end
end

function _calculate_new_value(ind::PeakValleyDetector)
    if length(ind.input_values) < ind.lookback * 2 + 1
        return missing
    end
    
    bars = value(ind.input_values)
    center_idx = ind.lookback + 1  # Index of the bar we're analyzing for peak/valley
    
    # Don't analyze the most recent bars (need lookback confirmation)
    if length(bars) < center_idx + ind.lookback
        # Extract price type from the OHLCV input
        PriceType = typeof(bars[1].high)
        return PeakValleyVal{PriceType}(
            ind.current_peak,
            ind.current_valley,
            ind.peak_bar_index,
            ind.valley_bar_index,
            false,
            false
        )
    end
    
    center_bar = bars[center_idx]
    is_new_peak = false
    is_new_valley = false
    
    # Store previous values for change detection
    ind.prev_peak = ind.current_peak
    ind.prev_valley = ind.current_valley
    
    # Check for peak: center bar high is higher than all surrounding bars
    is_peak = true
    for i in (center_idx - ind.lookback):(center_idx + ind.lookback)
        if i != center_idx && bars[i].high >= center_bar.high
            is_peak = false
            break
        end
    end
    
    if is_peak && (ismissing(ind.current_peak) || center_bar.high != ind.current_peak)
        ind.current_peak = center_bar.high
        ind.peak_bar_index = center_idx
        is_new_peak = true
    end
    
    # Check for valley: center bar low is lower than all surrounding bars  
    is_valley = true
    for i in (center_idx - ind.lookback):(center_idx + ind.lookback)
        if i != center_idx && bars[i].low <= center_bar.low
            is_valley = false
            break
        end
    end
    
    if is_valley && (ismissing(ind.current_valley) || center_bar.low != ind.current_valley)
        ind.current_valley = center_bar.low
        ind.valley_bar_index = center_idx
        is_new_valley = true
    end
    
    # Extract price type from the OHLCV input
    PriceType = typeof(bars[1].high)
    return PeakValleyVal{PriceType}(
        ind.current_peak,
        ind.current_valley,
        ind.peak_bar_index,
        ind.valley_bar_index,
        is_new_peak,
        is_new_valley
    )
end

# Constructor for vector input
function PeakValleyDetector(data::Vector{T}; lookback = PEAK_VALLEY_LOOKBACK) where {T}
    ind = PeakValleyDetector{T}(lookback = lookback)
    for val in data
        fit!(ind, val)
    end
    return ind
end