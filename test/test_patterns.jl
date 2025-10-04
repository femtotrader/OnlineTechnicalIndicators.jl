using OnlineTechnicalIndicators
using OnlineStatsBase: nobs

@testitem "Pattern - Doji" begin
    using OnlineTechnicalIndicators:
        OHLCV, Doji, SingleCandlePatternType, PatternDirection

    # Create a perfect doji (open = close)
    doji_candle = OHLCV(100.0, 102.0, 98.0, 100.0)
    ind = Doji{OHLCV{Missing,Float64,Missing}}()

    fit!(ind, doji_candle)

    @test !ismissing(value(ind))
    @test value(ind).pattern != SingleCandlePatternType.NONE
    @test value(ind).direction == PatternDirection.NEUTRAL ||
          value(ind).direction == PatternDirection.BULLISH ||
          value(ind).direction == PatternDirection.BEARISH
    @test value(ind).confidence > 0.5
end

@testitem "Pattern - Hammer" begin
    using OnlineTechnicalIndicators:
        OHLCV, Hammer, SingleCandlePatternType, PatternDirection

    # Create a hammer pattern (small body at top, long lower shadow)
    hammer_candle = OHLCV(100.0, 101.0, 95.0, 100.5)
    ind = Hammer{OHLCV{Missing,Float64,Missing}}()

    fit!(ind, hammer_candle)

    @test !ismissing(value(ind))
    if value(ind).pattern != SingleCandlePatternType.NONE
        @test value(ind).pattern == SingleCandlePatternType.HAMMER
        @test value(ind).direction == PatternDirection.BULLISH
        @test value(ind).confidence > 0.0
    end
end

@testitem "Pattern - Shooting Star" begin
    using OnlineTechnicalIndicators:
        OHLCV, ShootingStar, SingleCandlePatternType, PatternDirection

    # Create a shooting star pattern (small body at bottom, long upper shadow)
    star_candle = OHLCV(100.0, 105.0, 99.5, 100.5)
    ind = ShootingStar{OHLCV{Missing,Float64,Missing}}()

    fit!(ind, star_candle)

    @test !ismissing(value(ind))
    if value(ind).pattern != SingleCandlePatternType.NONE
        @test value(ind).pattern == SingleCandlePatternType.SHOOTING_STAR
        @test value(ind).direction == PatternDirection.BEARISH
        @test value(ind).confidence > 0.0
    end
end

@testitem "Pattern - Marubozu" begin
    using OnlineTechnicalIndicators:
        OHLCV, Marubozu, SingleCandlePatternType, PatternDirection

    # Create a bullish marubozu (no shadows)
    marubozu_candle = OHLCV(100.0, 110.0, 100.0, 110.0)
    ind = Marubozu{OHLCV{Missing,Float64,Missing}}()

    fit!(ind, marubozu_candle)

    @test !ismissing(value(ind))
    @test value(ind).pattern == SingleCandlePatternType.MARUBOZU_BULLISH
    @test value(ind).direction == PatternDirection.BULLISH
    @test value(ind).confidence > 0.8
end

@testitem "Pattern - Spinning Top" begin
    using OnlineTechnicalIndicators:
        OHLCV, SpinningTop, SingleCandlePatternType, PatternDirection

    # Create a spinning top (small body, long shadows on both sides)
    spinning_candle = OHLCV(100.0, 105.0, 95.0, 101.0)
    ind = SpinningTop{OHLCV{Missing,Float64,Missing}}()

    fit!(ind, spinning_candle)

    @test !ismissing(value(ind))
    if value(ind).pattern != SingleCandlePatternType.NONE
        @test value(ind).pattern == SingleCandlePatternType.SPINNING_TOP
        @test value(ind).direction == PatternDirection.NEUTRAL
    end
end

@testitem "Pattern - Bullish Engulfing" begin
    using OnlineTechnicalIndicators:
        OHLCV, Engulfing, TwoCandlePatternType, PatternDirection

    ind = Engulfing{OHLCV{Missing,Float64,Missing}}()

    # First candle: bearish
    candle1 = OHLCV(110.0, 111.0, 105.0, 106.0)
    fit!(ind, candle1)

    # Second candle: bullish engulfing
    candle2 = OHLCV(105.0, 115.0, 104.0, 114.0)
    fit!(ind, candle2)

    @test !ismissing(value(ind))
    @test value(ind).pattern == TwoCandlePatternType.BULLISH_ENGULFING
    @test value(ind).direction == PatternDirection.BULLISH
    @test value(ind).confidence > 0.0
end

