using OnlineStatsChains

const KST_ROC1_PERIOD = 5
const KST_ROC1_MA_PERIOD = 5
const KST_ROC2_PERIOD = 10
const KST_ROC2_MA_PERIOD = 5
const KST_ROC3_PERIOD = 15
const KST_ROC3_MA_PERIOD = 5
const KST_ROC4_PERIOD = 25
const KST_ROC4_MA_PERIOD = 10
const KST_SIGNAL_PERIOD = 9

"""
    KSTVal{Tval}

Return value type for Know Sure Thing (KST) indicator.

# Fields
- `kst::Tval`: KST line (weighted sum of smoothed ROC values)
- `signal::Union{Missing,Tval}`: Signal line (moving average of KST)

See also: [`KST`](@ref)
"""
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
        input_modifier_return_type = T
    )

The `KST` type implements Know Sure Thing indicator using OnlineStatsChains with filtered edges.

# Implementation Details
Uses OnlineStatsChains.StatDAG with filtered edges to organize 4 parallel ROC→MA chains.
Each chain computes ROC at different periods, then smooths with a moving average.

The DAG structure provides:
- Clear organization of 4 parallel ROC→MA pipelines
- Automatic propagation through filtered edges
- Named access to each stage for debugging

# Formula
KST = 1*ROC1_MA + 2*ROC2_MA + 3*ROC3_MA + 4*ROC4_MA
Signal = MA(KST, signal_period)

# Output
- [`KSTVal`](@ref): A value containing `kst` and `signal` values
"""
mutable struct KST{Tval,IN,S} <: TechnicalIndicatorMultiOutput{Tval}
    value::Union{Missing,KSTVal}
    n::Int

    sub_indicators::Series

    roc1_ma::MovingAverageIndicator
    roc2_ma::MovingAverageIndicator
    roc3_ma::MovingAverageIndicator
    roc4_ma::MovingAverageIndicator

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
        input_modifier_return_type = Tval,
    ) where {Tval}
        T2 = input_modifier_return_type

        # Create sub_indicators for ROCs (receive data from main fit!)
        roc1 = ROC{T2}(period = roc1_period)
        roc2 = ROC{T2}(period = roc2_period)
        roc3 = ROC{T2}(period = roc3_period)
        roc4 = ROC{T2}(period = roc4_period)
        sub_indicators = Series(roc1, roc2, roc3, roc4)

        # Create 4 standalone MAs (not in DAG since each gets fed manually)
        roc1_ma = MAFactory(T2)(ma, period = roc1_ma_period)
        roc2_ma = MAFactory(T2)(ma, period = roc2_ma_period)
        roc3_ma = MAFactory(T2)(ma, period = roc3_ma_period)
        roc4_ma = MAFactory(T2)(ma, period = roc4_ma_period)

        signal_line = MAFactory(T2)(ma, period = signal_period)

        new{Tval,false,T2}(
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

function KST(;
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
    input_modifier_return_type = Float64,
)
    KST{input_modifier_return_type}(;
        roc1_period = roc1_period,
        roc1_ma_period = roc1_ma_period,
        roc2_period = roc2_period,
        roc2_ma_period = roc2_ma_period,
        roc3_period = roc3_period,
        roc3_ma_period = roc3_ma_period,
        roc4_period = roc4_period,
        roc4_ma_period = roc4_ma_period,
        signal_period = signal_period,
        ma = ma,
        input_modifier_return_type = input_modifier_return_type,
    )
end

function _calculate_new_value(ind::KST)
    # Feed ROC values into corresponding MAs
    roc1_val = value(ind.sub_indicators.stats[1])
    roc2_val = value(ind.sub_indicators.stats[2])
    roc3_val = value(ind.sub_indicators.stats[3])
    roc4_val = value(ind.sub_indicators.stats[4])

    if !ismissing(roc1_val)
        fit!(ind.roc1_ma, roc1_val)
    end
    if !ismissing(roc2_val)
        fit!(ind.roc2_ma, roc2_val)
    end
    if !ismissing(roc3_val)
        fit!(ind.roc3_ma, roc3_val)
    end
    if !ismissing(roc4_val)
        fit!(ind.roc4_ma, roc4_val)
    end

    # Check if all MAs have produced values
    if has_output_value(ind.roc1_ma) &&
       has_output_value(ind.roc2_ma) &&
       has_output_value(ind.roc3_ma) &&
       has_output_value(ind.roc4_ma)
        # Compute weighted KST
        kst =
            value(ind.roc1_ma) +
            2 * value(ind.roc2_ma) +
            3 * value(ind.roc3_ma) +
            4 * value(ind.roc4_ma)
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
