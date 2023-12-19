struct OHLCV{Ttime, Tprice, Tvol}
    open::Tprice
    high::Tprice
    low::Tprice
    close::Tprice
    volume::Tvol
    time::Ttime

    function OHLCV(open::Tprice, high::Tprice, low::Tprice, close::Tprice; volume::Tvol = missing, time::Ttime = missing) where {Ttime, Tprice, Tvol}
        new{Ttime, Tprice, Tvol}(open, high, low, close, volume, time)
    end

end

struct OHLCVFactory{Ttime, Tprice, Tvol}
    open::Vector{Tprice}
    high::Vector{Tprice}
    low::Vector{Tprice}
    close::Vector{Tprice}
    volume::Vector{Tvol}
    time::Vector{Ttime}

    function OHLCVFactory(open::Vector{Tprice}, high::Vector{Tprice}, low::Vector{Tprice}, close::Vector{Tprice}; volume::Vector{Tvol} = Missing[], time::Vector{Ttime} = Missing[]) where {Ttime, Tprice, Tvol}
        n = length(close)
        @assert length(open) == n
        @assert length(high) == n
        @assert length(low) == n
        new{Ttime, Tprice, Tvol}(open, high, low, close, volume, time)
    end
end

function Base.collect(factory::OHLCVFactory{Ttime, Tprice, Tvol}) where {Ttime, Tprice, Tvol}
    v_ohlcv = OHLCV{Ttime, Tprice, Tvol}[]
    for i in 1:length(factory.close)
        if i <= length(factory.volume)
            volume = factory.volume[i]
        else
            volume = missing
        end
        if i <= length(factory.time)
            time = factory.time[i]
        else
            time = missing
        end
        ohlcv = OHLCV(factory.open[i], factory.high[i], factory.low[i], factory.close[i], volume=volume, time=time)
        push!(v_ohlcv, ohlcv)
    end
    return v_ohlcv
end