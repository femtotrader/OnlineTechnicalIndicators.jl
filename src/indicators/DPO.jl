const DPO_PERIOD = 20

"""
    DPO{T}(; period = DPO_PERIOD)

The DPO type implements a Detrended Price Oscillator indicator.
"""
mutable struct DPO{Tval} <: AbstractIncTAIndicator
    period::Integer

    sma::SMA{Tval}

    input::CircularBuffer{Tval}
    value::CircularBuffer{Union{Missing,Tval}}

    function DPO{Tval}(; period = DPO_PERIOD) where {Tval}
        input = CircularBuffer{Tval}(period)
        value = CircularBuffer{Union{Missing,Tval}}(period)

        sma = SMA{Tval}(period = period)

        new{Tval}(period, sma, input, value)
    end
end


function Base.push!(ind::DPO{Tval}, val::Tval) where {Tval}
    push!(ind.input, val)
    push!(ind.sma, val)

    semi_period = floor(Int, ind.period / 2)
    if length(ind.input) < semi_period + 2 || length(ind.sma.value) < 1
        out_val = missing
    else
        out_val = ind.input[end-semi_period-1] - ind.sma.value[end]
    end

    push!(ind.value, out_val)
    return out_val
end
