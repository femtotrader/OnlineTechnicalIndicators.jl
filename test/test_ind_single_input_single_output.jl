using OnlineTechnicalIndicators
using OnlineTechnicalIndicators.SampleData: CLOSE_TMPL, CLOSE_EQUAL_VALUES_TMPL

@testitem "SISO - SMA" begin
    using OnlineTechnicalIndicators.Indicators: SMA
    using OnlineTechnicalIndicators.Internals: expected_return_type
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: CLOSE_TMPL
    using OnlineStatsBase: nobs, fit!, value, fit!, value

    const P = 20
    const ATOL = 0.00001

    ind = SMA(period = P)
    @test expected_return_type(ind) == Float64
    @test nobs(ind) == 0
    ind = StatLag(ind, length(CLOSE_TMPL))
    fit!(ind, CLOSE_TMPL)
    @test nobs(ind) == length(CLOSE_TMPL)
    for i = 1:P-1
        @test ismissing(value(ind.lag[i]))
    end
    @test !ismissing(value(ind.lag[P]))

    @test isapprox(value(ind.lag[end-2]), 9.075500; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), 9.183000; atol = ATOL)
    @test isapprox(value(ind), 9.308500; atol = ATOL)
end

@testitem "SISO - Indicator chaining (SMA)" begin
    using OnlineTechnicalIndicators.Indicators: SMA
    using OnlineStatsChains: StatDAG, add_node!, connect!, fit!, value

    const ATOL = 0.00001

    values = collect(1.0:10.0)
    # data -> (ind1) -> (ind2) -> (ind3) -> (ind4)
    # Using StatDAG to chain 4 SMAs

    ind1 = SMA(period = 3)
    ind2 = SMA(period = 3)
    ind3 = SMA(period = 3)
    ind4 = SMA(period = 3)

    # Create DAG chain: ind1 -> ind2 -> ind3 -> ind4
    dag = StatDAG()
    add_node!(dag, :ind1, ind1)
    add_node!(dag, :ind2, ind2)
    add_node!(dag, :ind3, ind3)
    add_node!(dag, :ind4, ind4)

    connect!(dag, :ind1, :ind2, filter = !ismissing)
    connect!(dag, :ind2, :ind3, filter = !ismissing)
    connect!(dag, :ind3, :ind4, filter = !ismissing)

    # Feed data into the DAG
    for val in values
        fit!(dag, :ind1 => val)
    end

    @test isapprox(value(dag, :ind1), 9.0; atol = ATOL)
    @test isapprox(value(dag, :ind2), 8.0; atol = ATOL)
    @test isapprox(value(dag, :ind3), 7.0; atol = ATOL)
    @test isapprox(value(dag, :ind4), 6.0; atol = ATOL)
end

@testitem "SISO - SMA with Vector as input" begin
    using OnlineTechnicalIndicators.Indicators: SMA
    using OnlineTechnicalIndicators.SampleData: CLOSE_TMPL

    const P = 20
    const ATOL = 0.00001

    calculated = SMA(CLOSE_TMPL; period = P)
    for i = 1:P-1
        @test ismissing(calculated[i])
    end
    @test !ismissing(calculated[P])
    @test isapprox(calculated[end-2], 9.075500; atol = ATOL)
    @test isapprox(calculated[end-1], 9.183000; atol = ATOL)
    @test isapprox(calculated[end], 9.308500; atol = ATOL)
end

@testitem "SISO - EMA" begin
    using OnlineTechnicalIndicators.Indicators: EMA
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: CLOSE_TMPL
    using OnlineStatsBase: nobs, fit!, value

    const P = 20
    const ATOL = 0.00001

    ind = EMA(period = P)
    @test nobs(ind) == 0
    ind = StatLag(ind, 3)
    fit!(ind, CLOSE_TMPL)
    @test nobs(ind) == length(CLOSE_TMPL)
    @test isapprox(value(ind.lag[end-2]), 9.319374; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), 9.406100; atol = ATOL)
    @test isapprox(value(ind), 9.462662; atol = ATOL)
