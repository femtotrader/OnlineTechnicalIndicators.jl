const RSI_PERIOD = 3

"""
    RSI{T}(; period = SMA_PERIOD, input_filter = always_true, input_modifier = identity, input_modifier_return_type = T)

The `RSI` type implements a Relative Strength Index indicator.
"""
mutable struct RSI{Tval,IN,T2} <: TechnicalIndicatorSingleOutput{Tval}
    value::Union{Missing,T2}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    period::Integer

    gains::SMMA
    losses::SMMA

    input_modifier::Function
    input_filter::Function
    input_values::CircBuff

    function RSI{Tval}(;
        period = RSI_PERIOD,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tval,
    ) where {Tval}
        T2 = input_modifier_return_type
        input_values = CircBuff(T2, 2, rev = false)
        value = missing
        gains = SMMA{T2}(period = period)
        losses = SMMA{T2}(period = period)
        new{Tval,false,T2}(
            initialize_indicator_common_fields()...,
            period,
            gains,
            losses,
            input_modifier,
            input_filter,
            input_values,
        )
    end
end

function RSI(;
    period = RSI_PERIOD,
    input_filter = always_true,
    input_modifier = identity,
    input_modifier_return_type = Float64,
)
    RSI{input_modifier_return_type}(;
        period=period,
        input_filter=input_filter,
        input_modifier=input_modifier,
        input_modifier_return_type=input_modifier_return_type)
end

function _calculate_new_value(ind::RSI{T,IN,S}) where {T,IN,S}
    if ind.n > 1
        change = ind.input_values[end] - ind.input_values[end-1]

        gain = change > 0 ? change : zero(S)
        loss = change < 0 ? -change : zero(S)

        fit!(ind.gains, gain)
        fit!(ind.losses, loss)

        _losses = value(ind.losses)
        if ismissing(_losses)
            return missing
        end

        if _losses == 0
            rsi = 100 * one(S)
        else
            rs = value(ind.gains) / _losses
            rsi = 100 * one(S) - 100 * one(S) / (one(S) + rs)
        end
        return rsi
    else
        return missing
    end
end
