"""
    BOP{Tohlcv,S}()

The `BOP` type implements a Balance Of Power indicator.
"""
mutable struct BOP{Tohlcv,S} <: TechnicalIndicator{Tohlcv}
    value::Union{Missing,S}
    n::Int

    function BOP{Tohlcv,S}() where {Tohlcv,S}
        new{Tohlcv,S}(missing, 0)
    end
end

function _calculate_new_value_only_from_incoming_data(ind::BOP, candle)
    return candle.high != candle.low ? (candle.close - candle.open) / (candle.high - candle.low) : value(ind)
end
