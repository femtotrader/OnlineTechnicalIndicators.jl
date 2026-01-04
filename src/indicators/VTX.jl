const VTX_PERIOD = 14

"""
    VTXVal{Tval}

Return value type for Vortex Indicator.

# Fields
- `plus_vtx::Tval`: Plus Vortex Indicator (+VI)
- `minus_vtx::Tval`: Minus Vortex Indicator (-VI)

See also: [`VTX`](@ref)
"""
struct VTXVal{Tval}
    plus_vtx::Tval
    minus_vtx::Tval
end

"""
    VTX{Tohlcv}(; period = VTX_PERIOD, input_modifier_return_type = Tohlcv)

The `VTX` type implements a Vortex Indicator.

The Vortex Indicator identifies trend direction and trend reversals by analyzing the
relationship between price movement and true range. +VI rising above -VI suggests an
uptrend, while -VI rising above +VI suggests a downtrend.

# Parameters
- `period::Integer = $VTX_PERIOD`: The lookback period for the calculation
- `input_modifier_return_type::Type = Tohlcv`: Input OHLCV type

# Formula
```
+VM = |high - low_prev|
-VM = |low - high_prev|
+VI = sum(+VM, period) / sum(TR, period)
-VI = sum(-VM, period) / sum(TR, period)
```
Where TR is the True Range.

# Input
Requires OHLCV data with `high`, `low`, and `close` fields.

# Output
- [`VTXVal`](@ref): Contains `plus_vtx` (+VI) and `minus_vtx` (-VI) values

# Returns
`Union{Missing,VTXVal}` - The vortex indicator values, or `missing` during warm-up.

See also: [`TrueRange`](@ref), [`ADX`](@ref), [`Aroon`](@ref)
"""
mutable struct VTX{Tohlcv,IN,S} <: TechnicalIndicatorMultiOutput{Tohlcv}
    value::Union{Missing,VTXVal}
    n::Int

    period::Integer

    sub_indicators::Series
    tr::TrueRange

    tr_values::CircBuff

    plus_vm::CircBuff
    minus_vm::CircBuff
    input_values::CircBuff

    function VTX{Tohlcv}(;
        period = VTX_PERIOD,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        S = fieldtype(T2, :close)
        tr = TrueRange{T2}()
        sub_indicators = Series(tr)
        tr_values = CircBuff(Union{Missing,S}, period, rev = false)
        plus_vm = CircBuff(S, period, rev = false)
        minus_vm = CircBuff(S, period, rev = false)
        input_values = CircBuff(T2, 2, rev = false)
        new{Tohlcv,true,S}(
            missing,
            0,
            period,
            sub_indicators,
            tr,
            tr_values,
            plus_vm,
            minus_vm,
            input_values,
        )
    end
end

function VTX(;
    period = VTX_PERIOD,
    input_modifier_return_type = OHLCV{Missing,Float64,Float64},
)
    VTX{input_modifier_return_type}(;
        period = period,
        input_modifier_return_type = input_modifier_return_type,
    )
end

function _calculate_new_value(ind::VTX)
    _atr_value = value(ind.tr)
    fit!(ind.tr_values, _atr_value)
    if ind.n > 1
        candle = ind.input_values[end]
        candle_prev = ind.input_values[end-1]
        fit!(ind.plus_vm, abs(candle.high - candle_prev.low))
        fit!(ind.minus_vm, abs(candle.low - candle_prev.high))
        if !has_valid_values(ind.tr_values, ind.period) ||
           !has_valid_values(ind.plus_vm, ind.period) ||
           !has_valid_values(ind.minus_vm, ind.period)
            return missing
        end
        atr_sum = sum(value(ind.tr_values))
        return VTXVal(sum(value(ind.plus_vm)) / atr_sum, sum(value(ind.minus_vm)) / atr_sum)
    else
        return missing
    end
end
