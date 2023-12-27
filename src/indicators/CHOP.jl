const CHOP_PERIOD = 14


"""
    CHOP{Tohlcv,S}(; period = CHOP_PERIOD)

The CHOP type implements a Choppiness Index indicator.
"""
mutable struct CHOP{Tohlcv,S} <: OnlineStat{Tohlcv}
    value::Union{Missing,S}
    n::Int

    period::Integer

    atr::ATR

    input::CircBuff

    function CHOP{Tohlcv,S}(; period = CHOP_PERIOD) where {Tohlcv,S}
        @warn "WIP - buggy"
        atr = ATR{Tohlcv,S}(period = 1)
        input = CircBuff(Tohlcv, period, rev = false)
        new{Tohlcv,S}(missing, 0, period, atr, input)
    end
end

function OnlineStatsBase._fit!(ind::CHOP, candle)
    fit!(ind.input, candle)
    fit!(ind.atr, candle)

    if (!has_output_value(ind.atr)) || (!isfull(ind.input))
        ind.value = missing
        return
    end

    max_high = max([cdl.high for cdl in value(ind.input)]...)
    min_low = min([cdl.low for cdl in value(ind.input)]...)

    if max_high != min_low
        out_val =
            100.0 * log10(sum(ind.atr.value) / (max_high - min_low)) / log10(ind.period)
    else
        if length(ind.value) > 0
            ind.value = value(ind)
        else
            ind.value = missing
        end
    end

    ind.value = out_val
end
