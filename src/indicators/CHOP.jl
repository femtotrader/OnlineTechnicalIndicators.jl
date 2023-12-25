const CHOP_PERIOD = 14


"""
    CHOP{Ttime, Tprice, Tvol}(; period = CHOP_PERIOD)

The CHOP type implements a Choppiness Index indicator.
"""
mutable struct CHOP{Ttime,Tprice,Tvol} <: OnlineStat{Tval}
    value::CircularBuffer{Union{Tprice,Missing}}
    n::Int

    period::Integer

    atr::ATR{Ttime,Tprice,Tvol}

    input::CircularBuffer{OHLCV{Ttime,Tprice,Tvol}}

    function CHOP{Ttime,Tprice,Tvol}(; period = CHOP_PERIOD) where {Ttime,Tprice,Tvol}
        @warn "WIP - buggy"
        atr = ATR{Ttime,Tprice,Tvol}(period = 1)
        input = CircularBuffer{OHLCV{Ttime,Tprice,Tvol}}(period)
        value = CircularBuffer{Union{Tprice,Missing}}(period)
        new{Ttime,Tprice,Tvol}(value, 0, period, atr, input)
    end
end

function Base.push!(ind::CHOP, candle::OHLCV)
    push!(ind.input, candle)
    push!(ind.atr, candle)

    if (!has_output_value(ind.atr)) || (!isfull(ind.input))
        out_val = missing
        push!(ind.value, out_val)
        println(out_val)
        return out_val
    end

    max_high = max([cdl.high for cdl in ind.input]...)
    min_low = min([cdl.low for cdl in ind.input]...)

    if max_high != min_low
        out_val =
            100.0 * log10(sum(ind.atr.value) / (max_high - min_low)) / log10(ind.period)
    else
        if length(ind.value) > 0
            out_val = ind.value[end]
        else
            out_val = missing
        end
    end

    push!(ind.value, out_val)
    println(out_val)
    return out_val
end
