const ADX_DI_PERIOD = 14
const ADX_PERIOD = 14

struct ADXVal{Tval}
    adx::Union{Missing,Tval}
    plus_di::Tval
    minus_di::Tval
end

"""
    ADX{Tohlcv,S}(; di_period = 14, adx_period = 14)

The `ADX` type implements an Average Directional Index indicator.
"""
mutable struct ADX{Tohlcv,S} <: TechnicalIndicator{Tohlcv}
    value::Union{Missing,ADXVal{S}}
    n::Int

    di_period::Integer
    adx_period::Integer

    atr::ATR
    #sub_indicators::Series

    pdm::CircBuff   # plus directional movement
    mdm::CircBuff   # minus directional movement

    spdm::CircBuff  # smoothed plus directional movement
    smdm::CircBuff  # smoothed minus directional movement

    pdi::CircBuff  # plus directional index
    mdi::CircBuff  # minus directional index

    dx::CircBuff  # directional index

    input::CircBuff

    function ADX{Tohlcv,S}(; di_period = 14, adx_period = 14) where {Tohlcv,S}
        atr = ATR{Tohlcv,S}(period = di_period)
        sub_indicators = Series(atr)
        pdm = CircBuff(S, di_period, rev = false)
        mdm = CircBuff(S, di_period, rev = false)
        spdm = CircBuff(S, adx_period, rev = false)
        smdm = CircBuff(S, adx_period, rev = false)
        pdi = CircBuff(S, adx_period, rev = false)
        mdi = CircBuff(S, adx_period, rev = false)
        dx = CircBuff(S, adx_period, rev = false)
        input = CircBuff(Tohlcv, 2, rev = false)
        new{Tohlcv,S}(
            missing,
            0,
            di_period,
            adx_period,
            # atr,
            sub_indicators,
            pdm,
            mdm,
            spdm,
            smdm,
            pdi,
            mdi,
            dx,
            input,
        )
    end
end

function OnlineStatsBase._fit!(ind::ADX, candle)
    fit!(ind.input, candle)
    #fit!(ind.sub_indicators, candle)
    fit!(ind.atr, candle)
    ind.n += 1
    #atr, = ind.sub_indicators.stats
    if ind.n >= 2

        current_input = ind.input[end]
        prev_input = ind.input[end-1]

        if current_input.high - prev_input.high > prev_input.low - current_input.low &&
           current_input.high - prev_input.high > 0
            fit!(ind.pdm, current_input.high - prev_input.high)
        else
            fit!(ind.pdm, 0.0)
        end

        if prev_input.low - current_input.low > current_input.high - prev_input.high &&
           prev_input.low - current_input.low > 0
            fit!(ind.mdm, prev_input.low - current_input.low)
        else
            fit!(ind.mdm, 0.0)
        end

        if length(ind.pdm) < ind.di_period
            ind.value = missing
            return
        elseif length(ind.pdm) == ind.di_period
            fit!(ind.spdm, sum(ind.pdm.value) / ind.di_period)
            fit!(ind.smdm, sum(ind.mdm.value) / ind.di_period)
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


        fit!(ind.pdi, 100.0 * ind.spdm[end] / value(ind.atr))
        fit!(ind.mdi, 100.0 * ind.smdm[end] / value(ind.atr))

        fit!(
            ind.dx,
            100.0 * (abs(ind.pdi[end]) - ind.mdi[end]) / (ind.pdi[end] + ind.mdi[end]),
        )

        adx = missing
        if length(ind.dx) == ind.adx_period
            adx = sum(value(ind.dx)) / ind.adx_period
        elseif length(ind.dx) > ind.adx_period
            adx = (value(ind).adx * (ind.adx_period - 1) + ind.dx[end]) / ind.adx_period
        end

        ind.value = ADXVal(adx, ind.pdi[end], ind.mdi[end])

    else
        ind.value = missing
    end

end
