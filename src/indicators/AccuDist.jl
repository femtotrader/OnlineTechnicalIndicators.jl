"""
    AccuDist{Tohlcv}(; input_modifier_return_type = Tohlcv)

The `AccuDist` type implements an Accumulation/Distribution Line (ADL) indicator.

The Accumulation/Distribution Line measures the cumulative flow of money into and out of
a security. It uses the relationship between the close price and the trading range,
weighted by volume. Rising ADL suggests accumulation (buying), falling ADL suggests
distribution (selling).

# Parameters
- `input_modifier_return_type::Type = Tohlcv`: Input OHLCV type

# Formula
```
MFI = ((close - low) - (high - close)) / (high - low)  # Money Flow Multiplier
MFV = MFI × volume                                      # Money Flow Volume
ADL = ADL_prev + MFV                                    # Cumulative sum
```
Returns previous value if high equals low (avoids division by zero).

# Input
Requires OHLCV data with `high`, `low`, `close`, and `volume` fields.

# Returns
`Union{Missing,T}` - The cumulative accumulation/distribution value. Available from
the first observation.

See also: [`ChaikinOsc`](@ref), [`OBV`](@ref), [`ForceIndex`](@ref), [`MFI`](@ref)
"""
mutable struct AccuDist{Tohlcv,IN,S} <: TechnicalIndicatorSingleOutput{Tohlcv}
    value::Union{Missing,S}
    n::Int

    function AccuDist{Tohlcv}(; input_modifier_return_type = Tohlcv) where {Tohlcv}
        T2 = input_modifier_return_type
        S = fieldtype(T2, :close)
        new{Tohlcv,true,S}(missing, 0)
    end
end

function AccuDist(; input_modifier_return_type = OHLCV{Missing,Float64})
    AccuDist{input_modifier_return_type}(;
        input_modifier_return_type = input_modifier_return_type,
    )
end

function _calculate_new_value_only_from_incoming_data(ind::AccuDist, candle)
    if candle.high != candle.low
        # Calculate MFI and MFV
        mfi =
            ((candle.close - candle.low) - (candle.high - candle.close)) /
            (candle.high - candle.low)
        mfv = mfi * candle.volume
    else
        # In case high and low are equal (division by zero), return previous value if exists, otherwise return missing
        return value(ind)
    end
    return has_output_value(ind) ? value(ind) + mfv : mfv
end
