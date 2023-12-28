const CHOP_PERIOD = 14


"""
    CHOP{Tohlcv,S}(; period = CHOP_PERIOD)

The `CHOP` type implements a Choppiness Index indicator.
"""
mutable struct CHOP{Tohlcv,S} <: TechnicalIndicator{Tohlcv}
    value::Union{Missing,S}
    n::Int

    period::Integer

    sub_indicators::Series
    # atr::ATR
    atr_values::CircBuff

    input::CircBuff

    function CHOP{Tohlcv,S}(; period = CHOP_PERIOD) where {Tohlcv,S}
        @warn "WIP - buggy"
        atr = ATR{Tohlcv,S}(period = 1)
        sub_indicators = Series(atr)
        atr_values = CircBuff(Union{Missing,S}, period, rev = false)
        input = CircBuff(Tohlcv, period, rev = false)
        new{Tohlcv,S}(missing, 0, period, sub_indicators, atr_values, input)
    end
end

function OnlineStatsBase._fit!(ind::CHOP, candle)
    fit!(ind.input, candle)
    fit!(ind.sub_indicators, candle)
    ind.n += 1
    atr, = ind.sub_indicators.stats
    fit!(ind.atr_values, value(atr))

    if (!has_output_value(atr)) || (length(ind.input) != ind.period)
        ind.value = missing
        return
    end


    max_high = max([cdl.high for cdl in value(ind.input)]...)
    min_low = min([cdl.low for cdl in value(ind.input)]...)

    if max_high != min_low
        ind.value =
            100.0 * log10(sum(ind.atr_values.value) / (max_high - min_low)) /
            log10(ind.period)
    else
        if length(ind.value) > 0
            ind.value = value(ind)
        else
            ind.value = missing
        end
    end
end
