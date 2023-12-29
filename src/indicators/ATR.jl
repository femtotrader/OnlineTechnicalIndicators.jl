const ATR_PERIOD = 3

"""
    ATR{Tohlcv,S}(; period = ATR_PERIOD)

The `ATR` type implements an Average True Range indicator.
"""
mutable struct ATR{Tohlcv,S} <: TechnicalIndicator{Tohlcv}
    value::Union{Missing,S}
    n::Int

    period::Number

    tr::CircBuff{S}
    rolling::Bool

    input_values::CircBuff{Tohlcv}  # seems a bit overkilled just to get ind.input_values[end - 1].close (maybe use simply a Tuple with current and previous value - see ForceIndex)

    function ATR{Tohlcv,S}(; period = ATR_PERIOD) where {Tohlcv,S}
        tr = CircBuff(S, period, rev = false)
        input = CircBuff(Tohlcv, period, rev = false)
        new{Tohlcv,S}(missing, 0, period, tr, false, input)
    end
end

function OnlineStatsBase._fit!(ind::ATR, candle)
    fit!(ind.input_values, candle)
    ind.n += 1
    true_range = candle.high - candle.low
    if ind.n != 1
        close2 = ind.input_values[end-1].close
        fit!(ind.tr, max(true_range, abs(candle.high - close2), abs(candle.low - close2)))
        if ind.n < ind.period
            ind.value = missing
            # elseif isfull(ind.input_values)  # length(ind.input_values) == ind.period
        else
            if !ind.rolling
                ind.rolling = true
                ind.value = sum(value(ind.tr)) / ind.period
            else
                ind.value = (value(ind) * (ind.period - 1) + ind.tr[end]) / ind.period
            end
        end
    else
        fit!(ind.tr, true_range)
    end
end
