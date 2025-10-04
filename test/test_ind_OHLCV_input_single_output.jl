using OnlineTechnicalIndicators
using OnlineTechnicalIndicators.SampleData: V_OHLCV

@testitem "MISO - SMA with OHLCV input" begin
    using OnlineTechnicalIndicators: SMA, StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs

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
    using OnlineTechnicalIndicators: AccuDist, StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs

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
    using OnlineTechnicalIndicators: BOP, StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs

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
    using OnlineTechnicalIndicators: CCI, StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs

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
    using OnlineTechnicalIndicators: ChaikinOsc, StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs

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
    using OnlineTechnicalIndicators: VWMA, StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs

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
    using OnlineTechnicalIndicators: VWAP, StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs

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
    using OnlineTechnicalIndicators: AO, StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs

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
    using OnlineTechnicalIndicators: TrueRange, StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs

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
    using OnlineTechnicalIndicators: ATR, StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs

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
    using OnlineTechnicalIndicators: ATR, StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs

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
    using OnlineTechnicalIndicators: ForceIndex, StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs

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
    using OnlineTechnicalIndicators: OBV, StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs

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
    using OnlineTechnicalIndicators: SOBV, StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs

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
    using OnlineTechnicalIndicators: EMV, StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs

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
    using OnlineTechnicalIndicators: MassIndex, StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs

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
    using OnlineTechnicalIndicators: CHOP, StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs

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
    using OnlineTechnicalIndicators: KVO, StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs

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
    using OnlineTechnicalIndicators: UO, StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs

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
    using OnlineTechnicalIndicators: NATR, StatLag
    using OnlineTechnicalIndicators.SampleData: V_OHLCV
    using OnlineStatsBase: nobs

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
