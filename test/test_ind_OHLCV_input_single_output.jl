using OnlineTechnicalIndicators.SampleData: V_OHLCV

@testitem "MISO - SMA with OHLCV input" begin
    using OnlineTechnicalIndicators.Indicators: SMA
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs, fit!, value

    const P = 20
    const ATOL = 0.00001

    ind = SMA(period = P, input_modifier_return_type = Float64)
    @test nobs(ind) == 0
    ind = StatLag(ind, 3)

    # fit!(ind, V_OHLCV) # doesn't work
    for o in V_OHLCV
        fit!(ind, o.close)
    end
    @test nobs(ind) == length(V_OHLCV)
    @test isapprox(value(ind.lag[end-2]), 9.075500; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), 9.183000; atol = ATOL)
    @test isapprox(value(ind), 9.308500; atol = ATOL)
end

@testitem "MISO - AccuDist" begin
    using OnlineTechnicalIndicators.Indicators: AccuDist
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs, fit!, value

    const ATOL = 0.00001

    ind = AccuDist()
    @test nobs(ind) == 0
    ind = StatLag(ind, 3)
    fit!(ind, V_OHLCV)
    @test nobs(ind) == length(V_OHLCV)
    @test isapprox(value(ind.lag[end-2]), -689.203568; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), -725.031632; atol = ATOL)
    @test isapprox(value(ind), -726.092152; atol = ATOL)
end

@testitem "MISO - BOP" begin
    using OnlineTechnicalIndicators.Indicators: BOP
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs, fit!, value

    const ATOL = 0.00001

    ind = BOP()
    @test nobs(ind) == 0
    ind = StatLag(ind, 3)
    fit!(ind, V_OHLCV)
    @test nobs(ind) == length(V_OHLCV)
    @test isapprox(value(ind.lag[end-2]), 0.447761; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), -0.870967; atol = ATOL)
    @test isapprox(value(ind), -0.363636; atol = ATOL)
end

@testitem "MISO - CCI" begin
    using OnlineTechnicalIndicators.Indicators: CCI
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs, fit!, value

    const ATOL = 0.00001

    ind = CCI(period = 20)
    @test nobs(ind) == 0
    ind = StatLag(ind, 3)
    fit!(ind, V_OHLCV)
    @test nobs(ind) == length(V_OHLCV)
    @test isapprox(value(ind.lag[end-2]), 179.169127; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), 141.667617; atol = ATOL)
    @test isapprox(value(ind), 89.601438; atol = ATOL)
end

@testitem "MISO - ChaikinOsc" begin
    using OnlineTechnicalIndicators.Indicators: ChaikinOsc
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs, fit!, value

    const ATOL = 0.00001

    ind = ChaikinOsc(fast_period = 5, slow_period = 7)
    @test nobs(ind) == 0
    ind = StatLag(ind, 3)
    fit!(ind, V_OHLCV)
    @test nobs(ind) == length(V_OHLCV)
    @test isapprox(value(ind.lag[end-2]), 31.280810; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), 28.688536; atol = ATOL)
    @test isapprox(value(ind), 24.913310; atol = ATOL)
end

@testitem "MISO - VWMA" begin
    using OnlineTechnicalIndicators.Indicators: VWMA
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs, fit!, value

    const P = 20
    const ATOL = 0.00001

    ind = VWMA(period = P)
    @test nobs(ind) == 0
    ind = StatLag(ind, 3)
    fit!(ind, V_OHLCV)
    @test nobs(ind) == length(V_OHLCV)
    @test isapprox(value(ind.lag[end-2]), 9.320203; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), 9.352602; atol = ATOL)
    @test isapprox(value(ind), 9.457708; atol = ATOL)
end

@testitem "MISO - VWAP" begin
    using OnlineTechnicalIndicators.Indicators: VWAP
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs, fit!, value

    const ATOL = 0.00001

    ind = VWAP()
    @test nobs(ind) == 0
    ind = StatLag(ind, length(V_OHLCV))
    fit!(ind, V_OHLCV)
    @test nobs(ind) == length(V_OHLCV)
    @test isapprox(value(ind.lag[1]), 10.47333; atol = ATOL)
    @test isapprox(value(ind.lag[2]), 10.21883; atol = ATOL)
    @test isapprox(value(ind.lag[3]), 10.20899; atol = ATOL)
    @test isapprox(value(ind.lag[end-2]), 9.125770; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), 9.136613; atol = ATOL)
    @test isapprox(value(ind), 9.149069; atol = ATOL)
