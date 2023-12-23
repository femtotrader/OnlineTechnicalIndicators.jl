const ATR_PERIOD = 3

"""
    ATR{Ttime, Tprice, Tvol}(; period = ATR_PERIOD)

The ATR type implements an Average True Range indicator.
"""
mutable struct ATR{Ttime,Tprice,Tvol} <: AbstractIncTAIndicator
    period::Number

    tr::CircularBuffer{Tprice}
    rolling::Bool

    input::CircularBuffer{OHLCV{Ttime,Tprice,Tvol}}  # seems a bit overkilled just to get ind.input[end - 1].close (maybe use simply a Tuple with current and previous value - see ForceIndex)
    output::CircularBuffer{Union{Tprice,Missing}}

    function ATR{Ttime,Tprice,Tvol}(; period = ATR_PERIOD) where {Ttime,Tprice,Tvol}
        tr = CircularBuffer{Tprice}(period)
        input = CircularBuffer{OHLCV{Ttime,Tprice,Tvol}}(period)
        output = CircularBuffer{Union{Tprice,Missing}}(period)
        new{Ttime,Tprice,Tvol}(period, tr, false, input, output)
    end
end

function Base.push!(ind::ATR, ohlcv::OHLCV)
    push!(ind.input, ohlcv)
    true_range = ohlcv.high - ohlcv.low
    if length(ind.input) == 1
        push!(ind.tr, true_range)
    else
        close2 = ind.input[end-1].close
        push!(ind.tr, max(true_range, abs(ohlcv.high - close2), abs(ohlcv.low - close2)))
    end
    if length(ind.input) < ind.period
        out_val = missing
        # elseif isfull(ind.input)  # length(ind.input) == ind.period
    else
        if !ind.rolling
            out_val = sum(ind.tr) / ind.period
            ind.rolling = true
        else
            out_val = (ind.output[end] * (ind.period - 1) + ind.tr[end]) / ind.period
        end
    end
    push!(ind.output, out_val)
    return out_val
end
