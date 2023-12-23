const SOBV_PERIOD = 20

"""
    SOBV{Ttime, Tprice, Tvol}(; period = SOBV_PERIOD)

The SOBV type implements a Smoothed On Balance Volume indicator.
"""
mutable struct SOBV{Ttime,Tprice,Tvol} <: AbstractIncTAIndicator
    period::Integer

    obv::OBV{Ttime,Tprice,Tvol}

    output::CircularBuffer{Union{Tprice,Missing}}

    function SOBV{Ttime,Tprice,Tvol}(; period = SOBV_PERIOD) where {Ttime,Tprice,Tvol}
        obv = OBV{Ttime,Tprice,Tvol}(memory = period)
        output = CircularBuffer{Union{Tprice,Missing}}(period)
        new{Ttime,Tprice,Tvol}(period, obv, output)
    end
end

function Base.push!(ind::SOBV, candle::OHLCV)
    push!(ind.obv, candle)

    if !has_output_value(ind.obv)
        out_val = missing
    else
        out_val = sum(ind.obv.output) / ind.period
    end

    push!(ind.output, out_val)
    return out_val
end