end

@testitem "MISO - AO" begin
    using OnlineTechnicalIndicators.Indicators: AO
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs, fit!, value

    const ATOL = 0.00001

    ind = AO(fast_period = 5, slow_period = 7)
    @test nobs(ind) == 0
    ind = StatLag(ind, 3)
    fit!(ind, V_OHLCV)
    @test nobs(ind) == length(V_OHLCV)
    @test isapprox(value(ind.lag[end-2]), 0.117142; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), 0.257142; atol = ATOL)
    @test isapprox(value(ind), 0.373285; atol = ATOL)
end

@testitem "MISO - TrueRange" begin
    using OnlineTechnicalIndicators.Indicators: TrueRange
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs, fit!, value

    const ATOL = 0.00001

    ind = TrueRange()
    @test nobs(ind) == 0
    ind = StatLag(ind, 3)
    fit!(ind, V_OHLCV)
    @test nobs(ind) == length(V_OHLCV)
    @test isapprox(value(ind.lag[end-2]), 0.670000; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), 0.620000; atol = ATOL)
    @test isapprox(value(ind), 0.770000; atol = ATOL)
end

@testitem "MISO - ATR" begin
    using OnlineTechnicalIndicators.Indicators: ATR
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs, fit!, value

    const ATOL = 0.00001

    ind = ATR(period = 5)
    @test nobs(ind) == 0
    ind = StatLag(ind, 3)
    fit!(ind, V_OHLCV)
    @test nobs(ind) == length(V_OHLCV)
    @test isapprox(value(ind.lag[end-2]), 0.676426; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), 0.665141; atol = ATOL)
    @test isapprox(value(ind), 0.686113; atol = ATOL)
end

@testitem "MISO - ATR(1)" begin
    using OnlineTechnicalIndicators.Indicators: ATR
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs, fit!, value

    const ATOL = 0.00001

    ind = ATR(period = 1)
    @test nobs(ind) == 0
    ind = StatLag(ind, 3)
    fit!(ind, V_OHLCV)
    @test nobs(ind) == length(V_OHLCV)
    @test isapprox(value(ind.lag[end-2]), 0.669999; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), 0.619999; atol = ATOL)
    @test isapprox(value(ind), 0.770000; atol = ATOL)
end

@testitem "MISO - ForceIndex" begin
    using OnlineTechnicalIndicators.Indicators: ForceIndex
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs, fit!, value

    const ATOL = 0.00001

    ind = ForceIndex(period = 20)
    @test nobs(ind) == 0
    ind = StatLag(ind, 3)
    fit!(ind, V_OHLCV)
    @test nobs(ind) == length(V_OHLCV)
    @test isapprox(value(ind.lag[end-2]), 24.015092; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), 20.072283; atol = ATOL)
    @test isapprox(value(ind), 16.371894; atol = ATOL)
end

@testitem "MISO - OBV" begin
    using OnlineTechnicalIndicators.Indicators: OBV
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs, fit!, value

    const ATOL = 0.00001

    ind = OBV()
    @test nobs(ind) == 0
    ind = StatLag(ind, 3)
    fit!(ind, V_OHLCV)
    @test nobs(ind) == length(V_OHLCV)
    @test isapprox(value(ind.lag[end-2]), 665.899999; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), 617.609999; atol = ATOL)
    @test isapprox(value(ind), 535.949999; atol = ATOL)
end

@testitem "MISO - SOBV" begin
    using OnlineTechnicalIndicators.Indicators: SOBV
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs, fit!, value

    const ATOL = 0.00001

    ind = SOBV(period = 20)
    @test nobs(ind) == 0
    ind = StatLag(ind, 3)
    fit!(ind, V_OHLCV)
    @test nobs(ind) == length(V_OHLCV)
    @test isapprox(value(ind.lag[end-2]), 90.868499; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), 139.166499; atol = ATOL)
    @test isapprox(value(ind), 187.558499; atol = ATOL)
end

