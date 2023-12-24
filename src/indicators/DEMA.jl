const DEMA_PERIOD = 20

"""
    DEMA{T}(; period = DEMA_PERIOD)

The DEMA type implements a Double Exponential Moving Average indicator.
"""
mutable struct DEMA{Tval} <: AbstractIncTAIndicator
    value::CircularBuffer{Union{Missing,Tval}}

    period::Integer

    ema::EMA{Tval}
    ema_ema::EMA{Tval}

    function DEMA{Tval}(; period = DEMA_PERIOD) where {Tval}
        @warn "WIP - buggy"
        ema = EMA{Tval}(period = period)
        ema_ema = EMA{Tval}(period = period)

        value = CircularBuffer{Union{Missing,Tval}}(period)
        new{Tval}(value, period, ema, ema_ema)
    end
end


function Base.push!(ind::DEMA{Tval}, val::Tval) where {Tval}
    push!(ind.ema, val)

    if !has_output_value(ind.ema)
        out_val = missing
    else
        push!(ind.ema_ema, ind.ema.value[end])

        if !has_output_value(ind.ema_ema)
            out_val = missing
        else
            out_val = 2.0 * ind.ema.value[end] - ind.ema_ema.value[end]
        end
    end

    push!(ind.value, out_val)
    return out_val
end
