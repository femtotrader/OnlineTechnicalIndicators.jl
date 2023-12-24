const SOBV_PERIOD = 20

"""
    SOBV{Ttime, Tprice, Tvol}(; period = SOBV_PERIOD)

The SOBV type implements a Smoothed On Balance Volume indicator.
"""
mutable struct SOBV{Ttime,Tprice,Tvol} <: AbstractIncTAIndicator
    value::CircularBuffer{Union{Tprice,Missing}}

    period::Integer

    obv::OBV{Ttime,Tprice,Tvol}

    function SOBV{Ttime,Tprice,Tvol}(; period = SOBV_PERIOD) where {Ttime,Tprice,Tvol}
        obv = OBV{Ttime,Tprice,Tvol}(memory = period)
        value = CircularBuffer{Union{Tprice,Missing}}(period)
        new{Ttime,Tprice,Tvol}(value, period, obv)
    end
end

function Base.push!(ind::SOBV, candle::OHLCV)
    push!(ind.obv, candle)

    if !has_output_value(ind.obv)
        out_val = missing
    else
        out_val = sum(ind.obv.value) / ind.period
    end

    push!(ind.value, out_val)
    return out_val
end
