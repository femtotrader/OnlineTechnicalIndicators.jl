"""
    AllPatternsVal{S}

Return value type containing all detected candlestick patterns.

# Fields
- `single_patterns::Vector{SingleCandlePatternVal{S}}`: All detected single-candle patterns
- `two_patterns::Vector{TwoCandlePatternVal{S}}`: All detected two-candle patterns
- `three_patterns::Vector{ThreeCandlePatternVal{S}}`: All detected three-candle patterns
"""
struct AllPatternsVal{S}
    single_patterns::Vector{SingleCandlePatternVal{S}}
    two_patterns::Vector{TwoCandlePatternVal{S}}
    three_patterns::Vector{ThreeCandlePatternVal{S}}
end

"""
    CandlestickPatternDetector{Tohlcv}(; enable_single = true, enable_two = true, enable_three = true, input_modifier_return_type = Tohlcv)

The `CandlestickPatternDetector` type implements a comprehensive candlestick pattern detector
that aggregates all available pattern detection algorithms.

# Parameters
- `enable_single`: Enable single-candle pattern detection (default: true)
- `enable_two`: Enable two-candle pattern detection (default: true)
- `enable_three`: Enable three-candle pattern detection (default: true)

# Output
- [`AllPatternsVal`](@ref): A value containing all detected patterns
"""
mutable struct CandlestickPatternDetector{Tohlcv,IN,S} <: TechnicalIndicatorSingleOutput{Tohlcv}
    value::Union{Missing,AllPatternsVal}
    n::Int

    enable_single::Bool
    enable_two::Bool
    enable_three::Bool

    # Single-candle detectors
    doji::Union{Missing,Doji}
    hammer::Union{Missing,Hammer}
    shooting_star::Union{Missing,ShootingStar}
    marubozu::Union{Missing,Marubozu}
    spinning_top::Union{Missing,SpinningTop}

    # Two-candle detectors
    engulfing::Union{Missing,Engulfing}
    harami::Union{Missing,Harami}
    piercing_dark_cloud::Union{Missing,PiercingDarkCloud}
    tweezer::Union{Missing,Tweezer}

    # Three-candle detectors
    star::Union{Missing,Star}
    three_soldiers_crows::Union{Missing,ThreeSoldiersCrows}
    three_inside::Union{Missing,ThreeInside}

    input_values::CircBuff

    function CandlestickPatternDetector{Tohlcv}(;
        enable_single = true,
        enable_two = true,
        enable_three = true,
        input_modifier_return_type = Tohlcv,
    ) where {Tohlcv}
        T2 = input_modifier_return_type
        S = hasfield(T2, :close) ? fieldtype(T2, :close) : Float64

        # Initialize single-candle detectors
        doji = enable_single ? Doji{T2}() : missing
        hammer = enable_single ? Hammer{T2}() : missing
        shooting_star = enable_single ? ShootingStar{T2}() : missing
        marubozu = enable_single ? Marubozu{T2}() : missing
        spinning_top = enable_single ? SpinningTop{T2}() : missing

        # Initialize two-candle detectors
        engulfing = enable_two ? Engulfing{T2}() : missing
        harami = enable_two ? Harami{T2}() : missing
        piercing_dark_cloud = enable_two ? PiercingDarkCloud{T2}() : missing
        tweezer = enable_two ? Tweezer{T2}() : missing

        # Initialize three-candle detectors
        star = enable_three ? Star{T2}() : missing
        three_soldiers_crows = enable_three ? ThreeSoldiersCrows{T2}() : missing
        three_inside = enable_three ? ThreeInside{T2}() : missing

        # Use maximum lookback needed (3 for three-candle patterns)
        max_lookback = enable_three ? 3 : (enable_two ? 2 : 1)
        input_values = CircBuff(T2, max_lookback, rev = false)

        new{Tohlcv,true,S}(
            missing,
            0,
            enable_single,
            enable_two,
            enable_three,
            doji,
            hammer,
            shooting_star,
            marubozu,
            spinning_top,
            engulfing,
            harami,
            piercing_dark_cloud,
            tweezer,
            star,
            three_soldiers_crows,
            three_inside,
            input_values,
        )
    end
end

