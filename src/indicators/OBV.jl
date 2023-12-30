"""
    OBV{Tohlcv,S}()

The `OBV` type implements On Balance Volume indicator.
"""
mutable struct OBV{Tohlcv,S} <: TechnicalIndicator{Tohlcv}
    value::Union{Missing,S}
    n::Int

    input_values::CircBuff

    function OBV{Tohlcv,S}() where {Tohlcv,S}
        input_values = CircBuff(Tohlcv, 2, rev = false)
        new{Tohlcv,S}(missing, 0, input_values)
    end
end

function _calculate_new_value(ind::OBV)
    candle = ind.input_values[end]
    if ind.n != 1
        candle_prev = ind.input_values[end-1]
        if candle.close == candle_prev.close
            return value(ind)
        elseif candle.close > candle_prev.close
            return value(ind) + candle.volume
        else
            return value(ind) - candle.volume
        end
    else
        return candle.volume
    end
end
