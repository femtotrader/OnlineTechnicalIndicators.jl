const VWMA_PERIOD = 3

"""
    VWMA{Ttime, Tprice, Tvol}(; period = VWMA_PERIOD)

The VWMA type implements a Volume Weighted Moving Average indicator.
"""
mutable struct VWMA{Ttime,Tprice,Tvol} <: OnlineStat{Tprice}
    value::CircularBuffer{Union{Tprice,Missing}}

    period::Integer

    input::CircularBuffer{OHLCV{Ttime,Tprice,Tvol}}

    function VWMA{Ttime,Tprice,Tvol}(; period = VWMA_PERIOD) where {Ttime,Tprice,Tvol}
        input = CircularBuffer{OHLCV{Ttime,Tprice,Tvol}}(period)
        value = CircularBuffer{Union{Tprice,Missing}}(period)
        new{Ttime,Tprice,Tvol}(value, 0, period, input)
    end
end

function Base.push!(
    ind::VWMA{Ttime,Tprice,Tvol},
    ohlcv::OHLCV{Ttime,Tprice,Tvol},
) where {Ttime,Tprice,Tvol}
    push!(ind.input, ohlcv)
    if length(ind.input) < ind.period
        out_val = missing
    else
        s = zero(Tprice)
        v = zero(Tvol)
        for candle in ind.input
            s += candle.close * candle.volume
            v += candle.volume
        end
        out_val = s / v
    end
    push!(ind.value, out_val)
    return out_val
end