@testitem "MISO - EMV" begin
    using OnlineTechnicalIndicators.Indicators: EMV
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs, fit!, value

    const ATOL = 0.00001

    ind = EMV(period = 14, volume_div = 10000)
    @test nobs(ind) == 0
    ind = StatLag(ind, 3)
    fit!(ind, V_OHLCV)
    @test nobs(ind) == length(V_OHLCV)
    @test isapprox(value(ind.lag[end-2]), 5.656780; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), 5.129971; atol = ATOL)
    @test isapprox(value(ind), -0.192883; atol = ATOL)
end

@testitem "MISO - MassIndex" begin
    using OnlineTechnicalIndicators.Indicators: MassIndex
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs, fit!, value

    const ATOL = 0.00001

    ind = MassIndex(ma_period = 9, ma_ma_period = 9, ma_ratio_period = 10)
    @test nobs(ind) == 0
    ind = StatLag(ind, 3)
    fit!(ind, V_OHLCV)
    @test nobs(ind) == length(V_OHLCV)
    @test isapprox(value(ind.lag[end-2]), 9.498975; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), 9.537927; atol = ATOL)
    @test isapprox(value(ind), 9.648128; atol = ATOL)
end

@testitem "MISO - CHOP" begin
    using OnlineTechnicalIndicators.Indicators: CHOP
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs, fit!, value

    const ATOL = 0.00001

    ind = CHOP(period = 14)
    @test nobs(ind) == 0
    ind = StatLag(ind, 3)
    fit!(ind, V_OHLCV)
    @test nobs(ind) == length(V_OHLCV)
    @test isapprox(value(ind.lag[end-2]), 49.835100; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), 50.001477; atol = ATOL)
    @test isapprox(value(ind), 49.289273; atol = ATOL)
end

@testitem "MISO - KVO" begin
    using OnlineTechnicalIndicators.Indicators: KVO
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs, fit!, value

    const ATOL = 0.00001

    ind = KVO(fast_period = 5, slow_period = 10)
    @test nobs(ind) == 0
    ind = StatLag(ind, 3)
    fit!(ind, V_OHLCV)
    @test nobs(ind) == length(V_OHLCV)
    @test isapprox(value(ind.lag[end-2]), 4540.325257; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), 535.632479; atol = ATOL)
    @test isapprox(value(ind), -2470.776132; atol = ATOL)
end

@testitem "MISO - UO" begin
    using OnlineTechnicalIndicators.Indicators: UO
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs, fit!, value

    const ATOL = 0.00001

    ind = UO(fast_period = 3, mid_period = 5, slow_period = 7)
    @test nobs(ind) == 0
    ind = StatLag(ind, 3)
    fit!(ind, V_OHLCV)
    @test nobs(ind) == length(V_OHLCV)
    @test isapprox(value(ind.lag[end-2]), 67.574669; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), 54.423675; atol = ATOL)
    @test isapprox(value(ind), 47.901125; atol = ATOL)
end

@testitem "MISO - NATR" begin
    using OnlineTechnicalIndicators.Indicators: NATR
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs, fit!, value

    const ATOL = 0.00001

    ind = NATR(period = 5)
    @test nobs(ind) == 0
    ind = StatLag(ind, 3)
    fit!(ind, V_OHLCV)
    @test nobs(ind) == length(V_OHLCV)
    @test isapprox(value(ind.lag[end-2]), 6.387410; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), 6.501871; atol = ATOL)
    @test isapprox(value(ind), 6.861131; atol = ATOL)
end

@testitem "MISO - MFI" begin
    using OnlineTechnicalIndicators.Indicators: MFI
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs, fit!, value

    const ATOL = 0.00001

    ind = MFI(period = 14)
    @test nobs(ind) == 0
    ind = StatLag(ind, 3)
    fit!(ind, V_OHLCV)
    @test nobs(ind) == length(V_OHLCV)
    @test isapprox(value(ind.lag[end-2]), 74.139455; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), 67.291047; atol = ATOL)
    @test isapprox(value(ind), 56.996043; atol = ATOL)
end

