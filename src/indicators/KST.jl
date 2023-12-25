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
        signal_period = KST_SIGNAL_PERIOD
    )

The KST type implements Know Sure Thing indicator.
"""
mutable struct KST{Tval} <: OnlineStat{Tval}
    value::Union{Missing,KSTVal{Tval}}
    n::Int

    roc1::SMA{Tval}
    roc2::SMA{Tval}
    roc3::SMA{Tval}
    roc4::SMA{Tval}

    roc1_ma::SMA{Tval}
    roc2_ma::SMA{Tval}
    roc3_ma::SMA{Tval}
    roc4_ma::SMA{Tval}

    signal_line::SMA{Tval}

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
    ) where {Tval}
        roc1 = SMA{Tval}(period = roc1_period)
        roc2 = SMA{Tval}(period = roc2_period)
        roc3 = SMA{Tval}(period = roc3_period)
        roc4 = SMA{Tval}(period = roc4_period)

        roc1_ma = SMA{Tval}(period = roc1_ma_period)
        roc2_ma = SMA{Tval}(period = roc2_ma_period)
        roc3_ma = SMA{Tval}(period = roc3_ma_period)
        roc4_ma = SMA{Tval}(period = roc4_ma_period)

        signal_line = SMA{Tval}(period = signal_period)

        new{Tval}(
            missing,
            0,
            roc1,
            roc2,
            roc3,
            roc4,
            roc1_ma,
            roc2_ma,
            roc3_ma,
            roc4_ma,
            signal_line,
        )
    end
end

function OnlineStatsBase._fit!(ind::KST{Tval}, data::Tval) where {Tval}
    fit!(ind.roc1, data)
    fit!(ind.roc2, data)
    fit!(ind.roc3, data)
    fit!(ind.roc4, data)

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
        1.0 * ind.roc1_ma.value[end] +
        2.0 * ind.roc2_ma.value[end] +
        3.0 * ind.roc3_ma.value[end] +
        4.0 * ind.roc4_ma.value[end]
    fit!(ind.signal_line, kst)

    if length(ind.signal_line.value) > 0
        signal_value = ind.signal_line.value[end]
    else
        signal_value = missing
    end

    ind.value = KSTVal(kst, signal_value)
end
