const STOCH_PERIOD = 14
const STOCH_SMOOTHING_PERIOD = 3

struct StochVal{Tprice}
    k::Tprice
    d::Tprice
end

"""
    Stoch{Ttime,Tprice,Tvol}(; period = STOCH_PERIOD, smoothing_period = STOCH_SMOOTHING_PERIOD)

The Stoch type implements the Stochastic indicator.
"""
mutable struct Stoch{Ttime,Tprice,Tvol} <: AbstractIncTAIndicator
    period::Integer
    smoothing_period::Integer

    values_d::SMA{Tprice}
    input::CircularBuffer{OHLCV{Ttime,Tprice,Tvol}}
    output::CircularBuffer{Union{Missing,StochVal{Tprice}}}

    function Stoch{Ttime,Tprice,Tvol}(;
        period=STOCH_PERIOD,
        smoothing_period=STOCH_SMOOTHING_PERIOD
    ) where {Ttime,Tprice,Tvol}
        values_d = SMA{Tprice}(; period=smoothing_period)
        input = CircularBuffer{OHLCV{Ttime,Tprice,Tvol}}(period)
        output = CircularBuffer{Union{Missing,StochVal{Tprice}}}(period)
        new{Ttime,Tprice,Tvol}(period, smoothing_period, values_d, input, output)
    end
end

function Base.push!(ind::Stoch, ohlcv::OHLCV)
    # load candles until i have enough data
    push!(ind.input, ohlcv)
    # get max high
    # get min low
    max_high = max([cdl.high for cdl in ind.input]...)
    min_low = min([cdl.low for cdl in ind.input]...)
    # calculate k
    if max_high == min_low
        k = 100.0
    else
        k = 100.0 * (ind.input[end].close - min_low) / (max_high - min_low)
    end
    # calculate d
    push!(ind.values_d, k)
    if length(ind.values_d.output) > 0
        d = ind.values_d.output[end]
    else
        d = missing
    end

    kd = StochVal(k, d)
    push!(ind.output, kd)
    return kd
end

# I was surprised to see how much variety there was when it came to calculating the Stochastic indicator.
# TradingView, talipp, and talib all have their own take on it.