@testitem "MISO - MFI edge cases" begin
    using OnlineTechnicalIndicators.Indicators: MFI
    using OnlineTechnicalIndicators.Candlesticks: OHLCV
    using OnlineStatsBase: nobs, fit!, value

    # Test warm-up period (should return missing)
    ind = MFI(period = 3)
    # OHLCV(open, high, low, close; volume, time)
    candle1 = OHLCV(10.0, 11.0, 9.0, 10.5; volume=100.0)
    candle2 = OHLCV(10.5, 12.0, 10.0, 11.0; volume=150.0)
    candle3 = OHLCV(11.0, 11.5, 10.5, 10.8; volume=120.0)
    candle4 = OHLCV(10.8, 11.2, 10.2, 11.1; volume=130.0)

    fit!(ind, candle1)
    @test ismissing(value(ind))  # First candle - no comparison possible

    fit!(ind, candle2)
    @test ismissing(value(ind))  # Still in warm-up

    fit!(ind, candle3)
    @test ismissing(value(ind))  # Still in warm-up (need period+1)

    fit!(ind, candle4)
    @test !ismissing(value(ind))  # Now should have value
    @test value(ind) >= 0.0 && value(ind) <= 100.0  # MFI in valid range

    # Test zero volume handling
    ind2 = MFI(period = 2)
    candle_zero_vol = OHLCV(10.0, 11.0, 9.0, 10.5; volume=0.0)
    fit!(ind2, candle1)
    fit!(ind2, candle_zero_vol)
    fit!(ind2, candle2)
    @test !ismissing(value(ind2))  # Should still calculate

    # Test equal typical prices (neutral flow)
    ind3 = MFI(period = 2)
    candle_same_tp1 = OHLCV(10.0, 11.0, 9.0, 10.0; volume=100.0)  # TP = 10
    candle_same_tp2 = OHLCV(10.0, 11.0, 9.0, 10.0; volume=100.0)  # TP = 10
    candle_same_tp3 = OHLCV(10.0, 11.0, 9.0, 10.0; volume=100.0)  # TP = 10
    fit!(ind3, candle_same_tp1)
    fit!(ind3, candle_same_tp2)
    fit!(ind3, candle_same_tp3)
    @test !ismissing(value(ind3))  # Should return neutral (50)
    @test isapprox(value(ind3), 50.0; atol = 0.00001)  # All neutral = 50
end

@testitem "MISO - MFI interface" begin
    using OnlineTechnicalIndicators.Indicators: MFI
    using OnlineTechnicalIndicators.Candlesticks: OHLCV
    using OnlineStatsBase: nobs, fit!, value

    # Test basic interface (fit!, value, nobs)
    ind = MFI(period = 3)

    # Initial state
    @test nobs(ind) == 0
    @test ismissing(value(ind))

    # Feed data one candle at a time
    # OHLCV(open, high, low, close; volume, time)
    candle1 = OHLCV(10.0, 11.0, 9.0, 10.5; volume=100.0)
    fit!(ind, candle1)
    @test nobs(ind) == 1

    candle2 = OHLCV(10.5, 12.0, 10.0, 11.0; volume=150.0)
    fit!(ind, candle2)
    @test nobs(ind) == 2

    candle3 = OHLCV(11.0, 11.5, 10.5, 10.8; volume=120.0)
    fit!(ind, candle3)
    @test nobs(ind) == 3

    candle4 = OHLCV(10.8, 11.2, 10.2, 11.1; volume=130.0)
    fit!(ind, candle4)
    @test nobs(ind) == 4
    @test !ismissing(value(ind))

    # Test custom period
    ind2 = MFI(period = 5)
    @test ind2.period == 5

    # Test default period
    ind3 = MFI()
    @test ind3.period == 14  # Default MFI period
end

@testitem "MISO - MFI StatLag integration" begin
    using OnlineTechnicalIndicators.Indicators: MFI
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.Candlesticks: OHLCV
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs, fit!, value

    # Test StatLag integration - track historical values
    ind = MFI(period = 14)
    ind = StatLag(ind, 5)  # Keep last 5 values

    # Feed all sample data
    fit!(ind, V_OHLCV)

    @test nobs(ind) == length(V_OHLCV)

    # Check that lag values are accessible
    @test !ismissing(value(ind.lag[end]))
    @test !ismissing(value(ind.lag[end-1]))
    @test !ismissing(value(ind.lag[end-2]))
    @test !ismissing(value(ind.lag[end-3]))
    @test !ismissing(value(ind.lag[end-4]))

    # Check that current value matches last lag value
    @test value(ind) == value(ind.lag[end])

    # Verify all values are in valid range
    for i in 0:4
        v = value(ind.lag[end-i])
        @test v >= 0.0 && v <= 100.0
    end
