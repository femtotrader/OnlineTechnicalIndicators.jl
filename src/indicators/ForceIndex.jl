const ForceIndex_PERIOD = 3

"""
    ForceIndex{Tohlcv}(; period = ForceIndex_PERIOD)

The ForceIndex type implements a Force Index indicator.
"""
mutable struct ForceIndex{Tohlcv} <: OnlineStat{Tohlcv}
    value::Union{Missing,Float64}  # Tprice
    n::Int

    period::Integer

    ema::EMA{Float64}  # Tprice

    input::Tuple{
        Union{Missing,Tohlcv},
        Union{Missing,Tohlcv},
    }

    function ForceIndex{Tohlcv}(;
        period = ForceIndex_PERIOD,
    ) where {Tohlcv}
        Tprice = Float64
        ema = EMA{Tprice}(period = period)
        input = (missing, missing)
        new{Tohlcv}(missing, 0, period, ema, input)
    end
end

function OnlineStatsBase._fit!(ind::ForceIndex, candle::OHLCV)
    ind.input = (ind.input[end], candle)  # Keep a small window of input values
    ind.n += 1
    if ind.n >= 2
        fit!(ind.ema, (ind.input[end].close - ind.input[end-1].close) * ind.input[end].volume)
        if has_output_value(ind.ema)
            ind.value = value(ind.ema)
        else
            ind.value = missing
        end    
    else
        ind.value = missing
    end
end
