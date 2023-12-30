const T3_PERIOD = 5
const T3_FACTOR = 0.7


"""
    T3{T}(; period = T3_PERIOD, factor = T3_FACTOR)

The `T3` type implements a T3 Moving Average indicator.
"""
mutable struct T3{Tval} <: MovingAverageIndicator{Tval}
    value::Union{Missing,Tval}
    n::Int

    output_listeners::Series

    period::Int

    sub_indicators::Series
    ema1::EMA

    ema2::EMA
    ema3::EMA
    ema4::EMA
    ema5::EMA
    ema6::EMA

    c1::Tval
    c2::Tval
    c3::Tval
    c4::Tval

    input_indicator::Union{Missing,TechnicalIndicator}
    input_values::CircBuff{Tval}

    function T3{Tval}(; period = T3_PERIOD, factor = T3_FACTOR) where {Tval}
        input_values = CircBuff(Tval, 2, rev = false)
        ema1 = EMA{Tval}(period = period)
        ema2 = EMA{Tval}(period = period)
        ema3 = EMA{Tval}(period = period)
        ema4 = EMA{Tval}(period = period)
        ema5 = EMA{Tval}(period = period)
        ema6 = EMA{Tval}(period = period)
        # add_input_indicator!(ema2, ema1)  # <-
        # add_input_indicator!(ema3, ema2)  # <-
        # add_input_indicator!(ema4, ema3)  # <-
        # add_input_indicator!(ema5, ema4)  # <-
        # add_input_indicator!(ema6, ema5)  # <-
        sub_indicators = Series(ema1)
        c1 = -(factor^3)
        c2 = 3 * factor^2 + 3 * factor^3
        c3 = -6 * factor^2 - 3 * factor - 3 * factor^3
        c4 = 1 + 3 * factor + factor^3 + 3 * factor^2
        output_listeners = Series()
        input_indicator = missing
        new{Tval}(
            missing,
            0,
            output_listeners,
            period,
            sub_indicators,
            ema1,
            ema2,
            ema3,
            ema4,
            ema5,
            ema6,
            c1,
            c2,
            c3,
            c4,
            input_indicator,
            input_values,
        )
    end
end

function _calculate_new_value(ind::T3)
    _ema1 = value(ind.ema1)
    if !ismissing(_ema1)
        fit!(ind.ema2, value(ind.ema1))
        _ema2 = value(ind.ema2)
        if !ismissing(_ema2)
            fit!(ind.ema3, _ema2)
            _ema3 = value(ind.ema3)
            if !ismissing(_ema3)
                fit!(ind.ema4, _ema3)
                _ema4 = value(ind.ema4)
                if !ismissing(_ema4)
                    fit!(ind.ema5, _ema4)
                    _ema5 = value(ind.ema5)
                    if !ismissing(_ema5)
                        fit!(ind.ema6, _ema5)
                    end
                end
            end
        end
    end

    if has_output_value(ind.ema6)
        return ind.c1 * value(ind.ema6) +
               ind.c2 * value(ind.ema5) +
               ind.c3 * value(ind.ema4) +
               ind.c4 * value(ind.ema3)
    else
        return missing
    end
end

function OnlineStatsBase._fit!(ind::T3, data)
    fit!(ind.input_values, data)
    fit!(ind.sub_indicators, data)
    #fit!(ind.ema1, data)
    ind.n += 1
    ind.value = _calculate_new_value(ind)
    fit_listeners!(ind)
end
