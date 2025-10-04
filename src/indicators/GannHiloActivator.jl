const GANN_HILO_PERIOD = 14

"""
    GannHiloActivatorVal{T}

A struct representing the result of the Gann HiLo Activator calculation.
 - `high`: The calculated high value or `missing` if not enough data.
 - `low`: The calculated low value or `missing` if not enough data.
"""
struct GannHiloActivatorVal{T}
    high::T
    low::T
end

"""
    GannHiloActivator{T}(; period=GANN_HILO_PERIOD, input_modifier_return_type = T)

The `GannHiloActivator` type implements a Gann HiLo Activator indicator.
"""
mutable struct GannHiloActivator{Tval,IN,T2} <: TechnicalIndicatorMultiOutput{Tval}
    value::Union{Missing,GannHiloActivatorVal}
    n::Int

    period::Int
    sma_high::SMA
    sma_low::SMA
    input_values::CircBuff

    function GannHiloActivator{Tval}(;
        period = GANN_HILO_PERIOD,
        input_modifier_return_type = Tval) where {Tval}
        T2 = input_modifier_return_type
        S = fieldtype(T2, :close)
        input_values = CircBuff(T2, period, rev = false)
        sma_high = SMA{S}(period = period)
        sma_low = SMA{S}(period = period)

        new{Tval,false,S}(
            missing,
            0,
            period,
            sma_high,
            sma_low,
            input_values)
    end
end

function _calculate_new_value(ind::GannHiloActivator)
    if length(ind.input_values) >= ind.period
        high = maximum(cdl.high for cdl in value(ind.input_values))
        low = minimum(cdl.low for cdl in value(ind.input_values))
        fit!(ind.sma_high, high)
        fit!(ind.sma_low, low)
        return GannHiloActivatorVal(value(ind.sma_high), value(ind.sma_low))
    else
        return missing
    end
end
