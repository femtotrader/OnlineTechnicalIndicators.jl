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
    signal::Union{Missing,Tval}
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
    roc1::ROC
    roc2::ROC
    roc3::ROC
    roc4::ROC

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

        roc1 = ROC{T2}(period = roc1_period)
        roc2 = ROC{T2}(period = roc2_period)
        roc3 = ROC{T2}(period = roc3_period)
        roc4 = ROC{T2}(period = roc4_period)
        sub_indicators = Series(roc1, roc2, roc3, roc4)  # roc1, ... 4 are sub_indicators

        roc1_ma = MAFactory(T2)(ma, period = roc1_ma_period, input_filter = !ismissing)
        roc2_ma = MAFactory(T2)(ma, period = roc2_ma_period, input_filter = !ismissing)
        roc3_ma = MAFactory(T2)(ma, period = roc3_ma_period, input_filter = !ismissing)
        roc4_ma = MAFactory(T2)(ma, period = roc4_ma_period, input_filter = !ismissing)
        add_input_indicator!(roc1_ma, roc1)  # <-
        add_input_indicator!(roc2_ma, roc2)  # <-
        add_input_indicator!(roc3_ma, roc3)  # <-
        add_input_indicator!(roc4_ma, roc4)  # <-

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

expected_return_type(ind::KST) = KSTVal{typeof(ind).parameters[end]}

function _calculate_new_value(ind::KST)
    if has_output_value(ind.roc1_ma) &&
       has_output_value(ind.roc2_ma) &&
       has_output_value(ind.roc3_ma) &&
       has_output_value(ind.roc4_ma)
        kst =
            1.0 * value(ind.roc1_ma) +
            2.0 * value(ind.roc2_ma) +
            3.0 * value(ind.roc3_ma) +
            4.0 * value(ind.roc4_ma)
        fit!(ind.signal_line, kst)

        if has_output_value(ind.signal_line)
            signal_value = value(ind.signal_line)
        else
            signal_value = missing
        end

        return KSTVal(kst, signal_value)
    else
        return missing
    end
end