end

@testitem "SISO - SMMA last 3 values" begin
    using OnlineTechnicalIndicators.Indicators: SMMA
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: CLOSE_TMPL
    using OnlineStatsBase: nobs, fit!, value

    const P = 20
    const ATOL = 0.00001

    ind = SMMA(period = P)
    @test nobs(ind) == 0
    ind = StatLag(ind, 3)
    fit!(ind, CLOSE_TMPL)
    @test nobs(ind) == length(CLOSE_TMPL)
    @test isapprox(value(ind.lag[end-2]), 9.149589; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), 9.203610; atol = ATOL)
    @test isapprox(value(ind), 9.243429; atol = ATOL)
end

@testitem "SISO - SMMA vector" begin
    using OnlineTechnicalIndicators.Indicators: SMMA
    using OnlineTechnicalIndicators.SampleData: CLOSE_TMPL
    using OnlineStatsBase: nobs, fit!, value

    const P = 20
    const ATOL = 0.00001

    ind = SMMA{eltype(CLOSE_TMPL)}(period = P)
    @test nobs(ind) == 0
    calculated = map(val -> value(fit!(ind, val)), CLOSE_TMPL)
    @test nobs(ind) == length(CLOSE_TMPL)
    expected = [
        missing,
        missing,
        missing,
        missing,
        missing,
        missing,
        missing,
        missing,
        missing,
        missing,
        missing,
        missing,
        missing,
        missing,
        missing,
        missing,
        missing,
        missing,
        missing,
        9.268500000000001,
        9.266075,
        9.257771250000001,
        9.210382687500001,
        9.168363553125001,
        9.124945375468752,
        9.057698106695314,
        9.00731320136055,
        8.96194754129252,
        8.917850164227895,
        8.8464576560165,
        8.783134773215675,
        8.75247803455489,
        8.756354132827147,
        8.76403642618579,
        8.7858346048765,
        8.834542874632675,
        8.86381573090104,
        8.885624944355989,
        8.90734369713819,
        8.91397651228128,
        8.918277686667215,
        8.938863802333856,
        8.958920612217163,
        8.935474581606305,
        8.94920085252599,
        9.00924080989969,
        9.073778769404708,
        9.149589830934472,
        9.203610339387748,
        9.24342982241836,
    ]
    @test length(calculated) == length(expected)
    @test sum(ismissing.(calculated)) == P - 1  # 19
    @test isapprox(calculated[P:end], expected[P:end]; atol = ATOL)
end

@testitem "SISO - RSI" begin
    using OnlineTechnicalIndicators.Indicators: RSI
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: CLOSE_TMPL
    using OnlineStatsBase: nobs, fit!, value

    const P = 20
    const ATOL = 0.00001

    ind = RSI(period = P)
    @test nobs(ind) == 0
    ind = StatLag(ind, 3)
    fit!(ind, CLOSE_TMPL)
    @test nobs(ind) == length(CLOSE_TMPL)
    @test isapprox(value(ind.lag[end-2]), 57.880437; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), 55.153392; atol = ATOL)
    @test isapprox(value(ind), 53.459494; atol = ATOL)
end

@testitem "SISO - MeanDev" begin
    using OnlineTechnicalIndicators.Indicators: MeanDev
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: CLOSE_TMPL
    using OnlineStatsBase: nobs, fit!, value

    const P = 20
    const ATOL = 0.00001

    ind = MeanDev(period = P)
    @test nobs(ind) == 0
    ind = StatLag(ind, 3)
    fit!(ind, CLOSE_TMPL)
    @test nobs(ind) == length(CLOSE_TMPL)
    @test isapprox(value(ind.lag[end-2]), 0.608949; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), 0.595400; atol = ATOL)
    @test isapprox(value(ind), 0.535500; atol = ATOL)
end

