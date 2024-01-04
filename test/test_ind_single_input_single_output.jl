@testset "single input - single output" begin  # take only a single value as input

    @testset "SMA" begin
        ind = SMA{Float64}(period = P)
        @test nobs(ind) == 0
        ind = StatLag(ind, length(CLOSE_TMPL))
        fit!(ind, CLOSE_TMPL)
        @test nobs(ind) == length(CLOSE_TMPL)
        @test ismissing(value(ind.lag[1]))
        @test ismissing(value(ind.lag[2]))
        @test ismissing(value(ind.lag[3]))
        @test ismissing(value(ind.lag[P-1]))
        @test !ismissing(value(ind.lag[P]))

        @test isapprox(value(ind.lag[end-2]), 9.075500; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]), 9.183000; atol = ATOL)
        @test isapprox(value(ind), 9.308500; atol = ATOL)
    end

    #=
    # This is how talipp works for chaining indicators
    # but I haven't been able to achieve this with Julia
    # so I'm using an other solution see below
    @testset "Indicator chaining (SMA) - WIP" begin
        values = collect(1.0:10.0)
        # data -> (ind1) -> ... (ind2) -> ... -> (ind3) -> ... -> (ind4) -> ...
        ind1 = SMA{Float64}(period = 3)
        ind2 = SMA{Float64}(period = 3, input_indicator = ind1)
        ind3 = SMA{Float64}(period = 3, input_indicator = ind2)
        ind4 = SMA{Float64}(period = 3, input_indicator = ind3)
        for val in values
            fit!(ind1, val)
        end
        @test isapprox(value(ind1), 9.0; atol = ATOL)
        @test isapprox(value(ind2), 8.0; atol = ATOL)
        @test isapprox(value(ind3), 7.0; atol = ATOL)
        @test isapprox(value(ind4), 6.0; atol = ATOL)
    end
    =#

    @testset "Indicator chaining (SMA) - WIP" begin
        values = collect(1.0:10.0)
        # data -> (ind1) -> ... (ind2) -> ... -> (ind3) -> ... -> (ind4) -> ...
        ind1 = SMA{Float64}(period = 3)
        ind2 = SMA{Float64}(period = 3, input_filter = !ismissing)
        ind3 = SMA{Float64}(period = 3, input_filter = !ismissing)
        ind4 = SMA{Float64}(period = 3, input_filter = !ismissing)
        add_input_indicator!(ind2, ind1)  # <---
        add_input_indicator!(ind3, ind2)
        add_input_indicator!(ind4, ind3)
        for val in values
            fit!(ind1, val)
        end
        @test isapprox(value(ind1), 9.0; atol = ATOL)
        @test isapprox(value(ind2), 8.0; atol = ATOL)
        @test isapprox(value(ind3), 7.0; atol = ATOL)
        @test isapprox(value(ind4), 6.0; atol = ATOL)
    end

    @testset "EMA" begin
        ind = EMA{Float64}(period = P)
        @test nobs(ind) == 0
        ind = StatLag(ind, 3)
        fit!(ind, CLOSE_TMPL)
        @test nobs(ind) == length(CLOSE_TMPL)
        @test isapprox(value(ind.lag[end-2]), 9.319374; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]), 9.406100; atol = ATOL)
        @test isapprox(value(ind), 9.462662; atol = ATOL)
    end

    @testset "SMMA" begin
        @testset "last 3 values" begin
            ind = SMMA{Float64}(period = P)
            @test nobs(ind) == 0
            ind = StatLag(ind, 3)
            fit!(ind, CLOSE_TMPL)
            @test nobs(ind) == length(CLOSE_TMPL)
            @test isapprox(value(ind.lag[end-2]), 9.149589; atol = ATOL)
            @test isapprox(value(ind.lag[end-1]), 9.203610; atol = ATOL)
            @test isapprox(value(ind), 9.243429; atol = ATOL)
        end

        @testset "vector" begin
            ind = SMMA{Float64}(period = P)
            @test nobs(ind) == 0
            #=
            calculated = Union{Missing,Float64}[]
            for p in CLOSE_TMPL
                fit!(ind, p)
                v = value(ind)
                push!(calculated, v)
            end
            =#
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
    end

    @testset "RSI" begin
        ind = RSI{Float64}(period = P)
        @test nobs(ind) == 0
        ind = StatLag(ind, 3)
        fit!(ind, CLOSE_TMPL)
        @test nobs(ind) == length(CLOSE_TMPL)
        @test isapprox(value(ind.lag[end-2]), 57.880437; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]), 55.153392; atol = ATOL)
        @test isapprox(value(ind), 53.459494; atol = ATOL)
    end

    @testset "MeanDev" begin
        ind = MeanDev{Float64}(period = P)
        @test nobs(ind) == 0
        ind = StatLag(ind, 3)
        fit!(ind, CLOSE_TMPL)
        @test nobs(ind) == length(CLOSE_TMPL)
        @test isapprox(value(ind.lag[end-2]), 0.608949; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]), 0.595400; atol = ATOL)
        @test isapprox(value(ind), 0.535500; atol = ATOL)
    end

    @testset "StdDev" begin
        ind = StdDev{Float64}(period = P)
        @test nobs(ind) == 0
        ind = StatLag(ind, 3)
        fit!(ind, CLOSE_TMPL)
        @test nobs(ind) == length(CLOSE_TMPL)
        @test isapprox(value(ind.lag[end-2]), 0.800377; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]), 0.803828; atol = ATOL)
        @test isapprox(value(ind), 0.721424; atol = ATOL)
    end

    @testset "ROC" begin
        ind = ROC{Float64}(period = P)
        @test nobs(ind) == 0
        ind = StatLag(ind, 3)
        fit!(ind, CLOSE_TMPL)
        @test nobs(ind) == length(CLOSE_TMPL)
        @test isapprox(value(ind.lag[end-2]), 30.740740; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]), 26.608910; atol = ATOL)
        @test isapprox(value(ind), 33.511348; atol = ATOL)
    end

    @testset "WMA" begin
        ind = WMA{Float64}(period = P)
        @test nobs(ind) == 0
        ind = StatLag(ind, 3)
        fit!(ind, CLOSE_TMPL)
        @test nobs(ind) == length(CLOSE_TMPL)
        @test isapprox(value(ind.lag[end-2]), 9.417523; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]), 9.527476; atol = ATOL)
        @test isapprox(value(ind), 9.605285; atol = ATOL)
    end

    @testset "DPO" begin
        ind = DPO{Float64}(period = 20)
        @test nobs(ind) == 0
        ind = StatLag(ind, 3)
        fit!(ind, CLOSE_TMPL)
        @test nobs(ind) == length(CLOSE_TMPL)
        @test isapprox(value(ind.lag[end-2]), 0.344499; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]), 0.116999; atol = ATOL)
        @test isapprox(value(ind), 0.011499; atol = ATOL)
    end

    @testset "HMA" begin
        ind = HMA{Float64}(period = 20)
        @test nobs(ind) == 0
        ind = StatLag(ind, 3)
        fit!(ind, CLOSE_TMPL)
        @test nobs(ind) == length(CLOSE_TMPL)
        @test isapprox(value(ind.lag[end-2]), 9.718018; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]), 9.940188; atol = ATOL)
        @test isapprox(value(ind), 10.104067; atol = ATOL)
    end

    @testset "CoppockCurve" begin
        ind = CoppockCurve{Float64}(
            fast_roc_period = 11,
            slow_roc_period = 14,
            wma_period = 10,
        )
        @test nobs(ind) == 0
        ind = StatLag(ind, 3)
        fit!(ind, CLOSE_TMPL)
        @test nobs(ind) == length(CLOSE_TMPL)
        @test isapprox(value(ind.lag[end-2]), 27.309482; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]), 26.109333; atol = ATOL)
        @test isapprox(value(ind), 22.941006; atol = ATOL)
    end

    @testset "ALMA" begin
        ind = ALMA{Float64}(period = 9, offset = 0.85, sigma = 6.0)
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

    @testset "DEMA" begin
        ind = DEMA{Float64}(period = 20)
        @test nobs(ind) == 0
        ind = StatLag(ind, 3)
        fit!(ind, CLOSE_TMPL)
        @test nobs(ind) == length(CLOSE_TMPL)
        @test isapprox(value(ind.lag[end-2]), 9.683254; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]), 9.813792; atol = ATOL)
        @test isapprox(value(ind), 9.882701; atol = ATOL)
    end

    @testset "TEMA" begin
        ind = TEMA{Float64}(period = 10)
        @test nobs(ind) == 0
        ind = StatLag(ind, 3)
        fit!(ind, CLOSE_TMPL)
        @test nobs(ind) == length(CLOSE_TMPL)
        @test isapprox(value(ind.lag[end-2]), 10.330217; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]), 10.399910; atol = ATOL)
        @test isapprox(value(ind), 10.323950; atol = ATOL)
    end

    @testset "KAMA" begin
        ind = KAMA{Float64}(
            period = 14,
            fast_ema_constant_period = 2,
            slow_ema_constant_period = 30,
        )
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

    @testset "McGinleyDynamic" begin
        ind = McGinleyDynamic{Float64}(period = 14)
        @test nobs(ind) == 0
        ind = StatLag(ind, 3)
        fit!(ind, CLOSE_TMPL)
        @test nobs(ind) == length(CLOSE_TMPL)
        @test isapprox(value(ind.lag[end-2]), 8.839868; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]), 8.895229; atol = ATOL)
        @test isapprox(value(ind), 8.944634; atol = ATOL)
    end

    @testset "STC" begin
        ind = STC{Float64}(
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

    @testset "ZLEMA" begin
        ind = ZLEMA{Float64}(period = 20)
        @test nobs(ind) == 0
        ind = StatLag(ind, 3)
        fit!(ind, CLOSE_TMPL)
        @test nobs(ind) == length(CLOSE_TMPL)
        @test isapprox(value(ind.lag[end-2]), 9.738243; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]), 9.871744; atol = ATOL)
        @test isapprox(value(ind), 9.975387; atol = ATOL)
    end

    @testset "T3" begin
        ind = T3{Float64}(period = 5, factor = 0.7)
        @test nobs(ind) == 0
        ind = StatLag(ind, 3)
        fit!(ind, CLOSE_TMPL)
        @test nobs(ind) == length(CLOSE_TMPL)
        @test isapprox(value(ind.lag[end-2]), 9.718661; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]), 9.968503; atol = ATOL)
        @test isapprox(value(ind), 10.124616; atol = ATOL)
    end

    @testset "TRIX" begin
        ind = TRIX{Float64}(period = 10)
        @test nobs(ind) == 0
        ind = StatLag(ind, 3)
        fit!(ind, CLOSE_TMPL)
        @test nobs(ind) == length(CLOSE_TMPL)
        @test isapprox(value(ind.lag[end-2]), 66.062922; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]), 75.271366; atol = ATOL)
        @test isapprox(value(ind), 80.317194; atol = ATOL)
    end

    @testset "TSI" begin
        @testset "fit! with CLOSE_TMPL" begin
            ind = TSI{Float64}(fast_period = 14, slow_period = 23)
            @test nobs(ind) == 0
            ind = StatLag(ind, 3)
            fit!(ind, CLOSE_TMPL)
            @test nobs(ind) == length(CLOSE_TMPL)
            @test isapprox(value(ind.lag[end-2]), 9.159520; atol = ATOL)
            @test isapprox(value(ind.lag[end-1]), 10.724944; atol = ATOL)
            @test isapprox(value(ind), 11.181863; atol = ATOL)
        end

        @testset "fit! with CLOSE_EQUAL_VALUES_TMPL" begin
            ind = TSI{Float64}(fast_period = 3, slow_period = 5)
            @test nobs(ind) == 0
            ind = StatLag(ind, length(CLOSE_EQUAL_VALUES_TMPL))
            fit!(ind, CLOSE_EQUAL_VALUES_TMPL)
            @test nobs(ind) == length(CLOSE_EQUAL_VALUES_TMPL)
            results = Set([value(stat) for stat in value(ind.lag)])
            @test length(results) == 1
            @test ismissing(collect(results)[1])
        end
    end


end
