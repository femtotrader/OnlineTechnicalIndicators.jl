const AO_FAST_PERIOD = 3
const AO_SLOW_PERIOD = 21

"""
    AO{Tohlcv}(; fast_period = AO_FAST_PERIOD, slow_period = AO_SLOW_PERIOD)

The AO type implements an Awesome Oscillator indicator.
"""
mutable struct AO{Tohlcv} <: OnlineStat{Tohlcv}
    value::Union{Missing,Float64}
    n::Int

    sma_fast::SMA{Float64}
    sma_slow::SMA{Float64}

    function AO{Tohlcv}(;
        fast_period = AO_FAST_PERIOD,
        slow_period = AO_SLOW_PERIOD,
    ) where {Tohlcv}
        @assert fast_period < slow_period "slow_period must be greater than fast_period"
        Tprice = Float64
        sma_fast = SMA{Tprice}(period = fast_period)
        sma_slow = SMA{Tprice}(period = slow_period)
        new{Tohlcv}(missing, 0, sma_fast, sma_slow)
    end
end

function OnlineStatsBase._fit!(ind::AO, candle::OHLCV)
    ind.n += 1
    median = (candle.high + candle.low) / 2.0
    fit!(ind.sma_fast, median)
    fit!(ind.sma_slow, median)
    if has_output_value(ind.sma_fast) && has_output_value(ind.sma_slow)
        ind.value = value(ind.sma_fast) - value(ind.sma_slow)
    else
        ind.value = missing
    end
end
#=
function Base.push!(ind::AO, ohlcv::OHLCV)
    median = (ohlcv.high + ohlcv.low) / 2.0
    push!(ind.sma_fast, median)
    push!(ind.sma_slow, median)
    if ismissing(ind.sma_fast.value[end]) || ismissing(ind.sma_slow.value[end])
        out_val = missing
    else
        out_val = ind.sma_fast.value[end] - ind.sma_slow.value[end]
    end
    push!(ind.value, out_val)
    return out_val
end
=#
