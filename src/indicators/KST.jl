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
        ma = SMA
    )

The KST type implements Know Sure Thing indicator.
"""
mutable struct KST{Tval} <: TechnicalIndicator{Tval}
    value::Union{Missing,KSTVal{Tval}}
    n::Int

    sub_indicators::Series
    # roc1  # SMA
    # roc2  # SMA
    # roc3  # SMA
    # roc4  # SMA

    roc1_ma::MovingAverageIndicator  # SMA
    roc2_ma::MovingAverageIndicator  # SMA
    roc3_ma::MovingAverageIndicator  # SMA
    roc4_ma::MovingAverageIndicator  # SMA

    signal_line::MovingAverageIndicator  # SMA

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
    ) where {Tval}
        # roc1 = SMA{Tval}(period = roc1_period)
        # roc2 = SMA{Tval}(period = roc2_period)
        # roc3 = SMA{Tval}(period = roc3_period)
        # roc4 = SMA{Tval}(period = roc4_period)

        roc1 = MAFactory(Tval)(ma, roc1_period)
        roc2 = MAFactory(Tval)(ma, roc2_period)
        roc3 = MAFactory(Tval)(ma, roc3_period)
        roc4 = MAFactory(Tval)(ma, roc4_period)
        sub_indicators = Series(roc1, roc2, roc3, roc4)

        # roc1_ma = SMA{Tval}(period = roc1_ma_period)
        # roc2_ma = SMA{Tval}(period = roc2_ma_period)
        # roc3_ma = SMA{Tval}(period = roc3_ma_period)
        # roc4_ma = SMA{Tval}(period = roc4_ma_period)

        roc1_ma = MAFactory(Tval)(ma, roc1_ma_period)
        roc2_ma = MAFactory(Tval)(ma, roc2_ma_period)
        roc3_ma = MAFactory(Tval)(ma, roc3_ma_period)
        roc4_ma = MAFactory(Tval)(ma, roc4_ma_period)

        # signal_line = SMA{Tval}(period = signal_period)
        signal_line = MAFactory(Tval)(ma, signal_period)

        new{Tval}(
            missing,
            0,
            sub_indicators,
            roc1_ma,
            roc2_ma,
            roc3_ma,
            roc4_ma,
            signal_line,
        )
    end
end

function OnlineStatsBase._fit!(ind::KST{Tval}, data::Tval) where {Tval}
    fit!(ind.sub_indicators, data)
    # fit!(ind.roc1, data)
    # fit!(ind.roc2, data)
    # fit!(ind.roc3, data)
    # fit!(ind.roc4, data)
    roc1, roc2, roc3, roc4 = ind.sub_indicators.stats

    ind.n += 1

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
        ind.value = missing
        return
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

    ind.value = KSTVal(kst, signal_value)
end
