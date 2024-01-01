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
        input_filter = always_true, input_modifier = identity, input_modifier_return_type = T
    )

The `KST` type implements Know Sure Thing indicator.
"""
mutable struct KST{Tval} <: TechnicalIndicator{Tval}
    value::Union{Missing,KSTVal{Tval}}
    n::Int

    output_listeners::Series

    sub_indicators::Series
    roc1::Any  # SMA
    roc2::Any  # SMA
    roc3::Any  # SMA
    roc4::Any  # SMA

    roc1_ma::MovingAverageIndicator  # SMA
    roc2_ma::MovingAverageIndicator  # SMA
    roc3_ma::MovingAverageIndicator  # SMA
    roc4_ma::MovingAverageIndicator  # SMA

    signal_line::MovingAverageIndicator  # SMA

    input_modifier::Function
    input_filter::Function
    input_indicator::Union{Missing,TechnicalIndicator}

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
        # roc1 = SMA{Tval}(period = roc1_period)
        # roc2 = SMA{Tval}(period = roc2_period)
        # roc3 = SMA{Tval}(period = roc3_period)
        # roc4 = SMA{Tval}(period = roc4_period)

        roc1 = MAFactory(Tval)(ma, period = roc1_period)
        roc2 = MAFactory(Tval)(ma, period = roc2_period)
        roc3 = MAFactory(Tval)(ma, period = roc3_period)
        roc4 = MAFactory(Tval)(ma, period = roc4_period)
        sub_indicators = Series(roc1, roc2, roc3, roc4)

        # roc1_ma = SMA{Tval}(period = roc1_ma_period)
        # roc2_ma = SMA{Tval}(period = roc2_ma_period)
        # roc3_ma = SMA{Tval}(period = roc3_ma_period)
        # roc4_ma = SMA{Tval}(period = roc4_ma_period)

        roc1_ma = MAFactory(Tval)(ma, period = roc1_ma_period)
        roc2_ma = MAFactory(Tval)(ma, period = roc2_ma_period)
        roc3_ma = MAFactory(Tval)(ma, period = roc3_ma_period)
        roc4_ma = MAFactory(Tval)(ma, period = roc4_ma_period)

        # signal_line = SMA{Tval}(period = signal_period)
        signal_line = MAFactory(Tval)(ma, period = signal_period)

        output_listeners = Series()
        input_indicator = missing

        new{Tval}(
            missing,
            0,
            output_listeners,
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
            input_indicator,
        )
    end
end

function _calculate_new_value(ind::KST)

    if has_output_value(ind.roc1)
        fit!(ind.roc1_ma, ind.roc1.value[end])
    end

    if has_output_value(ind.roc2)
        fit!(ind.roc2_ma, ind.roc2.value[end])
    end

    if has_output_value(ind.roc3)
        fit!(ind.roc3_ma, ind.roc3.value[end])
    end

    if has_output_value(ind.roc4)
        fit!(ind.roc4_ma, ind.roc4.value[end])
    end

    if !has_output_value(ind.roc1) ||
       !has_output_value(ind.roc2) ||
       !has_output_value(ind.roc3) ||
       !has_output_value(ind.roc4)
        return missing
    end

    kst =
        1.0 * ind.roc1_ma[end] +
        2.0 * ind.roc2_ma[end] +
        3.0 * ind.roc3_ma[end] +
        4.0 * ind.roc4_ma[end]
    fit!(ind.signal_line, kst)

    if length(ind.signal_line.value) > 0
        signal_value = ind.signal_line.value[end]
    else
        signal_value = missing
    end

    return KSTVal(kst, signal_value)
end
