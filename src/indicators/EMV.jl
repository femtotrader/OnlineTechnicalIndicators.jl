const EMV_PERIOD = 20
const EMV_VOLUME_DIV = 10000

"""
    EMV{Ttime, Tprice, Tvol}(; period = EMV_PERIOD, volume_div = EMV_VOLUME_DIV)

The EMV type implements a Ease of Movement indicator.
"""
mutable struct EMV{Ttime,Tprice,Tvol} <: AbstractIncTAIndicator
    period::Integer
    volume_div::Integer

    emv_sma::SMA{Tprice}

    input::CircularBuffer{OHLCV{Ttime,Tprice,Tvol}}
    value::CircularBuffer{Union{Tprice,Missing}}

    function EMV{Ttime,Tprice,Tvol}(;
        period = EMV_PERIOD,
        volume_div = EMV_VOLUME_DIV,
    ) where {Ttime,Tprice,Tvol}
        emv_sma = SMA{Tprice}(period = period)

        input = CircularBuffer{OHLCV{Ttime,Tprice,Tvol}}(period)
        value = CircularBuffer{Union{Tprice,Missing}}(period)
        new{Ttime,Tprice,Tvol}(period, volume_div, emv_sma, input, value)
    end
end

function Base.push!(ind::EMV, candle::OHLCV)
    push!(ind.input, candle)

    if length(ind.input) < 2
        out_val = missing
        push!(ind.value, out_val)
        return out_val
    end

    value = ind.input[end]
    value2 = ind.input[end-1]

    if value.high ≠ value.low
        distance = ((value.high + value.low) / 2) - ((value2.high + value2.low) / 2)
        box_ratio = (value.volume / ind.volume_div / (value.high - value.low))
        emv = distance / box_ratio
    else
        emv = 0.0
    end

    push!(ind.emv_sma, emv)

    if length(ind.emv_sma.value) < 1
        out_val = missing
    else
        out_val = ind.emv_sma.value[end]
    end

    push!(ind.value, out_val)
    return out_val
end
