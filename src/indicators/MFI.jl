const MFI_PERIOD = 14

"""
    MFI{Tohlcv}(; period = MFI_PERIOD, input_modifier_return_type = Tohlcv)

The `MFI` type implements a Money Flow Index indicator.

The Money Flow Index (MFI) is a momentum oscillator that measures the flow of money into and
out of a security over a specified period of time. It is related to the Relative Strength
Index (RSI) but incorporates volume, making it a volume-weighted RSI. Values above 80
indicate overbought conditions, below 20 indicate oversold.

# Parameters
- `period::Integer = $MFI_PERIOD`: The lookback period for calculating money flow sums
- `input_modifier_return_type::Type = Tohlcv`: Input OHLCV type (must have `high`, `low`, `close`, `volume` fields)

# Formula
```
Typical Price (TP) = (High + Low + Close) / 3
Raw Money Flow = TP × Volume
If TP > TP_prev: Positive Money Flow = Raw Money Flow
If TP < TP_prev: Negative Money Flow = Raw Money Flow
If TP = TP_prev: No contribution (neutral)
Money Flow Ratio = Sum(Positive MF, period) / Sum(Negative MF, period)
MFI = 100 - (100 / (1 + Money Flow Ratio))
```

# Input
Requires OHLCV data with `high`, `low`, `close`, and `volume` fields.

# Returns
`Union{Missing,T}` - The MFI value (0-100), or `missing` during warm-up
(first `period` observations).

See also: [`RSI`](@ref), [`OBV`](@ref), [`AccuDist`](@ref), [`ChaikinOsc`](@ref)
"""
mutable struct MFI{Tohlcv,IN,S} <: TechnicalIndicatorSingleOutput{Tohlcv}
    value::Union{Missing,S}
    n::Int

    period::Integer

    pos_money_flow::CircBuff
    neg_money_flow::CircBuff

    input_values::CircBuff

    function MFI{Tohlcv}(;
        period = MFI_PERIOD,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        S = fieldtype(T2, :close)
        input_values = CircBuff(T2, 2, rev = false)
        pos_money_flow = CircBuff(S, period, rev = false)
        neg_money_flow = CircBuff(S, period, rev = false)
        new{Tohlcv,true,S}(
            missing,
            0,
            period,
            pos_money_flow,
            neg_money_flow,
            input_values,
        )
    end
end

function MFI(;
    period = MFI_PERIOD,
    input_modifier_return_type = OHLCV{Missing,Float64,Float64},
)
    MFI{input_modifier_return_type}(;
        period = period,
        input_modifier_return_type = input_modifier_return_type,
    )
end

function _calculate_new_value(ind::MFI{T,IN,S}) where {T,IN,S}
    if ind.n < 2
        # Need at least 2 observations to compare typical prices
        return missing
    end

    candle = ind.input_values[end]
    candle_prev = ind.input_values[end-1]

    # Calculate typical prices
    tp = (candle.high + candle.low + candle.close) / 3
    tp_prev = (candle_prev.high + candle_prev.low + candle_prev.close) / 3

    # Calculate raw money flow
    raw_money_flow = tp * candle.volume

    # Classify money flow as positive or negative based on typical price direction
    if tp > tp_prev
        fit!(ind.pos_money_flow, raw_money_flow)
        fit!(ind.neg_money_flow, zero(S))
    elseif tp < tp_prev
        fit!(ind.pos_money_flow, zero(S))
        fit!(ind.neg_money_flow, raw_money_flow)
    else
        # Equal typical prices - no contribution (neutral)
        fit!(ind.pos_money_flow, zero(S))
        fit!(ind.neg_money_flow, zero(S))
    end

    # Need period observations to calculate MFI
    if ind.n <= ind.period
        return missing
    end

    # Sum positive and negative money flows over the period
    sum_pos = sum(value(ind.pos_money_flow)[end-ind.period+1:end])
    sum_neg = sum(value(ind.neg_money_flow)[end-ind.period+1:end])

    # Handle edge cases
    if sum_neg == 0 && sum_pos == 0
        # No money flow in either direction - return neutral (50)
        return 50 * one(S)
    elseif sum_neg == 0
        # All positive flow - MFI = 100
        return 100 * one(S)
    elseif sum_pos == 0
        # All negative flow - MFI = 0
        return zero(S)
    end

    # Calculate Money Flow Ratio and MFI
    money_flow_ratio = sum_pos / sum_neg
    mfi = 100 * one(S) - 100 * one(S) / (one(S) + money_flow_ratio)

    return mfi
end
