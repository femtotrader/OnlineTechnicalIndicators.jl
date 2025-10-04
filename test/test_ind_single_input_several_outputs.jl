using OnlineTechnicalIndicators
using OnlineTechnicalIndicators.SampleData: CLOSE_TMPL

@testitem "SIMO - BB" begin
    using OnlineTechnicalIndicators: BB, BBVal, expected_return_type, StatLag
    using OnlineTechnicalIndicators.SampleData: CLOSE_TMPL
    using OnlineStatsBase: nobs

    const ATOL = 0.00001

    ind = BB(period = 5, std_dev_mult = 2.0)
    @test expected_return_type(ind) == BBVal{Float64}

    @test nobs(ind) == 0
    ind = StatLag(ind, 3)
    fit!(ind, CLOSE_TMPL)
    @test nobs(ind) == length(CLOSE_TMPL)

    @test isapprox(value(ind.lag[end-2]).lower, 8.186646; atol = ATOL)
    @test isapprox(value(ind.lag[end-2]).central, 9.748000; atol = ATOL)
    @test isapprox(value(ind.lag[end-2]).upper, 11.309353; atol = ATOL)

    @test isapprox(value(ind.lag[end-1]).lower, 9.161539; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]).central, 10.096000; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]).upper, 11.030460; atol = ATOL)

    @test isapprox(value(ind).lower, 9.863185; atol = ATOL)
    @test isapprox(value(ind).central, 10.254000; atol = ATOL)
    @test isapprox(value(ind).upper, 10.644814; atol = ATOL)
end

@testitem "SIMO - MACD" begin
    using OnlineTechnicalIndicators: MACD, MACDVal, expected_return_type, StatLag
    using OnlineTechnicalIndicators.SampleData: CLOSE_TMPL
    using OnlineStatsBase: nobs

    const ATOL = 0.00001

    ind = MACD(fast_period = 12, slow_period = 26, signal_period = 9)
    @test expected_return_type(ind) == MACDVal{Float64}
    ind = StatLag(ind, 3)
    @test nobs(ind) == 0
    fit!(ind, CLOSE_TMPL)
    @test nobs(ind) == length(CLOSE_TMPL)

    @test isapprox(value(ind.lag[end-2]).macd, 0.293541; atol = ATOL)
    @test isapprox(value(ind.lag[end-2]).signal, 0.098639; atol = ATOL)
    @test isapprox(value(ind.lag[end-2]).histogram, 0.194901; atol = ATOL)

    @test isapprox(value(ind.lag[end-1]).macd, 0.326186; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]).signal, 0.144149; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]).histogram, 0.182037; atol = ATOL)

    @test isapprox(value(ind).macd, 0.329698; atol = ATOL)
    @test isapprox(value(ind).signal, 0.181259; atol = ATOL)
    @test isapprox(value(ind).histogram, 0.148439; atol = ATOL)
end

@testitem "SIMO - StochRSI" begin
    using OnlineTechnicalIndicators: StochRSI, StochRSIVal, expected_return_type, StatLag
    using OnlineTechnicalIndicators.SampleData: CLOSE_TMPL
    using OnlineStatsBase: nobs

    const ATOL = 0.00001

    ind = StochRSI(
        rsi_period = 14,
        stoch_period = 14,
        k_smoothing_period = 3,
        d_smoothing_period = 3,
    )
    @test expected_return_type(ind) == StochRSIVal{Float64}
    ind = StatLag(ind, 3)
    @test nobs(ind) == 0
    fit!(ind, CLOSE_TMPL)
    @test nobs(ind) == length(CLOSE_TMPL)

    @test isapprox(value(ind.lag[end-2]).k, 100.000000; atol = ATOL)
    @test isapprox(value(ind.lag[end-2]).d, 82.573394; atol = ATOL)

    @test isapprox(value(ind.lag[end-1]).k, 92.453271; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]).d, 92.500513; atol = ATOL)

    @test isapprox(value(ind).k, 80.286409; atol = ATOL)
    @test isapprox(value(ind).d, 90.913227; atol = ATOL)
end

@testitem "SIMO - KST" begin
    using OnlineTechnicalIndicators: KST, KSTVal, expected_return_type, StatLag
    using OnlineTechnicalIndicators.SampleData: CLOSE_TMPL
    using OnlineStatsBase: nobs

    const ATOL = 0.00001

    ind = KST(
        roc1_period = 5,
        roc1_ma_period = 5,
        roc2_period = 10,
        roc2_ma_period = 5,
        roc3_period = 15,
        roc3_ma_period = 5,
        roc4_period = 25,
        roc4_ma_period = 10,
        signal_period = 9,
    )
    @test expected_return_type(ind) == KSTVal{Float64}
    @test nobs(ind) == 0
    ind = StatLag(ind, 3)
    fit!(ind, CLOSE_TMPL)
    @test nobs(ind) == length(CLOSE_TMPL)

    @test isapprox(value(ind.lag[end-2]).kst, 136.602283; atol = ATOL)
    @test isapprox(value(ind.lag[end-2]).signal, 103.707431; atol = ATOL)

    @test isapprox(value(ind.lag[end-1]).kst, 158.252762; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]).signal, 113.964023; atol = ATOL)

    @test isapprox(value(ind).kst, 155.407034; atol = ATOL)
    @test isapprox(value(ind).signal, 122.246497; atol = ATOL)
end
