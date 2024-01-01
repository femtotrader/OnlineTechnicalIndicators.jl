const UO_FAST_PERIOD = 3
const UI_MID_PERIOD = 5
const UO_SLOW_PERIOD = 7

"""
    UO{Tohlcv,S}(; fast_period = UO_FAST_PERIOD, mid_period = UO_MID_PERIOD, slow_period = UO_SLOW_PERIOD, input_filter = always_true, input_modifier = identity, input_modifier_return_type = Tohlcv)

The `UO` type implements an Ultimate Oscillator.
"""
mutable struct UO{Tohlcv,S} <: TechnicalIndicator{Tohlcv}
    value::Union{Missing,S}
    n::Int

    output_listeners::Series

    fast_period::Integer
    mid_period::Integer
    slow_period::Integer

    buy_press::CircBuff
    true_range::CircBuff

    input_modifier::Function
    input_filter::Function
    input_indicator::Union{Missing,TechnicalIndicator}
    input_values::CircBuff

    function UO{Tohlcv,S}(;
        fast_period = UO_FAST_PERIOD,
        mid_period = UO_MID_PERIOD,
        slow_period = UO_SLOW_PERIOD,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv,S}
        @assert fast_period < mid_period < slow_period "fast_period < mid_period < slow_period is not respected"
        input_values = CircBuff(Tohlcv, 2, rev = false)
        buy_press = CircBuff(S, slow_period, rev = false)
        true_range = CircBuff(S, slow_period, rev = false)
        output_listeners = Series()
        input_indicator = missing
        new{Tohlcv,S}(
            missing,
            0,
            output_listeners,
            fast_period,
            mid_period,
            slow_period,
            buy_press,
            true_range,
            input_modifier,
            input_filter,
            input_indicator,
            input_values,
        )
    end
end

function _calculate_new_value(ind::UO)
    if ind.n < 2
        return missing
    end

    candle = ind.input_values[end]
    candle_prev = ind.input_values[end-1]

    fit!(ind.buy_press, candle.close - min(candle.low, candle_prev.close))
    fit!(
        ind.true_range,
        max(candle.high, candle_prev.close) - min(candle.low, candle_prev.close),
    )

    # if length(ind.buy_press.value) < ind.slow_period
    if ind.n <= ind.slow_period
        return missing
    end

    avg_fast =
        sum(value(ind.buy_press)[end-ind.fast_period+1:end]) /
        sum(value(ind.true_range)[end-ind.fast_period+1:end])
    avg_mid =
        sum(value(ind.buy_press)[end-ind.mid_period+1:end]) /
        sum(value(ind.true_range)[end-ind.mid_period+1:end])
    avg_slow =
        sum(value(ind.buy_press)[end-ind.slow_period+1:end]) /
        sum(value(ind.true_range)[end-ind.slow_period+1:end])

    return 100.0 * (4.0 * avg_fast + 2.0 * avg_mid + avg_slow) / 7.0
end