end

@testitem "MISO - IntradayRange" begin
    using OnlineTechnicalIndicators.Indicators: IntradayRange
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs, fit!, value

    const ATOL = 0.00001

    ind = IntradayRange()
    @test nobs(ind) == 0
    ind = StatLag(ind, 3)
    fit!(ind, V_OHLCV)
    @test nobs(ind) == length(V_OHLCV)

    # Reference values: High - Low for last 3 bars
    # Bar 48: 10.86 - 10.19 = 0.67
    # Bar 49: 10.77 - 10.15 = 0.62
    # Bar 50: 10.39 - 9.62 = 0.77
    @test isapprox(value(ind.lag[end-2]), 0.67; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), 0.62; atol = ATOL)
    @test isapprox(value(ind), 0.77; atol = ATOL)
end

@testitem "MISO - IntradayRange interface" begin
    using OnlineTechnicalIndicators.Indicators: IntradayRange
    using OnlineTechnicalIndicators.Candlesticks: OHLCV
    using OnlineStatsBase: nobs, fit!, value

    # Test basic interface
    ind = IntradayRange()
    @test nobs(ind) == 0
    @test ismissing(value(ind))

    # Test immediate output (no warm-up)
    candle = OHLCV(10.0, 12.0, 9.0, 11.0, volume=100.0)
    fit!(ind, candle)
    @test nobs(ind) == 1
    @test !ismissing(value(ind))
    @test value(ind) == 3.0  # 12.0 - 9.0

    # Test constructor with type parameter
    ind2 = IntradayRange{OHLCV{Missing,Float64,Float64}}()
    @test nobs(ind2) == 0
end

@testitem "MISO - IntradayRange StatLag integration" begin
    using OnlineTechnicalIndicators.Indicators: IntradayRange
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.Candlesticks: OHLCV
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs, fit!, value

    # Test StatLag integration
    ind = IntradayRange()
    ind = StatLag(ind, 5)

    fit!(ind, V_OHLCV)
    @test nobs(ind) == length(V_OHLCV)

    # All lag values should be accessible (no warm-up period)
    for i in 0:4
        @test !ismissing(value(ind.lag[end-i]))
        @test value(ind.lag[end-i]) >= 0.0  # Range is always non-negative
    end

    @test value(ind) == value(ind.lag[end])
end

@testitem "MISO - RelativeIntradayRange" begin
    using OnlineTechnicalIndicators.Indicators: RelativeIntradayRange
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs, fit!, value

    const ATOL = 0.00001

    ind = RelativeIntradayRange()
    @test nobs(ind) == 0
    ind = StatLag(ind, 3)
    fit!(ind, V_OHLCV)
    @test nobs(ind) == length(V_OHLCV)

    # Reference values: (High - Low) * 100 / Open for last 3 bars
    # Bar 48: (10.86 - 10.19) * 100 / 10.29 = 6.511175898931001
    # Bar 49: (10.77 - 10.15) * 100 / 10.77 = 5.756731662024134
    # Bar 50: (10.39 - 9.62) * 100 / 10.28 = 7.49027237354087
    @test isapprox(value(ind.lag[end-2]), 6.511175898931001; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), 5.756731662024134; atol = ATOL)
    @test isapprox(value(ind), 7.49027237354087; atol = ATOL)
end

@testitem "MISO - RelativeIntradayRange edge cases" begin
    using OnlineTechnicalIndicators.Indicators: RelativeIntradayRange
    using OnlineTechnicalIndicators.Candlesticks: OHLCV
    using OnlineStatsBase: nobs, fit!, value

    # Test zero Open returns missing
    ind = RelativeIntradayRange()
    candle_zero_open = OHLCV(0.0, 10.0, 5.0, 8.0, volume=100.0)
    fit!(ind, candle_zero_open)
    @test ismissing(value(ind))

    # Test zero range returns 0.0
    ind2 = RelativeIntradayRange()
    candle_zero_range = OHLCV(10.0, 10.0, 10.0, 10.0, volume=100.0)
    fit!(ind2, candle_zero_range)
    @test !ismissing(value(ind2))
    @test value(ind2) == 0.0

    # Test normal case
    ind3 = RelativeIntradayRange()
    candle = OHLCV(100.0, 110.0, 90.0, 105.0, volume=100.0)
    fit!(ind3, candle)
    @test !ismissing(value(ind3))
    @test value(ind3) == 20.0  # (110 - 90) * 100 / 100 = 20%
