"""
    OBV{Tohlcv,S}()

The `OBV` type implements On Balance Volume indicator.
"""
mutable struct OBV{Tohlcv,S} <: TechnicalIndicator{Tohlcv}
    value::Union{Missing,S}
    n::Int

    input_values::Tuple{Union{Missing,Tohlcv},Union{Missing,Tohlcv}}

    function OBV{Tohlcv,S}() where {Tohlcv,S}
        input = (missing, missing)
        new{Tohlcv,S}(missing, 0, input)
    end
end

function OnlineStatsBase._fit!(ind::OBV, candle)
    ind.input_values = (ind.input_values[end], candle)  # Keep a small window of input values
    ind.n += 1
    if ind.n != 1
        candle = ind.input_values[end]
        candle_prev = ind.input_values[end-1]
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
