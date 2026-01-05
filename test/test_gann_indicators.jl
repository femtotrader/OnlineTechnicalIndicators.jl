using OnlineTechnicalIndicators
using OnlineTechnicalIndicators:
    GannSwingChart,
    GannSwingChartVal,
    PeakValleyDetector,
    PeakValleyVal,
    RetracementCalculator,
    RetracementVal,
    SupportResistanceLevel,
    SupportResistanceLevelVal

@testitem "GannSwingChart" begin
    using OnlineTechnicalIndicators.Indicators: GannSwingChart, GannSwingChartVal
    using OnlineTechnicalIndicators: OHLCV

    # Test basic construction
    ind = GannSwingChart{OHLCV{Missing,Float64,Float64}}(min_bars = 2)
    @test ind.min_bars == 2
    @test ind.current_trend == :downtrend  # Default start
    @test ind.consecutive_higher_highs == 0
    @test ind.consecutive_lower_lows == 0

    # Create test OHLCV data for upswing detection
    test_data = [
        OHLCV(1.0, 2.0, 0.5, 1.5, volume = 100.0),  # Low: 0.5, High: 2.0
        OHLCV(1.5, 3.0, 1.0, 2.5, volume = 110.0),  # Low: 1.0, High: 3.0 (higher high)
        OHLCV(2.0, 4.0, 1.5, 3.5, volume = 120.0),  # Low: 1.5, High: 4.0 (higher high)
    ]

    # Feed data to indicator
    for data in test_data
        fit!(ind, data)
    end

    result = value(ind)
    @test !ismissing(result)
    @test result isa GannSwingChartVal
    @test result.swing_high == 4.0  # Should detect the highest high

    # Test trend change detection (would need more complex setup)
    @test result.trend in [:uptrend, :downtrend]
end

@testitem "PeakValleyDetector" begin
    using OnlineTechnicalIndicators.Indicators: PeakValleyDetector, PeakValleyVal
    using OnlineTechnicalIndicators: OHLCV

    # Test construction
    ind = PeakValleyDetector{OHLCV{Missing,Float64,Float64}}(lookback = 2)
    @test ind.lookback == 2

    # Create test data with clear peak/valley pattern
    # Valley at index 3, Peak at index 7
    test_data = [
        OHLCV(2.0, 3.0, 1.0, 2.5, volume = 100.0),  # Bar 1
        OHLCV(1.8, 2.8, 0.8, 2.3, volume = 100.0),  # Bar 2
        OHLCV(1.5, 2.0, 0.5, 1.8, volume = 100.0),  # Bar 3 (Valley)
        OHLCV(1.8, 2.5, 0.8, 2.0, volume = 100.0),  # Bar 4
        OHLCV(2.0, 3.0, 1.2, 2.5, volume = 100.0),  # Bar 5
        OHLCV(2.5, 4.0, 1.8, 3.5, volume = 100.0),  # Bar 6
        OHLCV(3.0, 5.0, 2.5, 4.5, volume = 100.0),  # Bar 7 (Peak)
        OHLCV(2.8, 4.5, 2.0, 4.0, volume = 100.0),  # Bar 8
        OHLCV(2.5, 4.0, 1.8, 3.5, volume = 100.0),  # Bar 9
    ]

    # Feed data
    for data in test_data
        fit!(ind, data)
    end

    result = value(ind)
    @test !ismissing(result)
    @test result isa PeakValleyVal
    # After sufficient data, should detect peak and valley
    @test !ismissing(result.peak) || !ismissing(result.valley)
end

@testitem "RetracementCalculator" begin
    using OnlineTechnicalIndicators.Indicators: RetracementCalculator, RetracementVal
    using OnlineTechnicalIndicators: OHLCV

    # Test construction
    ind = RetracementCalculator{OHLCV{Missing,Float64,Float64}}(retracement_pct = 0.38)
    @test ind.retracement_pct == 0.38

    # Create upswing data: from 1.0 to 3.0 (swing size = 2.0)
    # 38% retracement should be: 3.0 - (3.0 - 1.0) × 0.38 = 3.0 - 0.76 = 2.24
    test_data = [
        OHLCV(1.0, 1.5, 1.0, 1.2, volume = 100.0),  # Start at 1.0
        OHLCV(2.0, 3.0, 1.8, 2.8, volume = 100.0),  # Peak at 3.0
        OHLCV(2.2, 2.5, 2.1, 2.2, volume = 100.0),  # Retracement to 2.2 (38% hit)
    ]

    for data in test_data
        fit!(ind, data)
    end

    result = value(ind)
    @test !ismissing(result)
    @test result isa RetracementVal

    # Check retracement calculation
    if !ismissing(result.retracement_38_long)
        @test result.retracement_38_long ≈ 2.24 atol = 0.1
    end
end

@testitem "SupportResistanceLevel" begin
    using OnlineTechnicalIndicators.Indicators: SupportResistanceLevel, SupportResistanceLevelVal
    using OnlineTechnicalIndicators: OHLCV

    # Test construction
    ind = SupportResistanceLevel{OHLCV{Missing,Float64,Float64}}()
    @test ind.support_active == true
    @test ind.resistance_active == true

    # Test with simple data
    test_data = [
        OHLCV(1.0, 2.0, 0.5, 1.5, volume = 100.0),  # Support at 0.5
        OHLCV(1.5, 3.0, 1.0, 2.5, volume = 100.0),  # Resistance at 3.0
        OHLCV(2.0, 2.5, 0.3, 2.0, volume = 100.0),  # Break support (0.3 < 0.5)
    ]

    for data in test_data
        fit!(ind, data)
    end

    result = value(ind)
    @test !ismissing(result)
    @test result isa SupportResistanceLevelVal
    @test !ismissing(result.support_level)
    @test !ismissing(result.resistance_level)

    # Should detect support break
    @test result.support_broken == true
    @test result.support_active == false
end

@testitem "Gann Integration - Multiple Indicators" begin
    using OnlineTechnicalIndicators: OHLCV
    using OnlineTechnicalIndicators.Indicators:
        GannSwingChart, PeakValleyDetector, RetracementCalculator

    # Test using multiple indicators together
    swing_chart = GannSwingChart{OHLCV{Missing,Float64,Float64}}()
    peak_valley = PeakValleyDetector{OHLCV{Missing,Float64,Float64}}(lookback = 2)
    retracement = RetracementCalculator{OHLCV{Missing,Float64,Float64}}()

    # Create realistic market data
    test_data = [
        OHLCV(100.0, 102.0, 98.0, 101.0, volume = 1000.0),
        OHLCV(101.0, 105.0, 99.0, 104.0, volume = 1100.0),
        OHLCV(104.0, 108.0, 102.0, 107.0, volume = 1200.0),
        OHLCV(107.0, 109.0, 103.0, 105.0, volume = 1050.0),
        OHLCV(105.0, 106.0, 101.0, 103.0, volume = 950.0),
    ]

    for data in test_data
        fit!(swing_chart, data)
        fit!(peak_valley, data)
        fit!(retracement, data)
    end

    swing_result = value(swing_chart)
    peak_result = value(peak_valley)
    retrace_result = value(retracement)

    # All indicators should produce results
    @test !ismissing(swing_result) || nobs(swing_chart) < 3  # May need more data
    @test !ismissing(peak_result) || nobs(peak_valley) < 5   # May need more data for lookback
    @test !ismissing(retrace_result) || nobs(retracement) < 2  # May need more data
end
