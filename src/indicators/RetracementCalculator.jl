const RETRACEMENT_PCT = 0.38

"""
    RetracementVal{T}

A struct representing retracement calculation results.
- `retracement_38_long`: 38% retracement level for long positions (B - (B-A) × 0.38)
- `retracement_38_short`: 38% retracement level for short positions (B + (A-B) × 0.38)  
- `swing_start`: Point A of the swing
- `swing_end`: Point B of the swing
- `current_retracement_pct`: Current retracement percentage from swing_end
- `is_38_retracement_hit`: Boolean indicating if 38% retracement was hit
"""
struct RetracementVal{T}
    retracement_38_long::Union{Missing,T}
    retracement_38_short::Union{Missing,T}
    swing_start::Union{Missing,T}
    swing_end::Union{Missing,T}
    current_retracement_pct::Union{Missing,T}
    is_38_retracement_hit::Bool
    
    # Inner constructor that allows specifying type explicitly
    function RetracementVal{T}(retracement_38_long::Union{Missing,T}, retracement_38_short::Union{Missing,T},
                              swing_start::Union{Missing,T}, swing_end::Union{Missing,T},
                              current_retracement_pct::Union{Missing,T}, is_38_retracement_hit::Bool) where T
        new{T}(retracement_38_long, retracement_38_short, swing_start, swing_end, current_retracement_pct, is_38_retracement_hit)
    end
end

"""
    RetracementCalculator{T}(; retracement_pct=0.38, input_modifier_return_type = T)

The `RetracementCalculator` type calculates retracement levels for swing trading.

This indicator calculates:
- 38% retracement levels for both long and short positions
- Current retracement percentage from swing peaks/valleys
- Signals when specific retracement levels are hit

# Parameters
- `retracement_pct`: Retracement percentage to calculate (default: 0.38 for 38%)

# Output
- [`RetracementVal`](@ref): Contains retracement levels and hit signals

Implements REQ-310 to REQ-313: Calculate and monitor 38% retracement levels
"""
mutable struct RetracementCalculator{Tval,IN,T2} <: TechnicalIndicatorMultiOutput{Tval}
    value::Union{Missing,RetracementVal}
    n::Int

    retracement_pct::Float64
    
    # Current swing tracking
    swing_start_price::Union{Missing,T2}    # Point A
    swing_end_price::Union{Missing,T2}      # Point B
    swing_direction::Symbol                 # :up or :down
    
    # Retracement tracking
    max_retracement::Union{Missing,T2}
    retracement_38_hit::Bool
    input_values::CircBuff

    function RetracementCalculator{Tval}(;
        retracement_pct = 0.38,
        input_modifier_return_type = Tval) where {Tval}
        T2 = input_modifier_return_type
        S = fieldtype(T2, :close)
        input_values = CircBuff(T2, 3, rev = false)  # Need minimal data for swing detection
        
        new{Tval,false,S}(
            missing,
            0,
            retracement_pct,
            missing,     # swing_start_price
            missing,     # swing_end_price  
            :up,         # swing_direction
            missing,     # max_retracement
            false,       # retracement_38_hit
            input_values)
    end
end

function _calculate_new_value(ind::RetracementCalculator)
    if length(ind.input_values) < 2
        return missing
    end
    
    bars = value(ind.input_values)
    current_bar = bars[end]
    
    # Initialize swing tracking if needed
    if ismissing(ind.swing_start_price) || ismissing(ind.swing_end_price)
        if length(bars) >= 2
            prev_bar = bars[end-1]
            # Detect initial swing direction
            if current_bar.high > prev_bar.high
                ind.swing_direction = :up
                ind.swing_start_price = prev_bar.low
                ind.swing_end_price = current_bar.high
            elseif current_bar.low < prev_bar.low
                ind.swing_direction = :down
                ind.swing_start_price = prev_bar.high
                ind.swing_end_price = current_bar.low
            end
        end
    else
        # Update swing tracking
        if ind.swing_direction == :up
            # In upswing, update swing_end if new high
            if current_bar.high > ind.swing_end_price
                ind.swing_end_price = current_bar.high
                ind.retracement_38_hit = false  # Reset retracement tracking
            end
        else  # :down
            # In downswing, update swing_end if new low
            if current_bar.low < ind.swing_end_price
                ind.swing_end_price = current_bar.low
                ind.retracement_38_hit = false  # Reset retracement tracking
            end
        end
    end
    
    # Calculate retracement levels if we have a valid swing
    retracement_38_long = missing
    retracement_38_short = missing
    current_retracement_pct = missing
    is_38_hit = false
    
    if !ismissing(ind.swing_start_price) && !ismissing(ind.swing_end_price)
        swing_size = abs(ind.swing_end_price - ind.swing_start_price)
        
        if swing_size > 0
            # REQ-312: Calculate 38% retracement levels
            if ind.swing_direction == :up
                # Long position: Point_Sortie = B - (B - A) × 0.38
                retracement_38_long = ind.swing_end_price - (ind.swing_end_price - ind.swing_start_price) * ind.retracement_pct
                
                # Calculate current retracement from swing high
                current_retracement = (ind.swing_end_price - current_bar.close) / (ind.swing_end_price - ind.swing_start_price)
                current_retracement_pct = current_retracement
                
                # Check if 38% retracement hit
                if current_bar.close <= retracement_38_long && !ind.retracement_38_hit
                    is_38_hit = true
                    ind.retracement_38_hit = true
                end
                
            else  # :down
                # Short position: Point_Sortie = B + (A - B) × 0.38
                retracement_38_short = ind.swing_end_price + (ind.swing_start_price - ind.swing_end_price) * ind.retracement_pct
                
                # Calculate current retracement from swing low
                current_retracement = (current_bar.close - ind.swing_end_price) / (ind.swing_start_price - ind.swing_end_price)
                current_retracement_pct = current_retracement
                
                # Check if 38% retracement hit
                if current_bar.close >= retracement_38_short && !ind.retracement_38_hit
                    is_38_hit = true
                    ind.retracement_38_hit = true
                end
            end
        end
    end
    
    # Extract price type from the OHLCV input
    PriceType = typeof(current_bar.high)
    return RetracementVal{PriceType}(
        retracement_38_long,
        retracement_38_short,
        ind.swing_start_price,
        ind.swing_end_price,
        current_retracement_pct,
        is_38_hit
    )
end

# Constructor for vector input
function RetracementCalculator(data::Vector{T}; retracement_pct = RETRACEMENT_PCT) where {T}
    ind = RetracementCalculator{T}(retracement_pct = retracement_pct)
    for val in data
        fit!(ind, val)
    end
    return ind
end