@testitem "Pattern - Bearish Engulfing" begin
    using OnlineTechnicalIndicators:
        OHLCV, Engulfing, TwoCandlePatternType, PatternDirection

    ind = Engulfing{OHLCV{Missing,Float64,Missing}}()

    # First candle: bullish
    candle1 = OHLCV(100.0, 110.0, 99.0, 109.0)
    fit!(ind, candle1)

    # Second candle: bearish engulfing
    candle2 = OHLCV(110.0, 111.0, 95.0, 96.0)
    fit!(ind, candle2)

    @test !ismissing(value(ind))
    @test value(ind).pattern == TwoCandlePatternType.BEARISH_ENGULFING
    @test value(ind).direction == PatternDirection.BEARISH
    @test value(ind).confidence > 0.0
end

@testitem "Pattern - Bullish Harami" begin
    using OnlineTechnicalIndicators:
        OHLCV, Harami, TwoCandlePatternType, PatternDirection

    ind = Harami{OHLCV{Missing,Float64,Missing}}()

    # First candle: bearish (large)
    candle1 = OHLCV(110.0, 111.0, 100.0, 101.0)
    fit!(ind, candle1)

    # Second candle: small bullish inside first
    candle2 = OHLCV(104.0, 107.0, 103.0, 106.0)
    fit!(ind, candle2)

    @test !ismissing(value(ind))
    @test value(ind).pattern == TwoCandlePatternType.BULLISH_HARAMI
    @test value(ind).direction == PatternDirection.BULLISH
    @test value(ind).confidence > 0.0
end

@testitem "Pattern - Piercing Line" begin
    using OnlineTechnicalIndicators:
        OHLCV, PiercingDarkCloud, TwoCandlePatternType, PatternDirection

    ind = PiercingDarkCloud{OHLCV{Missing,Float64,Missing}}()

    # First candle: bearish
    candle1 = OHLCV(110.0, 111.0, 100.0, 101.0)
    fit!(ind, candle1)

    # Second candle: bullish closing above midpoint
    candle2 = OHLCV(99.0, 108.0, 98.0, 107.0)
    fit!(ind, candle2)

    @test !ismissing(value(ind))
    @test value(ind).pattern == TwoCandlePatternType.PIERCING_LINE
    @test value(ind).direction == PatternDirection.BULLISH
    @test value(ind).confidence > 0.0
end

@testitem "Pattern - Tweezer Bottom" begin
    using OnlineTechnicalIndicators:
        OHLCV, Tweezer, TwoCandlePatternType, PatternDirection

    ind = Tweezer{OHLCV{Missing,Float64,Missing}}()

    # First candle
    candle1 = OHLCV(105.0, 107.0, 100.0, 102.0)
    fit!(ind, candle1)

    # Second candle with matching low
    candle2 = OHLCV(103.0, 108.0, 100.0, 106.0)
    fit!(ind, candle2)

    @test !ismissing(value(ind))
    if value(ind).pattern != TwoCandlePatternType.NONE
        @test value(ind).pattern == TwoCandlePatternType.TWEEZER_BOTTOM
        @test value(ind).direction == PatternDirection.BULLISH
    end
end

@testitem "Pattern - Morning Star" begin
    using OnlineTechnicalIndicators:
        OHLCV, Star, ThreeCandlePatternType, PatternDirection

    ind = Star{OHLCV{Missing,Float64,Missing}}()

    # First candle: bearish
    candle1 = OHLCV(110.0, 111.0, 105.0, 106.0)
    fit!(ind, candle1)

    # Second candle: small star
    candle2 = OHLCV(104.0, 105.0, 103.0, 104.0)
    fit!(ind, candle2)

    # Third candle: bullish
    candle3 = OHLCV(105.0, 112.0, 104.0, 111.0)
    fit!(ind, candle3)

    @test !ismissing(value(ind))
    if value(ind).pattern != ThreeCandlePatternType.NONE
        @test value(ind).pattern == ThreeCandlePatternType.MORNING_STAR
        @test value(ind).direction == PatternDirection.BULLISH
    end
end

@testitem "Pattern - Evening Star" begin
    using OnlineTechnicalIndicators:
        OHLCV, Star, ThreeCandlePatternType, PatternDirection

    ind = Star{OHLCV{Missing,Float64,Missing}}()

    # First candle: bullish
    candle1 = OHLCV(100.0, 110.0, 99.0, 109.0)
    fit!(ind, candle1)

    # Second candle: small star
    candle2 = OHLCV(110.0, 111.0, 109.5, 110.5)
    fit!(ind, candle2)

    # Third candle: bearish
    candle3 = OHLCV(109.0, 110.0, 102.0, 103.0)
    fit!(ind, candle3)

    @test !ismissing(value(ind))
    if value(ind).pattern != ThreeCandlePatternType.NONE
        @test value(ind).pattern == ThreeCandlePatternType.EVENING_STAR
        @test value(ind).direction == PatternDirection.BEARISH
    end
