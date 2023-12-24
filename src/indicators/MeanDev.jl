const MeanDev_PERIOD = 3

"""
    MeanDev{T}(; period = MeanDev_PERIOD)

The MeanDev type implements a Mean Deviation indicator.
"""
mutable struct MeanDev{Tval} <: AbstractIncTAIndicator
    period::Integer

    sma::SMA{Tval}

    input::CircularBuffer{Tval}
    value::CircularBuffer{Union{Tval,Missing}}

    function MeanDev{Tval}(; period = MeanDev_PERIOD) where {Tval}
        input = CircularBuffer{Tval}(period)
        value = CircularBuffer{Union{Tval,Missing}}(period)
        sma = SMA{Tval}(period = period)
        new{Tval}(period, sma, input, value)
    end
end

function Base.push!(ind::MeanDev{Tval}, data::Tval) where {Tval}
    push!(ind.input, data)
    push!(ind.sma, data)
    _sma = output(ind.sma)
    out_val = sum(abs.(ind.input .- _sma)) / ind.period
    push!(ind.value, out_val)
    return out_val
end

function output(ind::MeanDev)
    return ind.value[end]
end