end

@testitem "MISO - RelativeIntradayRange interface" begin
    using OnlineTechnicalIndicators.Indicators: RelativeIntradayRange
    using OnlineTechnicalIndicators.Candlesticks: OHLCV
    using OnlineStatsBase: nobs, fit!, value

    # Test basic interface
    ind = RelativeIntradayRange()
    @test nobs(ind) == 0
    @test ismissing(value(ind))

    # Test immediate output (no warm-up)
    candle = OHLCV(50.0, 55.0, 45.0, 52.0, volume=100.0)
    fit!(ind, candle)
    @test nobs(ind) == 1
    @test !ismissing(value(ind))
    @test value(ind) == 20.0  # (55 - 45) * 100 / 50 = 20%

    # Test constructor with type parameter
    ind2 = RelativeIntradayRange{OHLCV{Missing,Float64,Float64}}()
    @test nobs(ind2) == 0
end

@testitem "MISO - RelativeIntradayRange StatLag integration" begin
    using OnlineTechnicalIndicators.Indicators: RelativeIntradayRange
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.Candlesticks: OHLCV
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs, fit!, value

    # Test StatLag integration
    ind = RelativeIntradayRange()
    ind = StatLag(ind, 5)

    fit!(ind, V_OHLCV)
    @test nobs(ind) == length(V_OHLCV)

    # All lag values should be accessible (no warm-up period)
    for i in 0:4
        @test !ismissing(value(ind.lag[end-i]))
        @test value(ind.lag[end-i]) >= 0.0  # Percentage is always non-negative
    end

    @test value(ind) == value(ind.lag[end])
end

@testitem "MISO - ADR" begin
    using OnlineTechnicalIndicators.Indicators: ADR
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs, fit!, value

    const ATOL = 0.00001

    ind = ADR(period = 5)
    @test nobs(ind) == 0
    ind = StatLag(ind, 3)
    fit!(ind, V_OHLCV)
    @test nobs(ind) == length(V_OHLCV)

    # Reference values: SMA of IntradayRange (High - Low) with period 5
    # ADR[48] = 0.82, ADR[49] = 0.762, ADR[50] = 0.72
    @test isapprox(value(ind.lag[end-2]), 0.82; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), 0.762; atol = ATOL)
    @test isapprox(value(ind), 0.72; atol = ATOL)
end

@testitem "MISO - ADR interface" begin
    using OnlineTechnicalIndicators.Indicators: ADR, EMA
    using OnlineTechnicalIndicators.Candlesticks: OHLCV
    using OnlineStatsBase: nobs, fit!, value

    # Test basic interface
    ind = ADR(period = 3)
    @test nobs(ind) == 0
    @test ismissing(value(ind))

    # Test warm-up period
    candle1 = OHLCV(10.0, 11.0, 9.0, 10.5, volume=100.0)
    candle2 = OHLCV(10.5, 12.0, 10.0, 11.0, volume=150.0)
    candle3 = OHLCV(11.0, 11.5, 10.5, 10.8, volume=120.0)

    fit!(ind, candle1)
    @test nobs(ind) == 1
    @test ismissing(value(ind))  # Still in warm-up

    fit!(ind, candle2)
    @test nobs(ind) == 2
    @test ismissing(value(ind))  # Still in warm-up

    fit!(ind, candle3)
    @test nobs(ind) == 3
    @test !ismissing(value(ind))  # Now should have value

    # Verify the value is the average of the 3 ranges
    # Range1 = 11-9 = 2, Range2 = 12-10 = 2, Range3 = 11.5-10.5 = 1
    # SMA = (2 + 2 + 1) / 3 = 1.666...
    @test isapprox(value(ind), 5.0 / 3.0; atol = 0.00001)

    # Test default period
    ind2 = ADR()
    @test ind2.period == 14

    # Test with custom MA type
    ind3 = ADR(period = 5, ma = EMA)
    @test ind3.period == 5
end

