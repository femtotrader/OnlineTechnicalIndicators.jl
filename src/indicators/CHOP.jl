const CHOP_PERIOD = 14


"""
    CHOP{Ttime, Tprice, Tvol}(; period=CHOP_PERIOD)

The CHOP type implements a Choppiness Index indicator.
"""
mutable struct CHOP{Ttime, Tprice, Tvol} <: AbstractIncTAIndicator
    period::Integer

    atr::ATR{Ttime, Tprice, Tvol}
    
    input::CircularBuffer{OHLCV{Ttime, Tprice, Tvol}}
    output::CircularBuffer{Union{Tprice, Missing}}

    function CHOP{Ttime, Tprice, Tvol}(; period=CHOP_PERIOD) where {Ttime, Tprice, Tvol}
        atr = ATR{Ttime, Tprice, Tvol}(period=1)
        input = CircularBuffer{OHLCV{Ttime, Tprice, Tvol}}(period)
        output = CircularBuffer{Union{Tprice, Missing}}(period)
        new{Ttime, Tprice, Tvol}(period, atr, input, output)
    end
end

function Base.push!(ind::CHOP, candle::OHLCV)
    push!(ind.input, candle)
    push!(ind.atr, candle)

    if ( !has_output_value(ind.atr) ) || ( !isfull(ind.input) )
        out_val = missing
        push!(ind.output, out_val)
        println(out_val)
        return out_val
    end

    max_high = max([cdl.high for cdl in ind.input]...)
    min_low = min([cdl.low for cdl in ind.input]...)

    if max_high != min_low
        out_val = 100.0 * log10(sum(ind.atr.output) / (max_high - min_low) ) / log10(ind.period)
    else
        if length(ind.output) > 0
            out_val = ind.output[end]
        else
            out_val = missing
        end
    end

    push!(ind.output, out_val)
    println(out_val)
    return out_val
end
