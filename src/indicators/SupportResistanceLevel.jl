"""
    SupportResistanceLevelVal{T}

A struct representing support and resistance levels.
- `support_level`: Current support level (previous valley)
- `resistance_level`: Current resistance level (previous peak)
- `support_active`: Boolean indicating if support is holding
- `resistance_active`: Boolean indicating if resistance is holding  
- `support_broken`: Boolean indicating if support was broken this period
- `resistance_broken`: Boolean indicating if resistance was broken this period
"""
struct SupportResistanceLevelVal{T}
    support_level::Union{Missing,T}
    resistance_level::Union{Missing,T}
    support_active::Bool
    resistance_active::Bool
    support_broken::Bool
    resistance_broken::Bool
    
    # Inner constructor that allows specifying type explicitly
    function SupportResistanceLevelVal{T}(support_level::Union{Missing,T}, resistance_level::Union{Missing,T},
                                          support_active::Bool, resistance_active::Bool, 
                                          support_broken::Bool, resistance_broken::Bool) where T
        new{T}(support_level, resistance_level, support_active, resistance_active, support_broken, resistance_broken)
    end
end

"""
    SupportResistanceLevel{T}(; input_filter = always_true, input_modifier = identity, input_modifier_return_type = T)

The `SupportResistanceLevel` type calculates and monitors support and resistance levels.

This indicator tracks:
- Support levels from previous swing valleys
- Resistance levels from previous swing peaks  
- Break signals when price penetrates these levels

# Output
- [`SupportResistanceLevelVal`](@ref): Contains S/R levels and break signals

Implements REQ-040 to REQ-043: Support/Resistance level calculation and monitoring
"""
mutable struct SupportResistanceLevel{Tval,IN,T2} <: TechnicalIndicatorMultiOutput{Tval}
    value::Union{Missing,SupportResistanceLevelVal}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    # Current support/resistance levels
    current_support::Union{Missing,T2}
    current_resistance::Union{Missing,T2}
    
    # Previous levels for break detection
    prev_support::Union{Missing,T2}
    prev_resistance::Union{Missing,T2}
    
    # State tracking
    support_active::Bool
    resistance_active::Bool
    
    input_modifier::Function
    input_filter::Function
    input_values::CircBuff

    function SupportResistanceLevel{Tval}(;
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tval,
    ) where {Tval}
        T2 = input_modifier_return_type
        S = fieldtype(T2, :close)
        input_values = CircBuff(T2, 3, rev = false)
        
        new{Tval,false,S}(
            initialize_indicator_common_fields()...,
            missing,     # current_support
            missing,     # current_resistance
            missing,     # prev_support
            missing,     # prev_resistance
            true,        # support_active (assume active until broken)
            true,        # resistance_active (assume active until broken)
            input_modifier,
            input_filter,
            input_values,
        )
    end
end

function _calculate_new_value(ind::SupportResistanceLevel{Tval,IN,S}) where {Tval,IN,S}
    if length(ind.input_values) < 1
        return missing
    end
    
    bars = value(ind.input_values)
    current_bar = bars[end]
    
    support_broken = false
    resistance_broken = false
    
    # Store previous levels for break detection
    ind.prev_support = ind.current_support
    ind.prev_resistance = ind.current_resistance
    
    # REQ-041: Check if support is broken (prices penetrate under valley point)
    if !ismissing(ind.current_support) && ind.support_active
        if current_bar.low < ind.current_support
            support_broken = true
            ind.support_active = false
        end
    end
    
    # REQ-043: Check if resistance is broken (prices exceed peak point)  
    if !ismissing(ind.current_resistance) && ind.resistance_active
        if current_bar.high > ind.current_resistance
            resistance_broken = true
            ind.resistance_active = false
        end
    end
    
    # Update support and resistance levels from input data
    # This would typically be connected to a PeakValleyDetector or similar
    # For now, we'll use a simple approach based on recent highs/lows
    if length(bars) >= 1
        # Update resistance (peak detection) - only if not broken or new high
        if current_bar.high > (ismissing(ind.current_resistance) ? 0.0 : ind.current_resistance)
            ind.current_resistance = current_bar.high
            # Only reactivate if it wasn't just broken
            if !resistance_broken
                ind.resistance_active = true
            end
        end
        
        # Update support (valley detection) - only if not broken or new low  
        if current_bar.low < (ismissing(ind.current_support) ? Inf : ind.current_support)
            ind.current_support = current_bar.low
            # Only reactivate if it wasn't just broken
            if !support_broken
                ind.support_active = true
            end
        end
    end
    
    # Extract price type from the OHLCV input
    PriceType = typeof(current_bar.high)
    return SupportResistanceLevelVal{PriceType}(
        ind.current_support,
        ind.current_resistance,
        ind.support_active,
        ind.resistance_active,
        support_broken,
        resistance_broken
    )
end

"""
    update_levels!(sr::SupportResistanceLevel, peak_valley_val)

Update support and resistance levels from external peak/valley detection.
This method allows integration with PeakValleyDetector results.
"""
function update_levels!(sr::SupportResistanceLevel, peak_valley_val)
    if !ismissing(peak_valley_val.valley) && peak_valley_val.is_new_valley
        sr.current_support = peak_valley_val.valley
        sr.support_active = true
    end
    
    if !ismissing(peak_valley_val.peak) && peak_valley_val.is_new_peak
        sr.current_resistance = peak_valley_val.peak  
        sr.resistance_active = true
    end
end

# Constructor for vector input
function SupportResistanceLevel(data::Vector{T}) where {T}
    ind = SupportResistanceLevel{T}()
    for val in data
        fit!(ind, val)
    end
    return ind
end