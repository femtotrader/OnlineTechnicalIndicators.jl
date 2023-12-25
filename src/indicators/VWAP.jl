const VWAP_MEMORY = 3

"""
    VWAP{Tprice, Tvol}(; memory = VWAP_MEMORY)

The VWAP type implements a Volume Weighted Moving Average indicator.
"""
mutable struct VWAP{Tprice,Tvol} <: OnlineStat{Tval}
    value::CircularBuffer{Union{Tprice,Missing}}
    n::Int

    memory::Integer

    sum_price_vol::Tprice
    sum_vol::Tvol

    function VWAP{Tprice,Tvol}(; memory = VWAP_MEMORY) where {Tprice,Tvol}
        sum_price_vol = zero(Tprice)
        sum_vol = zero(Tvol)
        value = CircularBuffer{Union{Tprice,Missing}}(memory)
        new{Tprice,Tvol}(value, 0, memory, sum_price_vol, sum_vol)
    end
end

function Base.push!(
    ind::VWAP{Tprice},
    ohlcv::OHLCV{Ttime,Tprice,Tvol},
) where {Ttime,Tprice,Tvol}
    typical_price = (ohlcv.high + ohlcv.low + ohlcv.close) / 3.0

    ind.sum_price_vol = ind.sum_price_vol + ohlcv.volume * typical_price
    ind.sum_vol = ind.sum_vol + ohlcv.volume

    if ind.sum_vol != 0
        out_val = ind.sum_price_vol / ind.sum_vol
    else
        out_val = missing
    end

    push!(ind.value, out_val)
    return out_val
end
