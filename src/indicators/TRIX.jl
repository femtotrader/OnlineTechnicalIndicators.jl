const TRIX_PERIOD = 10


"""
    TRIX{T}(; period = TRIX_PERIOD, input_filter = always_true, input_modifier = identity, input_modifier_return_type = T)

The `TRIX` type implements a TRIX Moving Average indicator.
"""
mutable struct TRIX{Tval,IN,T2} <: MovingAverageIndicator{Tval}
    value::Union{Missing,T2}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    output_history::CircBuff

    period::Int

    sub_indicators::Series
    ema1::EMA

    ema2::EMA
    ema3::EMA

    input_modifier::Function
    input_filter::Function
    input_values::CircBuff

    function TRIX{Tval}(;
        period = TRIX_PERIOD,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tval,
    ) where {Tval}
        T2 = input_modifier_return_type
        input_values = CircBuff(T2, 2, rev = false)
        ema1 = EMA{T2}(period = period)

        ema2 = EMA{Union{Missing,T2}}(period = period, input_filter = !ismissing)
        ema3 = EMA{Union{Missing,T2}}(period = period, input_filter = !ismissing)
        add_input_indicator!(ema2, ema1)  # <-
        add_input_indicator!(ema3, ema2)  # <-
        sub_indicators = Series(ema1)

        output_history = CircBuff(T2, 2, rev = false)

        new{Tval,false,T2}(
            initialize_indicator_common_fields()...,
            output_history,
            period,
            sub_indicators,
            ema1,
            ema2,
            ema3,
            input_modifier,
            input_filter,
            input_values,
        )
    end
end

function _calculate_new_value(ind::TRIX)
    if has_output_value(ind.ema3)
        fit!(ind.output_history, value(ind.ema3))
        if length(ind.output_history.value) == 2
            return 10000 * (ind.output_history[end] - ind.output_history[end-1]) /
                   ind.output_history[end-1]
        else
            return missing
        end
    else
        return missing
    end
end