@testitem "SISO - StdDev" begin
    using OnlineTechnicalIndicators.Indicators: StdDev
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: CLOSE_TMPL
    using OnlineStatsBase: nobs, fit!, value

    const P = 20
    const ATOL = 0.00001

    ind = StdDev(period = P)
    @test nobs(ind) == 0
    ind = StatLag(ind, 3)
    fit!(ind, CLOSE_TMPL)
    @test nobs(ind) == length(CLOSE_TMPL)
    @test isapprox(value(ind.lag[end-2]), 0.800377; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), 0.803828; atol = ATOL)
    @test isapprox(value(ind), 0.721424; atol = ATOL)
end

@testitem "SISO - ROC" begin
    using OnlineTechnicalIndicators.Indicators: ROC
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: CLOSE_TMPL
    using OnlineStatsBase: nobs, fit!, value

    const P = 20
    const ATOL = 0.00001

    ind = ROC(period = P)
    @test nobs(ind) == 0
    ind = StatLag(ind, 3)
    fit!(ind, CLOSE_TMPL)
    @test nobs(ind) == length(CLOSE_TMPL)
    @test isapprox(value(ind.lag[end-2]), 30.740740; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), 26.608910; atol = ATOL)
    @test isapprox(value(ind), 33.511348; atol = ATOL)
end

@testitem "SISO - WMA" begin
    using OnlineTechnicalIndicators.Indicators: WMA
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: CLOSE_TMPL
    using OnlineStatsBase: nobs, fit!, value

    const P = 20
    const ATOL = 0.00001

    ind = WMA(period = P)
    @test nobs(ind) == 0
    ind = StatLag(ind, 3)
    fit!(ind, CLOSE_TMPL)
    @test nobs(ind) == length(CLOSE_TMPL)
    @test isapprox(value(ind.lag[end-2]), 9.417523; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), 9.527476; atol = ATOL)
    @test isapprox(value(ind), 9.605285; atol = ATOL)
end

@testitem "SISO - DPO" begin
    using OnlineTechnicalIndicators.Indicators: DPO
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: CLOSE_TMPL
    using OnlineStatsBase: nobs, fit!, value

    const ATOL = 0.00001

    ind = DPO(period = 20)
    @test nobs(ind) == 0
    ind = StatLag(ind, 3)
    fit!(ind, CLOSE_TMPL)
    @test nobs(ind) == length(CLOSE_TMPL)
    @test isapprox(value(ind.lag[end-2]), 0.344499; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), 0.116999; atol = ATOL)
    @test isapprox(value(ind), 0.011499; atol = ATOL)
end

@testitem "SISO - HMA" begin
    using OnlineTechnicalIndicators.Indicators: HMA
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: CLOSE_TMPL
    using OnlineStatsBase: nobs, fit!, value

    const ATOL = 0.00001

    ind = HMA(period = 20)
    @test nobs(ind) == 0
    ind = StatLag(ind, 3)
    fit!(ind, CLOSE_TMPL)
    @test nobs(ind) == length(CLOSE_TMPL)
    @test isapprox(value(ind.lag[end-2]), 9.718018; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), 9.940188; atol = ATOL)
    @test isapprox(value(ind), 10.104067; atol = ATOL)
end

@testitem "SISO - CoppockCurve" begin
    using OnlineTechnicalIndicators.Indicators: CoppockCurve
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: CLOSE_TMPL
    using OnlineStatsBase: nobs, fit!, value

    const ATOL = 0.00001

    ind = CoppockCurve(fast_roc_period = 11, slow_roc_period = 14, wma_period = 10)
    @test nobs(ind) == 0
    ind = StatLag(ind, 3)
    fit!(ind, CLOSE_TMPL)
    @test nobs(ind) == length(CLOSE_TMPL)
    @test isapprox(value(ind.lag[end-2]), 27.309482; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), 26.109333; atol = ATOL)
    @test isapprox(value(ind), 22.941006; atol = ATOL)
end

