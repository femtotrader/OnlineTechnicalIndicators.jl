const MeanDev_PERIOD = 3

"""
    MeanDev{T}(; period = MeanDev_PERIOD)

The MeanDev type implements a Mean Deviation indicator.
"""
mutable struct MeanDev{Tval} <: AbstractIncTAIndicator
    period::Integer

    input::CircularBuffer{Tval}
    output::CircularBuffer{Union{Tval,Missing}}

    sma::SMA{Tval}

    function MeanDev{Tval}(; period = MeanDev_PERIOD) where {Tval}
        input = CircularBuffer{Tval}(period)
        output = CircularBuffer{Union{Tval,Missing}}(period)
        sma = SMA{Tval}(period = period)
        new{Tval}(period, input, output, sma)
    end
end

function Base.push!(ind::MeanDev{Tval}, data::Tval) where {Tval}
    push!(ind.input, data)
    push!(ind.sma, data)
    _sma = output(ind.sma)
    out_val = sum(abs.(ind.input .- _sma)) / ind.period
    push!(ind.output, out_val)
    return out_val
end

function output(ind::MeanDev)
    return ind.output[end]
end
