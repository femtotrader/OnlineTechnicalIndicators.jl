"""
    OHLCV{Ttime,Tprice,Tvol}

Represents OHLCV (Open, High, Low, Close, Volume) candlestick data with optional timestamp.

# Fields
- `open::Tprice`: Opening price of the period
- `high::Tprice`: Highest price during the period
- `low::Tprice`: Lowest price during the period
- `close::Tprice`: Closing price of the period
- `volume::Tvol`: Trading volume during the period (optional, defaults to `missing`)
- `time::Ttime`: Timestamp of the candlestick (optional, defaults to `missing`)
"""
struct OHLCV{Ttime,Tprice,Tvol}
    open::Tprice
    high::Tprice
    low::Tprice
    close::Tprice
    volume::Tvol
    time::Ttime

    function OHLCV(
        open::Tprice,
        high::Tprice,
        low::Tprice,
        close::Tprice;
        volume::Tvol = missing,
        time::Ttime = missing,
    ) where {Ttime,Tprice,Tvol}
        new{Ttime,Tprice,Tvol}(open, high, low, close, volume, time)
    end

end

"""
    OHLCVFactory{Ttime,Tprice,Tvol}

Factory for creating multiple OHLCV candlesticks from vectors of price data.

# Fields
- `open::Vector{Tprice}`: Vector of opening prices
- `high::Vector{Tprice}`: Vector of high prices
- `low::Vector{Tprice}`: Vector of low prices
- `close::Vector{Tprice}`: Vector of closing prices
- `volume::Vector{Tvol}`: Vector of volumes (optional)
- `time::Vector{Ttime}`: Vector of timestamps (optional)

Use `Base.collect(factory)` to generate a vector of `OHLCV` instances.
"""
struct OHLCVFactory{Ttime,Tprice,Tvol}
    open::Vector{Tprice}
    high::Vector{Tprice}
    low::Vector{Tprice}
    close::Vector{Tprice}
    volume::Vector{Tvol}
    time::Vector{Ttime}

    function OHLCVFactory(
        open::Vector{Tprice},
        high::Vector{Tprice},
        low::Vector{Tprice},
        close::Vector{Tprice};
        volume::Vector{Tvol} = Missing[],
        time::Vector{Ttime} = Missing[],
    ) where {Ttime,Tprice,Tvol}
        n = length(close)
        @assert length(open) == n
        @assert length(high) == n
        @assert length(low) == n
        new{Ttime,Tprice,Tvol}(open, high, low, close, volume, time)
    end
end

function Base.collect(factory::OHLCVFactory{Ttime,Tprice,Tvol}) where {Ttime,Tprice,Tvol}
    v_ohlcv = OHLCV{Ttime,Tprice,Tvol}[]
    for i in eachindex(factory.close)
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
        ohlcv = OHLCV(
            factory.open[i],
            factory.high[i],
            factory.low[i],
            factory.close[i],
            volume = volume,
            time = time,
        )
        push!(v_ohlcv, ohlcv)
    end
    return v_ohlcv
end


module ValueExtractor
extract_open = candle -> candle.open
extract_high = candle -> candle.high
extract_low = candle -> candle.low
extract_close = candle -> candle.close
extract_volume = candle -> candle.volume
end