@testitem "SISO - ALMA" begin
    using OnlineTechnicalIndicators.Indicators: ALMA
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: CLOSE_TMPL
    using OnlineStatsBase: nobs, fit!, value

    const ATOL = 0.00001

    ind = ALMA(period = 9, offset = 0.85, sigma = 6.0)
    @test nobs(ind) == 0
    w_expected = [
        0.000335,
        0.003865,
        0.028565,
        0.135335,
        0.411112,
        0.800737,
        1.0,
        0.800737,
        0.411112,
    ]
    for (i, w_expected_val) in enumerate(w_expected)
        @test isapprox(ind.w[i], w_expected_val; atol = ATOL)
    end
    @test isapprox(ind.w_sum, 3.591801; atol = ATOL)
    ind = StatLag(ind, 3)
    fit!(ind, CLOSE_TMPL)
    @test nobs(ind) == length(CLOSE_TMPL)
    @test isapprox(value(ind.lag[end-2]), 9.795859; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), 10.121439; atol = ATOL)
    @test isapprox(value(ind), 10.257038; atol = ATOL)
end

@testitem "SISO - DEMA" begin
    using OnlineTechnicalIndicators.Indicators: DEMA
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: CLOSE_TMPL
    using OnlineStatsBase: nobs, fit!, value

    const ATOL = 0.00001

    ind = DEMA(period = 20)
    @test nobs(ind) == 0
    ind = StatLag(ind, 3)
    fit!(ind, CLOSE_TMPL)
    @test nobs(ind) == length(CLOSE_TMPL)
    @test isapprox(value(ind.lag[end-2]), 9.683254; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), 9.813792; atol = ATOL)
    @test isapprox(value(ind), 9.882701; atol = ATOL)
end

@testitem "SISO - TEMA" begin
    using OnlineTechnicalIndicators.Indicators: TEMA
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: CLOSE_TMPL
    using OnlineStatsBase: nobs, fit!, value

    const ATOL = 0.00001

    ind = TEMA(period = 10)
    @test nobs(ind) == 0
    ind = StatLag(ind, 3)
    fit!(ind, CLOSE_TMPL)
    @test nobs(ind) == length(CLOSE_TMPL)
    @test isapprox(value(ind.lag[end-2]), 10.330217; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), 10.399910; atol = ATOL)
    @test isapprox(value(ind), 10.323950; atol = ATOL)
end

@testitem "SISO - KAMA" begin
    using OnlineTechnicalIndicators.Indicators: KAMA
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: CLOSE_TMPL
    using OnlineStatsBase: nobs, fit!, value

    const ATOL = 0.00001

    ind = KAMA(period = 14, fast_ema_constant_period = 2, slow_ema_constant_period = 30)
    @test nobs(ind) == 0
    @test isapprox(ind.fast_smoothing_constant, 0.666666; atol = ATOL)
    @test isapprox(ind.slow_smoothing_constant, 0.064516; atol = ATOL)
    ind = StatLag(ind, 3)
    fit!(ind, CLOSE_TMPL)
    @test nobs(ind) == length(CLOSE_TMPL)
    @test isapprox(value(ind.lag[end-2]), 8.884374; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), 8.932091; atol = ATOL)
    @test isapprox(value(ind), 8.941810; atol = ATOL)
end

@testitem "SISO - McGinleyDynamic" begin
    using OnlineTechnicalIndicators.Indicators: McGinleyDynamic
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: CLOSE_TMPL
    using OnlineStatsBase: nobs, fit!, value

    const ATOL = 0.00001

    ind = McGinleyDynamic(period = 14)
    @test nobs(ind) == 0
    ind = StatLag(ind, 3)
    fit!(ind, CLOSE_TMPL)
    @test nobs(ind) == length(CLOSE_TMPL)
    @test isapprox(value(ind.lag[end-2]), 8.839868; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), 8.895229; atol = ATOL)
    @test isapprox(value(ind), 8.944634; atol = ATOL)
end

