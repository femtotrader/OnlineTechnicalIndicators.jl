const HMA_PERIOD = 20

"""
    HMA{T}(; period = HMA_PERIOD)

The HMA type implements a Hull Moving Average indicator.
"""
mutable struct HMA{Tval} <: AbstractIncTAIndicator
    period::Integer

    wma::WMA{Tval}
    wma2::WMA{Tval}
    hma::WMA{Tval}

    output::CircularBuffer{Union{Missing,Tval}}

    function HMA{Tval}(; period = HMA_PERIOD) where {Tval}

        output = CircularBuffer{Union{Missing,Tval}}(period)

        wma = WMA{Tval}(period = period)
        wma2 = WMA{Tval}(period = floor(Int, period / 2))
        hma = WMA{Tval}(period = floor(Int, sqrt(period)))

        new{Tval}(period, wma, wma2, hma, output)
    end
end


function Base.push!(ind::HMA{Tval}, val::Tval) where {Tval}
    push!(ind.wma, val)
    push!(ind.wma2, val)

    if !has_output_value(ind.wma)
        out_val = missing
    else
        push!(ind.hma, 2.0 * ind.wma2.output[end] - ind.wma.output[end])

        if !has_output_value(ind.hma)
            out_val = missing
        else
            out_val = ind.hma.output[end]
        end
    end

    push!(ind.output, out_val)
    return out_val
end
