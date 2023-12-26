const ForceIndex_PERIOD = 3

"""
    ForceIndex{Tohlcv,S}(; period = ForceIndex_PERIOD)

The ForceIndex type implements a Force Index indicator.
"""
mutable struct ForceIndex{Tohlcv,S} <: OnlineStat{Tohlcv}
    value::Union{Missing,S}
    n::Int

    period::Integer

    ema::EMA{S}

    input::Tuple{Union{Missing,Tohlcv},Union{Missing,Tohlcv}}

    function ForceIndex{Tohlcv,S}(; period = ForceIndex_PERIOD) where {Tohlcv,S}
        ema = EMA{S}(period = period)
        input = (missing, missing)
        new{Tohlcv,S}(missing, 0, period, ema, input)
    end
end

function OnlineStatsBase._fit!(ind::ForceIndex, candle::OHLCV)
    ind.input = (ind.input[end], candle)  # Keep a small window of input values
    ind.n += 1
    if ind.n >= 2
        fit!(
            ind.ema,
            (ind.input[end].close - ind.input[end-1].close) * ind.input[end].volume,
        )
        if has_output_value(ind.ema)
            ind.value = value(ind.ema)
        else
            ind.value = missing
        end
    else
        ind.value = missing
    end
end
