const AO_FAST_PERIOD = 3
const AO_SLOW_PERIOD = 21

"""
    AO{Tprice}(; fast_period=AO_FAST_PERIOD, slow_period=AO_SLOW_PERIOD)

The AO type implements an Awesome Oscillator indicator.
"""
mutable struct AO{Tprice} <: AbstractIncTAIndicator
    sma_fast::SMA{Tprice}
    sma_slow::SMA{Tprice}

    output::CircularBuffer{Union{Tprice, Missing}}

    function AO{Tprice}(; fast_period=AO_FAST_PERIOD, slow_period=AO_SLOW_PERIOD) where {Tprice}
        @assert fast_period < slow_period "slow_period must be greater than fast_period"
        sma_fast = SMA{Tprice}(period=fast_period)
        sma_slow = SMA{Tprice}(period=slow_period)
        output = CircularBuffer{Union{Tprice, Missing}}(slow_period)
        new{Tprice}(sma_fast, sma_slow, output)
    end
end

function Base.push!(ind::AO, ohlcv::OHLCV)
    median = (ohlcv.high + ohlcv.low) / 2.0
    push!(ind.sma_fast, median)
    push!(ind.sma_slow, median)
    if ismissing(ind.sma_fast.output[end]) || ismissing(ind.sma_slow.output[end])
        out_val = missing
    else
        out_val = ind.sma_fast.output[end] - ind.sma_slow.output[end]
    end
    push!(ind.output, out_val)
    return out_val
end