function _calculate_new_value(ind::CandlestickPatternDetector{T,IN,S}) where {T,IN,S}
    single_patterns = SingleCandlePatternVal{S}[]
    two_patterns = TwoCandlePatternVal{S}[]
    three_patterns = ThreeCandlePatternVal{S}[]

    candle = ind.input_values[end]

    # Process single-candle patterns
    if ind.enable_single
        # Fit all single-candle detectors
        !ismissing(ind.doji) && fit!(ind.doji, candle)
        !ismissing(ind.hammer) && fit!(ind.hammer, candle)
        !ismissing(ind.shooting_star) && fit!(ind.shooting_star, candle)
        !ismissing(ind.marubozu) && fit!(ind.marubozu, candle)
        !ismissing(ind.spinning_top) && fit!(ind.spinning_top, candle)

        # Collect detected patterns
        !ismissing(ind.doji) &&
            !ismissing(value(ind.doji)) &&
            is_detected(value(ind.doji)) &&
            push!(single_patterns, value(ind.doji))
        !ismissing(ind.hammer) &&
            !ismissing(value(ind.hammer)) &&
            is_detected(value(ind.hammer)) &&
            push!(single_patterns, value(ind.hammer))
        !ismissing(ind.shooting_star) &&
            !ismissing(value(ind.shooting_star)) &&
            is_detected(value(ind.shooting_star)) &&
            push!(single_patterns, value(ind.shooting_star))
        !ismissing(ind.marubozu) &&
            !ismissing(value(ind.marubozu)) &&
            is_detected(value(ind.marubozu)) &&
            push!(single_patterns, value(ind.marubozu))
        !ismissing(ind.spinning_top) &&
            !ismissing(value(ind.spinning_top)) &&
            is_detected(value(ind.spinning_top)) &&
            push!(single_patterns, value(ind.spinning_top))
    end

    # Process two-candle patterns
    if ind.enable_two && ind.n >= 2
        # Fit all two-candle detectors
        !ismissing(ind.engulfing) && fit!(ind.engulfing, candle)
        !ismissing(ind.harami) && fit!(ind.harami, candle)
        !ismissing(ind.piercing_dark_cloud) && fit!(ind.piercing_dark_cloud, candle)
        !ismissing(ind.tweezer) && fit!(ind.tweezer, candle)

        # Collect detected patterns
        !ismissing(ind.engulfing) &&
            !ismissing(value(ind.engulfing)) &&
            is_detected(value(ind.engulfing)) &&
            push!(two_patterns, value(ind.engulfing))
        !ismissing(ind.harami) &&
            !ismissing(value(ind.harami)) &&
            is_detected(value(ind.harami)) &&
            push!(two_patterns, value(ind.harami))
        !ismissing(ind.piercing_dark_cloud) &&
            !ismissing(value(ind.piercing_dark_cloud)) &&
            is_detected(value(ind.piercing_dark_cloud)) &&
            push!(two_patterns, value(ind.piercing_dark_cloud))
        !ismissing(ind.tweezer) &&
            !ismissing(value(ind.tweezer)) &&
            is_detected(value(ind.tweezer)) &&
            push!(two_patterns, value(ind.tweezer))
    end

    # Process three-candle patterns
    if ind.enable_three && ind.n >= 3
        # Fit all three-candle detectors
        !ismissing(ind.star) && fit!(ind.star, candle)
        !ismissing(ind.three_soldiers_crows) && fit!(ind.three_soldiers_crows, candle)
        !ismissing(ind.three_inside) && fit!(ind.three_inside, candle)

        # Collect detected patterns
        !ismissing(ind.star) &&
            !ismissing(value(ind.star)) &&
            is_detected(value(ind.star)) &&
            push!(three_patterns, value(ind.star))
        !ismissing(ind.three_soldiers_crows) &&
            !ismissing(value(ind.three_soldiers_crows)) &&
            is_detected(value(ind.three_soldiers_crows)) &&
            push!(three_patterns, value(ind.three_soldiers_crows))
        !ismissing(ind.three_inside) &&
            !ismissing(value(ind.three_inside)) &&
            is_detected(value(ind.three_inside)) &&
            push!(three_patterns, value(ind.three_inside))
    end

    return AllPatternsVal(single_patterns, two_patterns, three_patterns)
end

# Helper functions for AllPatternsVal
function has_patterns(val::AllPatternsVal)
    return length(val.single_patterns) > 0 ||
           length(val.two_patterns) > 0 ||
           length(val.three_patterns) > 0
end

function count_patterns(val::AllPatternsVal)
    return length(val.single_patterns) + length(val.two_patterns) +
           length(val.three_patterns)
end
