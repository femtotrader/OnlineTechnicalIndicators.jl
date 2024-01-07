const ADX_DI_PERIOD = 14
const ADX_PERIOD = 14

struct ADXVal{Tval}
    adx::Union{Missing,Tval}
    plus_di::Tval
    minus_di::Tval
end

"""
    ADX{Tohlcv,S}(; di_period = 14, adx_period = 14, input_filter = always_true, input_modifier = identity, input_modifier_return_type = Tohlcv)

The `ADX` type implements an Average Directional Index indicator.
"""
mutable struct ADX{Tohlcv,IN,S} <: TechnicalIndicatorMultiOutput{Tohlcv}
    value::Union{Missing,ADXVal}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    di_period::Integer
    adx_period::Integer

    sub_indicators::Series
    atr::ATR

    pdm::CircBuff   # plus directional movement
    mdm::CircBuff   # minus directional movement

    spdm::CircBuff  # smoothed plus directional movement
    smdm::CircBuff  # smoothed minus directional movement

    pdi::CircBuff  # plus directional index
    mdi::CircBuff  # minus directional index

    dx::CircBuff  # directional index

    input_modifier::Function
    input_filter::Function
    input_values::CircBuff

    function ADX{Tohlcv}(;
        di_period = ADX_DI_PERIOD,
        adx_period = ADX_PERIOD,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        S = fieldtype(T2, :close)
        atr = ATR{T2}(period = di_period)
        sub_indicators = Series(atr)
        pdm = CircBuff(S, di_period + 1, rev = false)
        mdm = CircBuff(S, di_period + 1, rev = false)
        spdm = CircBuff(S, adx_period + 1, rev = false)
        smdm = CircBuff(S, adx_period + 1, rev = false)
        pdi = CircBuff(S, adx_period, rev = false)
        mdi = CircBuff(S, adx_period, rev = false)
        dx = CircBuff(S, adx_period + 1, rev = false)
        input_values = CircBuff(T2, 2, rev = false)
        new{Tohlcv,true,S}(
            initialize_indicator_common_fields()...,
            di_period,
            adx_period,
            sub_indicators,
            atr,
            pdm,
            mdm,
            spdm,
            smdm,
            pdi,
            mdi,
            dx,
            input_modifier,
            input_filter,
            input_values,
        )
    end
end

function _calculate_new_value(ind::ADX{T,IN,S}) where {T,IN,S}
    if ind.n > 1

        current_input = ind.input_values[end]
        prev_input = ind.input_values[end-1]

        if current_input.high - prev_input.high > prev_input.low - current_input.low &&
           current_input.high - prev_input.high > 0
            fit!(ind.pdm, current_input.high - prev_input.high)
        else
            fit!(ind.pdm, zero(S))
        end

        if prev_input.low - current_input.low > current_input.high - prev_input.high &&
           prev_input.low - current_input.low > 0
            fit!(ind.mdm, prev_input.low - current_input.low)
        else
            fit!(ind.mdm, zero(S))
        end

        if !has_valid_values(ind.pdm, ind.di_period)
            return missing
        elseif has_valid_values(ind.pdm, ind.di_period, exact = true)
            fit!(ind.spdm, sum(value(ind.pdm)[end-ind.di_period+1:end]) / ind.di_period)
            fit!(ind.smdm, sum(value(ind.mdm)[end-ind.di_period+1:end]) / ind.di_period)
        elseif length(ind.pdm) > ind.di_period
            fit!(
                ind.spdm,
                (ind.spdm[end] * (ind.di_period - 1) + ind.pdm[end]) / ind.di_period,
            )
            fit!(
                ind.smdm,
                (ind.smdm[end] * (ind.di_period - 1) + ind.mdm[end]) / ind.di_period,
            )
        end

        fit!(ind.pdi, 100 * ind.spdm[end] / value(ind.atr))
        fit!(ind.mdi, 100 * ind.smdm[end] / value(ind.atr))

        fit!(
            ind.dx,
            100 * (abs(ind.pdi[end] - ind.mdi[end])) / (ind.pdi[end] + ind.mdi[end]),
        )

        adx = missing
        if length(ind.dx) == ind.adx_period
            adx = sum(value(ind.dx)[end-ind.adx_period+1:end]) / ind.adx_period
        elseif length(ind.dx) > ind.adx_period
            adx = (value(ind).adx * (ind.adx_period - 1) + ind.dx[end]) / ind.adx_period
        end

        return ADXVal(adx, ind.pdi[end], ind.mdi[end])

    else
        return missing
    end

end
