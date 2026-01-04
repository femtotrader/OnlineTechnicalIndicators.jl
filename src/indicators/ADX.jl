const ADX_DI_PERIOD = 14
const ADX_PERIOD = 14

"""
    ADXVal{Tval}

Return value type for Average Directional Index indicator.

# Fields
- `adx::Union{Missing,Tval}`: Average Directional Index value (trend strength)
- `plus_di::Tval`: Plus Directional Indicator (+DI)
- `minus_di::Tval`: Minus Directional Indicator (-DI)

See also: [`ADX`](@ref)
"""
struct ADXVal{Tval}
    adx::Union{Missing,Tval}
    plus_di::Tval
    minus_di::Tval
end

"""
    ADX{Tohlcv}(; di_period = ADX_DI_PERIOD, adx_period = ADX_PERIOD, input_modifier_return_type = Tohlcv)

The `ADX` type implements an Average Directional Index indicator.

ADX measures trend strength regardless of direction. Values above 25 suggest a strong trend,
while values below 20 indicate a weak or non-trending market. The +DI and -DI lines show
directional movement: +DI > -DI suggests uptrend, -DI > +DI suggests downtrend.

# Parameters
- `di_period::Integer = $ADX_DI_PERIOD`: Period for directional indicator calculation
- `adx_period::Integer = $ADX_PERIOD`: Period for ADX smoothing
- `input_modifier_return_type::Type = Tohlcv`: Input OHLCV type

# Formula
```
+DM = high - high_prev (if positive and > -DM, else 0)
-DM = low_prev - low (if positive and > +DM, else 0)
+DI = 100 × smoothed(+DM) / ATR
-DI = 100 × smoothed(-DM) / ATR
DX = 100 × |+DI - -DI| / (+DI + -DI)
ADX = smoothed(DX)
```

# Input
Requires OHLCV data with `high`, `low`, and `close` fields.

# Output
- [`ADXVal`](@ref): Contains `adx` (trend strength 0-100), `plus_di`, and `minus_di`

# Returns
`Union{Missing,ADXVal}` - The ADX values, or `missing` during warm-up.

See also: [`ATR`](@ref), [`Aroon`](@ref), [`VTX`](@ref)
"""
mutable struct ADX{Tohlcv,IN,S} <: TechnicalIndicatorMultiOutput{Tohlcv}
    value::Union{Missing,ADXVal}
    n::Int

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

    input_values::CircBuff

    function ADX{Tohlcv}(;
        di_period = ADX_DI_PERIOD,
        adx_period = ADX_PERIOD,
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
            missing,
            0,
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
            input_values,
        )
    end
end

function ADX(;
    di_period = ADX_DI_PERIOD,
    adx_period = ADX_PERIOD,
    input_modifier_return_type = OHLCV{Missing,Float64,Float64},
)
    ADX{input_modifier_return_type}(;
        di_period = di_period,
        adx_period = adx_period,
        input_modifier_return_type = input_modifier_return_type,
    )
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
