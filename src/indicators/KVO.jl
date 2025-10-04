const KVO_FAST_PERIOD = 5
const KVO_SLOW_PERIOD = 10

"""
    KVO{Tohlcv}(; fast_period = KVO_FAST_PERIOD, slow_period = KVO_SLOW_PERIOD, ma = EMA, input_modifier_return_type = Tohlcv)

The `KVO` type implements a Klinger Volume Oscillator.
"""
mutable struct KVO{Tohlcv,IN,S} <: TechnicalIndicatorSingleOutput{Tohlcv}
    value::Union{Missing,S}
    n::Int

    fast_ma::MovingAverageIndicator  # EMA by default
    slow_ma::MovingAverageIndicator  # EMA by default

    trend::CircBuff
    cumulative_measurement::CircBuff
    input_values::CircBuff

    function KVO{Tohlcv}(;
        fast_period = KVO_FAST_PERIOD,
        slow_period = KVO_SLOW_PERIOD,
        ma = EMA,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        S = fieldtype(T2, :close)
        _fast_ma = MAFactory(S)(ma, period = fast_period)
        _slow_ma = MAFactory(S)(ma, period = slow_period)
        trend = CircBuff(S, 2, rev = false)
        cumulative_measurement = CircBuff(S, 2, rev = false)
        input_values = CircBuff(T2, 2, rev = false)
        new{Tohlcv,true,S}(
            missing,
            0,
            _fast_ma,
            _slow_ma,
            trend,
            cumulative_measurement,
            input_values,
        )
    end
end

function KVO(;
    fast_period = KVO_FAST_PERIOD,
    slow_period = KVO_SLOW_PERIOD,
    ma = EMA,
    input_modifier_return_type = OHLCV{Missing,Float64,Float64},
)
    KVO{input_modifier_return_type}(;
        fast_period = fast_period,
        slow_period = slow_period,
        ma = ma,
        input_modifier_return_type = input_modifier_return_type,
    )
end

function _calculate_new_value(ind::KVO{T,IN,S}) where {T,IN,S}
    if length(ind.input_values) < 2
        return missing
    end

    value1 = ind.input_values[end]
    value2 = ind.input_values[end-1]

    if length(ind.trend) < 1
        fit!(ind.trend, zero(S))
    else
        if (value1.high + value1.low + value1.close) >
           (value2.high + value2.low + value2.close)
            fit!(ind.trend, one(S))
        else
            fit!(ind.trend, -one(S))
        end
    end

    if length(ind.trend) < 2
        return missing
    end

    dm1 = value1.high - value1.low
    dm2 = value2.high - value2.low

    if length(ind.cumulative_measurement) < 1
        prev_cm = dm1
    else
        prev_cm = ind.cumulative_measurement[end]
    end

    if ind.trend[end] == ind.trend[end-1]
        fit!(ind.cumulative_measurement, prev_cm + dm1)
    else
        fit!(ind.cumulative_measurement, dm2 + dm1)
    end

    if ind.cumulative_measurement[end] == 0
        volume_force = zero(S)
    else
        volume_force =
            value1.volume *
            abs(2 * (dm1 / ind.cumulative_measurement[end] - 1)) *
            ind.trend[end] *
            100
    end

    fit!(ind.fast_ma, volume_force)
    fit!(ind.slow_ma, volume_force)

    if has_output_value(ind.fast_ma) && has_output_value(ind.slow_ma)
        return value(ind.fast_ma) - value(ind.slow_ma)
    else
        return missing
    end
end

