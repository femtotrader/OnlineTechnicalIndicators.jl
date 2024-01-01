const KST_ROC1_PERIOD = 5
const KST_ROC1_MA_PERIOD = 5
const KST_ROC2_PERIOD = 10
const KST_ROC2_MA_PERIOD = 5
const KST_ROC3_PERIOD = 15
const KST_ROC3_MA_PERIOD = 5
const KST_ROC4_PERIOD = 25
const KST_ROC4_MA_PERIOD = 10
const KST_SIGNAL_PERIOD = 9

struct KSTVal{Tval}
    kst::Tval
    signal::Tval
end

"""
    KST{T}(;
        roc1_period = KST_ROC1_PERIOD,
        roc1_ma_period = KST_ROC1_MA_PERIOD,
        roc2_period = KST_ROC2_PERIOD,
        roc2_ma_period = KST_ROC2_MA_PERIOD,
        roc3_period = KST_ROC3_PERIOD,
        roc3_ma_period = KST_ROC3_MA_PERIOD,
        roc4_period = KST_ROC4_PERIOD,
        roc4_ma_period = KST_ROC4_MA_PERIOD,
        signal_period = KST_SIGNAL_PERIOD,
        ma = SMA,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = T
    )

The `KST` type implements Know Sure Thing indicator.
"""
mutable struct KST{Tval} <: TechnicalIndicator{Tval}
    value::Union{Missing,KSTVal}
    n::Int
    output_listeners::Series
    input_indicator::Union{Missing,TechnicalIndicator}

    sub_indicators::Series
    roc1::MovingAverageIndicator  # SMA
    roc2::MovingAverageIndicator  # SMA
    roc3::MovingAverageIndicator  # SMA
    roc4::MovingAverageIndicator  # SMA

    roc1_ma::MovingAverageIndicator  # SMA
    roc2_ma::MovingAverageIndicator  # SMA
    roc3_ma::MovingAverageIndicator  # SMA
    roc4_ma::MovingAverageIndicator  # SMA

    signal_line::MovingAverageIndicator  # SMA

    input_modifier::Function
    input_filter::Function

    function KST{Tval}(;
        roc1_period = KST_ROC1_PERIOD,
        roc1_ma_period = KST_ROC1_MA_PERIOD,
        roc2_period = KST_ROC2_PERIOD,
        roc2_ma_period = KST_ROC2_MA_PERIOD,
        roc3_period = KST_ROC3_PERIOD,
        roc3_ma_period = KST_ROC3_MA_PERIOD,
        roc4_period = KST_ROC4_PERIOD,
        roc4_ma_period = KST_ROC4_MA_PERIOD,
        signal_period = KST_SIGNAL_PERIOD,
        ma = SMA,
        input_filter = always_true,
        input_modifier = identity,
        input_modifier_return_type = Tval,
    ) where {Tval}
        T2 = input_modifier_return_type

        # roc1 = SMA{T2}(period = roc1_period)
        # roc2 = SMA{T2}(period = roc2_period)
        # roc3 = SMA{T2}(period = roc3_period)
        # roc4 = SMA{T2}(period = roc4_period)

        roc1 = MAFactory(T2)(ma, period = roc1_period)
        roc2 = MAFactory(T2)(ma, period = roc2_period)
        roc3 = MAFactory(T2)(ma, period = roc3_period)
        roc4 = MAFactory(T2)(ma, period = roc4_period)
        sub_indicators = Series(roc1, roc2, roc3, roc4)

        # roc1_ma = SMA{T2}(period = roc1_ma_period)
        # roc2_ma = SMA{T2}(period = roc2_ma_period)
        # roc3_ma = SMA{T2}(period = roc3_ma_period)
        # roc4_ma = SMA{T2}(period = roc4_ma_period)

        roc1_ma = MAFactory(T2)(ma, period = roc1_ma_period)
        roc2_ma = MAFactory(T2)(ma, period = roc2_ma_period)
        roc3_ma = MAFactory(T2)(ma, period = roc3_ma_period)
        roc4_ma = MAFactory(T2)(ma, period = roc4_ma_period)

        # signal_line = SMA{T2}(period = signal_period)
        signal_line = MAFactory(T2)(ma, period = signal_period)

        new{Tval}(
            initialize_indicator_common_fields()...,
            sub_indicators,
            roc1,
            roc2,
            roc3,
            roc4,
            roc1_ma,
            roc2_ma,
            roc3_ma,
            roc4_ma,
            signal_line,
            input_modifier,
            input_filter,
        )
    end
end

function _calculate_new_value(ind::KST)

    if has_output_value(ind.roc1)
        fit!(ind.roc1_ma, value(ind.roc1))
    end

    if has_output_value(ind.roc2)
        fit!(ind.roc2_ma, value(ind.roc2))
    end

    if has_output_value(ind.roc3)
        fit!(ind.roc3_ma, value(ind.roc3))
    end

    if has_output_value(ind.roc4)
        fit!(ind.roc4_ma, value(ind.roc4))
    end

    if !has_output_value(ind.roc1) ||
       !has_output_value(ind.roc2) ||
       !has_output_value(ind.roc3) ||
       !has_output_value(ind.roc4)
        return missing
    end

    kst =
        1.0 * value(ind.roc1_ma) +
        2.0 * value(ind.roc2_ma) +
        3.0 * value(ind.roc3_ma) +
        4.0 * value(ind.roc4_ma)
    fit!(ind.signal_line, kst)

    if length(ind.signal_line.value) > 0
        signal_value = value(ind.signal_line)
    else
        signal_value = missing
    end

    return KSTVal(kst, signal_value)
end