@testitem "MISO - ADR with different MA types" begin
    using OnlineTechnicalIndicators.Indicators: ADR, SMA, EMA, SMMA
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs, fit!, value

    # Test that different MA types produce different results
    adr_sma = ADR(period = 5, ma = SMA)
    adr_ema = ADR(period = 5, ma = EMA)

    fit!(adr_sma, V_OHLCV)
    fit!(adr_ema, V_OHLCV)

    # Both should have values
    @test !ismissing(value(adr_sma))
    @test !ismissing(value(adr_ema))

    # Values should be different (EMA weights recent values more)
    @test value(adr_sma) != value(adr_ema)
end

@testitem "MISO - ADR StatLag integration" begin
    using OnlineTechnicalIndicators.Indicators: ADR
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.Candlesticks: OHLCV
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs, fit!, value

    # Test StatLag integration
    ind = ADR(period = 5)
    ind = StatLag(ind, 5)

    fit!(ind, V_OHLCV)
    @test nobs(ind) == length(V_OHLCV)

    # All lag values should be accessible after warm-up
    for i in 0:4
        @test !ismissing(value(ind.lag[end-i]))
        @test value(ind.lag[end-i]) >= 0.0  # ADR is always non-negative
    end

    @test value(ind) == value(ind.lag[end])
end

@testitem "MISO - ARDR" begin
    using OnlineTechnicalIndicators.Indicators: ARDR
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs, fit!, value

    const ATOL = 0.00001

    ind = ARDR(period = 5)
    @test nobs(ind) == 0
    ind = StatLag(ind, 3)
    fit!(ind, V_OHLCV)
    @test nobs(ind) == length(V_OHLCV)

    # Reference values: SMA of RelativeIntradayRange ((High - Low) * 100 / Open) with period 5
    # ARDR[48] = 8.812618598428633, ARDR[49] = 8.015356793788495, ARDR[50] = 7.204812917495488
    @test isapprox(value(ind.lag[end-2]), 8.812618598428633; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), 8.015356793788495; atol = ATOL)
    @test isapprox(value(ind), 7.204812917495488; atol = ATOL)
end

@testitem "MISO - ARDR interface" begin
    using OnlineTechnicalIndicators.Indicators: ARDR, EMA
    using OnlineTechnicalIndicators.Candlesticks: OHLCV
    using OnlineStatsBase: nobs, fit!, value

    # Test basic interface
    ind = ARDR(period = 3)
    @test nobs(ind) == 0
    @test ismissing(value(ind))

    # Test warm-up period
    candle1 = OHLCV(100.0, 110.0, 90.0, 105.0, volume=100.0)  # RIR = 20%
    candle2 = OHLCV(105.0, 115.0, 95.0, 110.0, volume=150.0)  # RIR = 19.047...%
    candle3 = OHLCV(110.0, 120.0, 100.0, 115.0, volume=120.0) # RIR = 18.181...%

    fit!(ind, candle1)
    @test nobs(ind) == 1
    @test ismissing(value(ind))  # Still in warm-up

    fit!(ind, candle2)
    @test nobs(ind) == 2
    @test ismissing(value(ind))  # Still in warm-up

    fit!(ind, candle3)
    @test nobs(ind) == 3
    @test !ismissing(value(ind))  # Now should have value

    # Test default period
    ind2 = ARDR()
    @test ind2.period == 14

    # Test with custom MA type
    ind3 = ARDR(period = 5, ma = EMA)
    @test ind3.period == 5
end

@testitem "MISO - ARDR edge cases" begin
    using OnlineTechnicalIndicators.Indicators: ARDR
    using OnlineTechnicalIndicators.Candlesticks: OHLCV
    using OnlineStatsBase: nobs, fit!, value

    # Test handling of zero Open in the data
    ind = ARDR(period = 2)

    # Normal candle
    candle1 = OHLCV(100.0, 110.0, 90.0, 105.0, volume=100.0)
    fit!(ind, candle1)
    @test ismissing(value(ind))  # Still warming up

    # Candle with zero Open (should be skipped in average)
    candle_zero_open = OHLCV(0.0, 10.0, 5.0, 8.0, volume=100.0)
    fit!(ind, candle_zero_open)
    # Value should still be missing as we only have 1 valid RIR value
    @test ismissing(value(ind))

    # Another normal candle
    candle2 = OHLCV(105.0, 115.0, 95.0, 110.0, volume=150.0)
    fit!(ind, candle2)
    # Now we should have a value (2 valid RIR values)
    @test !ismissing(value(ind))
end

