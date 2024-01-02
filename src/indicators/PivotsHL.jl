const PivotsHL_HIGH_PERIOD = 7
const PivotsHL_LOW_PERIOD = 7

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
    value::Union{Missing,PivotsHLVal}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    output_latest::Union{Missing,PivotsHLVal}

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
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv,S}
        T2 = input_modifier_return_type
        @warn "WIP - buggy"
        output_latest = missing
        high_input_values = CircBuff(S, high_period, rev = false)
        low_input_values = CircBuff(S, low_period, rev = false)
        input_values = CircBuff(T2, 2, rev = false)  # could also be of size max(high_period, low_period) and avoid creation of 2 other CircBuff (high_input_values, low_input_values)
        new{Tohlcv,S}(
            initialize_indicator_common_fields()...,
            output_latest,
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

function _calculate_new_value(ind::PivotsHL)
    candle = ind.input_values[end]
    fit!(ind.high_input_values, candle.high)
    fit!(ind.low_input_values, candle.low)

    if ind.n > 1

        high = ind.input_values[end-1].high
        low = ind.input_values[end-1].low

        max_high = max([p for p in ind.high_input_values.value]...)
        min_low = min([p for p in ind.low_input_values.value]...)

        if high >= max_high
            if !has_output_value(ind) || value(ind).type == HLType.LOW
                println("1")
                return PivotsHLVal(ind.input_values[end-1], HLType.HIGH, false)
            else
                println("2")
                return PivotsHLVal(ind.input_values[end-1], HLType.HIGH, true)
            end
        elseif low <= min_low
            if !has_output_value(ind) || value(ind).type == HLType.HIGH
                println("3")
                return PivotsHLVal(ind.input_values[end-1], HLType.LOW, false)
            else
                println("4")
                return PivotsHLVal(ind.input_values[end-1], HLType.LOW, true)
            end
        end
        println("5")
        return missing
        # return ind.output_latest
    else
        return missing
    end
end