@testitem "SISO - STC" begin
    using OnlineTechnicalIndicators.Indicators: STC
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: CLOSE_TMPL
    using OnlineStatsBase: nobs, fit!, value

    const ATOL = 0.00001

    ind = STC(
        fast_macd_period = 5,
        slow_macd_period = 10,
        stoch_period = 10,
        stoch_smoothing_period = 3,
    )
    @test nobs(ind) == 0
    ind = StatLag(ind, 3)
    fit!(ind, CLOSE_TMPL)
    @test nobs(ind) == length(CLOSE_TMPL)
    @test isapprox(value(ind.lag[end-2]), 55.067364; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), 82.248999; atol = ATOL)
    @test isapprox(value(ind), 94.229147; atol = ATOL)
end

@testitem "SISO - ZLEMA" begin
    using OnlineTechnicalIndicators.Indicators: ZLEMA
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: CLOSE_TMPL
    using OnlineStatsBase: nobs, fit!, value

    const ATOL = 0.00001

    ind = ZLEMA(period = 20)
    @test nobs(ind) == 0
    ind = StatLag(ind, 3)
    fit!(ind, CLOSE_TMPL)
    @test nobs(ind) == length(CLOSE_TMPL)
    @test isapprox(value(ind.lag[end-2]), 9.738243; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), 9.871744; atol = ATOL)
    @test isapprox(value(ind), 9.975387; atol = ATOL)
end

@testitem "SISO - T3" begin
    using OnlineTechnicalIndicators.Indicators: T3
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: CLOSE_TMPL
    using OnlineStatsBase: nobs, fit!, value

    const ATOL = 0.00001

    ind = T3(period = 5, factor = 0.7)
    @test nobs(ind) == 0
    ind = StatLag(ind, 3)
    fit!(ind, CLOSE_TMPL)
    @test nobs(ind) == length(CLOSE_TMPL)
    @test isapprox(value(ind.lag[end-2]), 9.718661; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), 9.968503; atol = ATOL)
    @test isapprox(value(ind), 10.124616; atol = ATOL)
end

@testitem "SISO - TRIX" begin
    using OnlineTechnicalIndicators.Indicators: TRIX
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: CLOSE_TMPL
    using OnlineStatsBase: nobs, fit!, value

    const ATOL = 0.00001

    ind = TRIX(period = 10)
    @test nobs(ind) == 0
    ind = StatLag(ind, 3)
    fit!(ind, CLOSE_TMPL)
    @test nobs(ind) == length(CLOSE_TMPL)
    @test isapprox(value(ind.lag[end-2]), 66.062922; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), 75.271366; atol = ATOL)
    @test isapprox(value(ind), 80.317194; atol = ATOL)
end

@testitem "SISO - TSI with CLOSE_TMPL" begin
    using OnlineTechnicalIndicators.Indicators: TSI
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: CLOSE_TMPL
    using OnlineStatsBase: nobs, fit!, value

    const ATOL = 0.00001

    ind = TSI(fast_period = 14, slow_period = 23)
    @test nobs(ind) == 0
    ind = StatLag(ind, 3)
    fit!(ind, CLOSE_TMPL)
    @test nobs(ind) == length(CLOSE_TMPL)
    @test isapprox(value(ind.lag[end-2]), 9.159520; atol = ATOL)
    @test isapprox(value(ind.lag[end-1]), 10.724944; atol = ATOL)
    @test isapprox(value(ind), 11.181863; atol = ATOL)
end

@testitem "SISO - TSI with CLOSE_EQUAL_VALUES_TMPL" begin
    using OnlineTechnicalIndicators.Indicators: TSI
    using OnlineTechnicalIndicators: StatLag
    using OnlineTechnicalIndicators.SampleData: CLOSE_EQUAL_VALUES_TMPL
    using OnlineStatsBase: nobs, fit!, value

    ind = TSI(fast_period = 3, slow_period = 5)
    @test nobs(ind) == 0
    ind = StatLag(ind, length(CLOSE_EQUAL_VALUES_TMPL))
    fit!(ind, CLOSE_EQUAL_VALUES_TMPL)
    @test nobs(ind) == length(CLOSE_EQUAL_VALUES_TMPL)
    results = Set([value(stat) for stat in value(ind.lag)])
    @test length(results) == 1
    @test ismissing(collect(results)[1])
end
