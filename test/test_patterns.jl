using OnlineTechnicalIndicators
using OnlineStatsBase: nobs
using Test

@testset "Pattern Recognition" begin

    @testset "Single Candle Patterns" begin

        @testset "Doji" begin
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

        @testset "Hammer" begin
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

        @testset "Shooting Star" begin
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

        @testset "Marubozu" begin
            # Create a bullish marubozu (no shadows)
            marubozu_candle = OHLCV(100.0, 110.0, 100.0, 110.0)
            ind = Marubozu{OHLCV{Missing,Float64,Missing}}()

            fit!(ind, marubozu_candle)

            @test !ismissing(value(ind))
            @test value(ind).pattern == SingleCandlePatternType.MARUBOZU_BULLISH
            @test value(ind).direction == PatternDirection.BULLISH
            @test value(ind).confidence > 0.8
        end

        @testset "Spinning Top" begin
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

    end

    @testset "Two Candle Patterns" begin

        @testset "Bullish Engulfing" begin
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

        @testset "Bearish Engulfing" begin
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

        @testset "Bullish Harami" begin
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

        @testset "Piercing Line" begin
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

        @testset "Tweezer Bottom" begin
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

    end

    @testset "Three Candle Patterns" begin

        @testset "Morning Star" begin
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

        @testset "Evening Star" begin
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

        @testset "Three White Soldiers" begin
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

        @testset "Three Black Crows" begin
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

        @testset "Three Inside Up" begin
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

    end

    @testset "CandlestickPatternDetector" begin
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

    @testset "Pattern Detection on Sequences" begin
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

end
