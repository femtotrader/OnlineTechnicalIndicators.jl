"""
    OBV{Tohlcv,S}()

The OBV type implements On Balance Volume indicator.
"""
mutable struct OBV{Tohlcv,S} <: OnlineStat{Tohlcv}
    value::Union{Missing,S}
    n::Int

    input::Tuple{Union{Missing,Tohlcv},Union{Missing,Tohlcv}}

    function OBV{Tohlcv,S}() where {Tohlcv,S}
        input = (missing, missing)
        new{Tohlcv,S}(missing, 0, input)
    end
end

function OnlineStatsBase._fit!(ind::OBV, candle)
    ind.input = (ind.input[end], candle)  # Keep a small window of input values
    ind.n += 1
    if ind.n != 1
        candle = ind.input[end]
        candle_prev = ind.input[end-1]
        if candle.close == candle_prev.close
            ind.value = value(ind)
        elseif candle.close > candle_prev.close
            ind.value = value(ind) + candle.volume
        else
            ind.value = value(ind) - candle.volume
        end
    else
        ind.value = candle.volume
    end
end
