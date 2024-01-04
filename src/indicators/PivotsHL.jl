const PivotsHL_HIGH_PERIOD = 7
const PivotsHL_LOW_PERIOD = 7
const PivotsHL_MEMORY = 3

module HLType
export HLTypeEnum
@enum HLTypeEnum LOW HIGH
end # module

struct PivotsHLVal{Tohlcv}
    ohlcv::Tohlcv
    type::HLType.HLTypeEnum
    isnew::Bool
end

# isnew(val::PivotsHLVal) = val.isnew

"""
    PivotsHL{Tohlcv,S}(; high_period = PivotsHL_HIGH_PERIOD, low_period = PivotsHL_LOW_PERIOD, input_filter = always_true, input_modifier = identity, input_modifier_return_type = Tohlcv)

The `PivotsHL` type implements a High/Low Pivots Indicator.
"""
mutable struct PivotsHL{Tohlcv,S} <: TechnicalIndicator{Tohlcv}
    value::Missing
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    output_values::CircBuff

    high_period::Integer
    low_period::Integer

    high_input_values::CircBuff
    low_input_values::CircBuff

    input_modifier::Function
    input_filter::Function
    input_values::CircBuff

    function PivotsHL{Tohlcv,S}(;
        high_period = PivotsHL_HIGH_PERIOD,
        low_period = PivotsHL_LOW_PERIOD,
        memory = PivotsHL_MEMORY,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv,S}
        T2 = input_modifier_return_type
        output_values =  CircBuff(PivotsHLVal, memory, rev = false)
        high_input_values = CircBuff(S, high_period, rev = false)
        low_input_values = CircBuff(S, low_period, rev = false)
        input_values = CircBuff(T2, 2, rev = false)  # could also be of size max(high_period, low_period) and avoid creation of 2 other CircBuff (high_input_values, low_input_values)
        new{Tohlcv,S}(
            initialize_indicator_common_fields()...,
            output_values,
            high_period,
            low_period,
            high_input_values,
            low_input_values,
            input_modifier,
            input_filter,
            input_values,
        )
    end
end

has_output_value(ind::PivotsHL) = length(ind.output_values) > 0

function _calculate_new_value(ind::PivotsHL)
    candle = ind.input_values[end]
    fit!(ind.high_input_values, candle.high)
    fit!(ind.low_input_values, candle.low)

    if ind.n > 1

        high = ind.input_values[end-1].high
        low = ind.input_values[end-1].low

        max_high = max((p for p in ind.high_input_values.value)...)
        min_low = min((p for p in ind.low_input_values.value)...)

        if high >= max_high
            if !has_output_value(ind) || ind.output_values[end].type == HLType.LOW
                fit!(ind.output_values, PivotsHLVal(ind.input_values[end-1], HLType.HIGH, false))
            else
                ind.output_values[end] = PivotsHLVal(ind.input_values[end-1], HLType.HIGH, true)
            end
        elseif low <= min_low
            if !has_output_value(ind) || ind.output_values[end].type == HLType.HIGH
                fit!(ind.output_values, PivotsHLVal(ind.input_values[end-1], HLType.LOW, false))
            else
                ind.output_values[end] = PivotsHLVal(ind.input_values[end-1], HLType.LOW, true)
            end
        end
        return missing
    else
        return missing
    end
end