@testitem "MISO - ARDR with different MA types" begin
    using OnlineTechnicalIndicators.Indicators: ARDR, SMA, EMA, SMMA
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs, fit!, value

    # Test that different MA types produce different results
    ardr_sma = ARDR(period = 5, ma = SMA)
    ardr_smma = ARDR(period = 5, ma = SMMA)

    fit!(ardr_sma, V_OHLCV)
    fit!(ardr_smma, V_OHLCV)

    # Both should have values
    @test !ismissing(value(ardr_sma))
    @test !ismissing(value(ardr_smma))

    # Values should be different (SMMA is smoothed differently)
    @test value(ardr_sma) != value(ardr_smma)
end

@testitem "MISO - ARDR StatLag integration" begin
    using OnlineTechnicalIndicators.Indicators: ARDR
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.Candlesticks: OHLCV
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs, fit!, value

    # Test StatLag integration
    ind = ARDR(period = 5)
    ind = StatLag(ind, 5)

    fit!(ind, V_OHLCV)
    @test nobs(ind) == length(V_OHLCV)

    # All lag values should be accessible after warm-up
    for i in 0:4
        @test !ismissing(value(ind.lag[end-i]))
        @test value(ind.lag[end-i]) >= 0.0  # ARDR is always non-negative
    end

    @test value(ind) == value(ind.lag[end])
end

# ===== Smoother Tests =====

@testitem "Smoother - basic with TrueRange" begin
    using OnlineTechnicalIndicators.Indicators: Smoother, TrueRange, SMA
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs, fit!, value

    const ATOL = 0.00001

    # Create a Smoother with TrueRange and SMA(5)
    ind = Smoother(TrueRange; period = 5, ma = SMA)
    @test nobs(ind) == 0
    ind = StatLag(ind, 3)
    fit!(ind, V_OHLCV)
    @test nobs(ind) == length(V_OHLCV)

    # The smoother should produce values after warm-up
    @test !ismissing(value(ind))
    @test !ismissing(value(ind.lag[end-1]))
    @test !ismissing(value(ind.lag[end-2]))

    # Values should be positive (TrueRange is always positive)
    @test value(ind) > 0
end

@testitem "Smoother - MA type variation" begin
    using OnlineTechnicalIndicators.Indicators: Smoother, IntradayRange, SMA, EMA
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs, fit!, value

    # Create two smoothers with different MA types
    smoother_sma = Smoother(IntradayRange; period = 5, ma = SMA)
    smoother_ema = Smoother(IntradayRange; period = 5, ma = EMA)

    fit!(smoother_sma, V_OHLCV)
    fit!(smoother_ema, V_OHLCV)

    # Both should have values
    @test !ismissing(value(smoother_sma))
    @test !ismissing(value(smoother_ema))

    # Values should be different (EMA weights recent values more)
    @test value(smoother_sma) != value(smoother_ema)
end

@testitem "Smoother - missing value handling" begin
    using OnlineTechnicalIndicators.Indicators: Smoother, IntradayRange, SMA
    using OnlineTechnicalIndicators.Candlesticks: OHLCV
    using OnlineStatsBase: nobs, fit!, value

    # Create a Smoother with period 3
    ind = Smoother(IntradayRange; period = 3, ma = SMA)
    @test nobs(ind) == 0
    @test ismissing(value(ind))

    # Test warm-up period
    candle1 = OHLCV(10.0, 11.0, 9.0, 10.5, volume=100.0)
    candle2 = OHLCV(10.5, 12.0, 10.0, 11.0, volume=150.0)
    candle3 = OHLCV(11.0, 11.5, 10.5, 10.8, volume=120.0)

    fit!(ind, candle1)
    @test nobs(ind) == 1
    @test ismissing(value(ind))  # Still in warm-up

    fit!(ind, candle2)
    @test nobs(ind) == 2
    @test ismissing(value(ind))  # Still in warm-up

    fit!(ind, candle3)
    @test nobs(ind) == 3
    @test !ismissing(value(ind))  # Now should have value

    # Verify the value is the average of the 3 ranges
    # Range1 = 11-9 = 2, Range2 = 12-10 = 2, Range3 = 11.5-10.5 = 1
    # SMA = (2 + 2 + 1) / 3 = 1.666...
    @test isapprox(value(ind), 5.0 / 3.0; atol = 0.00001)
end