end

@testitem "Pattern - Three White Soldiers" begin
    using OnlineTechnicalIndicators:
        OHLCV, ThreeSoldiersCrows, ThreeCandlePatternType, PatternDirection

    ind = ThreeSoldiersCrows{OHLCV{Missing,Float64,Missing}}()

    # Three consecutive bullish candles
    candle1 = OHLCV(100.0, 105.0, 99.0, 104.0)
    fit!(ind, candle1)

    candle2 = OHLCV(103.0, 108.0, 102.0, 107.0)
    fit!(ind, candle2)

    candle3 = OHLCV(106.0, 111.0, 105.0, 110.0)
    fit!(ind, candle3)

    @test !ismissing(value(ind))
    if value(ind).pattern != ThreeCandlePatternType.NONE
        @test value(ind).pattern == ThreeCandlePatternType.THREE_WHITE_SOLDIERS
        @test value(ind).direction == PatternDirection.BULLISH
    end
end

@testitem "Pattern - Three Black Crows" begin
    using OnlineTechnicalIndicators:
        OHLCV, ThreeSoldiersCrows, ThreeCandlePatternType, PatternDirection

    ind = ThreeSoldiersCrows{OHLCV{Missing,Float64,Missing}}()

    # Three consecutive bearish candles
    candle1 = OHLCV(110.0, 111.0, 106.0, 107.0)
    fit!(ind, candle1)

    candle2 = OHLCV(108.0, 109.0, 103.0, 104.0)
    fit!(ind, candle2)

    candle3 = OHLCV(105.0, 106.0, 100.0, 101.0)
    fit!(ind, candle3)

    @test !ismissing(value(ind))
    if value(ind).pattern != ThreeCandlePatternType.NONE
        @test value(ind).pattern == ThreeCandlePatternType.THREE_BLACK_CROWS
        @test value(ind).direction == PatternDirection.BEARISH
    end
end

@testitem "Pattern - Three Inside Up" begin
    using OnlineTechnicalIndicators:
        OHLCV, ThreeInside, ThreeCandlePatternType, PatternDirection

    ind = ThreeInside{OHLCV{Missing,Float64,Missing}}()

    # First candle: bearish (large)
    candle1 = OHLCV(110.0, 111.0, 100.0, 101.0)
    fit!(ind, candle1)

    # Second candle: small bullish (Harami)
    candle2 = OHLCV(104.0, 107.0, 103.0, 106.0)
    fit!(ind, candle2)

    # Third candle: bullish confirmation
    candle3 = OHLCV(106.0, 112.0, 105.0, 111.0)
    fit!(ind, candle3)

    @test !ismissing(value(ind))
    if value(ind).pattern != ThreeCandlePatternType.NONE
        @test value(ind).pattern == ThreeCandlePatternType.THREE_INSIDE_UP
        @test value(ind).direction == PatternDirection.BULLISH
    end
end

@testitem "Pattern - CandlestickPatternDetector" begin
    using OnlineTechnicalIndicators:
        OHLCV, CandlestickPatternDetector, AllPatternsVal

    ind = CandlestickPatternDetector{OHLCV{Missing,Float64,Missing}}()

    # Test with a Doji
    doji_candle = OHLCV(100.0, 102.0, 98.0, 100.0)
    fit!(ind, doji_candle)

    @test !ismissing(value(ind))
    result = value(ind)

    # Should have detected at least some patterns
    @test result isa AllPatternsVal

    # Test with a Marubozu
    marubozu_candle = OHLCV(100.0, 110.0, 100.0, 110.0)
    fit!(ind, marubozu_candle)

    @test !ismissing(value(ind))
    result = value(ind)

    # Should have detected the marubozu
    @test length(result.single_patterns) > 0

    # Test with engulfing pattern
    candle3 = OHLCV(105.0, 115.0, 104.0, 114.0)
    fit!(ind, candle3)

    @test !ismissing(value(ind))
end

@testitem "Pattern - Detection on Sequences" begin
    using OnlineTechnicalIndicators: OHLCV, Doji
    using OnlineStatsBase: nobs

    # Test incremental pattern detection with a sequence of candles
    ind = Doji{OHLCV{Missing,Float64,Missing}}()

    candles = [
        OHLCV(100.0, 105.0, 95.0, 103.0),
        OHLCV(103.0, 107.0, 102.0, 103.0),  # Doji
        OHLCV(103.0, 110.0, 103.0, 109.0),
    ]

    for candle in candles
        fit!(ind, candle)
    end

    @test nobs(ind) == 3
    @test !ismissing(value(ind))
end
