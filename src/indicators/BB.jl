const BB_PERIOD = 5
const BB_STD_DEV_MULTIPLIER = 2.0

struct BBVal{Tval}
    lower::Tval
    central::Tval
    upper::Tval
end

"""
    BB{T}(; period=BB_PERIOD, std_dev_multiplier=BB_STD_DEV_MULTIPLIER)

The BB type implements Bollinger Bands indicator.
"""
mutable struct BB{Tval} <: AbstractIncTAIndicator
    period::Integer
    std_dev_multiplier::Tval

    central_band::SMA{Tval}
    std_dev::StdDev{Tval}

    output::CircularBuffer{Union{Missing,BBVal{Tval}}}

    function BB{Tval}(;
        period = BB_PERIOD,
        std_dev_multiplier = BB_STD_DEV_MULTIPLIER,
    ) where {Tval}
        central_band = SMA{Tval}(period = period)
        std_dev = StdDev{Tval}(period = period)

        output = CircularBuffer{Union{Missing,BBVal{Tval}}}(period)
        new{Tval}(period, std_dev_multiplier, central_band, std_dev, output)
    end
end

function Base.push!(ind::BB{Tval}, val::Tval) where {Tval}
    push!(ind.central_band, val)
    push!(ind.std_dev, val)
    if !has_output_value(ind.central_band)
        out_val = missing
    else
        lower =
            ind.central_band.output[end] - ind.std_dev_multiplier * ind.std_dev.output[end]
        central = ind.central_band.output[end]
        upper =
            ind.central_band.output[end] + ind.std_dev_multiplier * ind.std_dev.output[end]
        out_val = BBVal{Tval}(lower, central, upper)
    end
    push!(ind.output, out_val)
    return out_val
end
