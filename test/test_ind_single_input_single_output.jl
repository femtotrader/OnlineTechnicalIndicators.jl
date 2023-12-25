@testset "single input - single output" begin  # take only a single value as input

    @testset "SMA" begin
        ind = SMA{Float64}(period = P)
        fit!(ind, CLOSE_TMPL)
        @test isapprox(ind.value[end-2], 9.075500; atol = ATOL)
        @test isapprox(ind.value[end-1], 9.183000; atol = ATOL)
        @test isapprox(ind.value[end], 9.308500; atol = ATOL)
        @test length(ind.input) == P
        @test length(ind.value) == P
    end

    @testset "SMA_v02" begin
        ind = SMA_v02{Float64}(period = P)
        fit!(ind, CLOSE_TMPL)
        @test isapprox(ind.value[end-2], 9.075500; atol = ATOL)
        @test isapprox(ind.value[end-1], 9.183000; atol = ATOL)
        @test isapprox(ind.value[end], 9.308500; atol = ATOL)
        @test length(ind.input) == P
        @test length(ind.value) == P
    end

    #=
    @testset "SMA_v3" begin
        ind = SMA_v3{Float64}(period = P)
        fit!(ind, CLOSE_TMPL)
        @test isapprox(ind.value[end-2], 9.075500; atol = ATOL)
        @test isapprox(ind.value[end-1], 9.183000; atol = ATOL)
        @test isapprox(ind.value[end], 9.308500; atol = ATOL)
        # @test length(ind.input) == P  #  no method matching length(::OnlineStats.MovingWindow{...})
        # @test length(ind.value) == P  #  no method matching length(::OnlineStats.MovingWindow{...})
    end
    =#

    @testset "EMA" begin
        ind = EMA{Float64}(period = P)
        fit!(ind, CLOSE_TMPL)
        @test isapprox(ind.value[end-2], 9.319374; atol = ATOL)
        @test isapprox(ind.value[end-1], 9.406100; atol = ATOL)
        @test isapprox(ind.value[end], 9.462662; atol = ATOL)
        @test length(ind.input) == P
        @test length(ind.value) == P
    end

    @testset "SMMA" begin
        @testset "last 3 values" begin
            ind = SMMA{Float64}(period = P)
            fit!(ind, CLOSE_TMPL)
            @test ind.rolling
            @test isapprox(ind.value[end-2], 9.149589; atol = ATOL)
            @test isapprox(ind.value[end-1], 9.203610; atol = ATOL)
            @test isapprox(ind.value[end], 9.243429; atol = ATOL)
            @test length(ind.input) == P
            @test length(ind.value) == P
        end

        @testset "vector" begin
            ind = SMMA{Float64}(period = P)
            calculated = map(v -> push!(ind, v), CLOSE_TMPL)
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
            @test sum(ismissing.(calculated)) == P - 1  # 19
            @test isapprox(calculated[P:end], expected[P:end]; atol = ATOL)
        end
    end

    @testset "RSI" begin
        ind = RSI{Float64}(period = P)
        fit!(ind, CLOSE_TMPL)
        @test isapprox(ind.value[end-2], 57.880437; atol = ATOL)
        @test isapprox(ind.value[end-1], 55.153392; atol = ATOL)
        @test isapprox(ind.value[end], 53.459494; atol = ATOL)
        @test length(ind.input) == P
        @test length(ind.value) == P
    end

    @testset "MeanDev" begin
        ind = MeanDev{Float64}(period = P)
        fit!(ind, CLOSE_TMPL)
        @test isapprox(ind.value[end-2], 0.608949; atol = ATOL)
        @test isapprox(ind.value[end-1], 0.595400; atol = ATOL)
        @test isapprox(ind.value[end], 0.535500; atol = ATOL)
        @test length(ind.input) == P
        @test length(ind.value) == P
    end

    @testset "StdDev" begin
        ind = StdDev{Float64}(period = P)
        fit!(ind, CLOSE_TMPL)
        @test isapprox(ind.value[end-2], 0.800377; atol = ATOL)
        @test isapprox(ind.value[end-1], 0.803828; atol = ATOL)
        @test isapprox(ind.value[end], 0.721424; atol = ATOL)
        @test length(ind.input) == P
        @test length(ind.value) == P
    end

    @testset "ROC" begin
        ind = ROC{Float64}(period = P)
        fit!(ind, CLOSE_TMPL)
        @test isapprox(ind.value[end-2], 30.740740; atol = ATOL)
        @test isapprox(ind.value[end-1], 26.608910; atol = ATOL)
        @test isapprox(ind.value[end], 33.511348; atol = ATOL)
        @test length(ind.input) == P + 1
        @test length(ind.value) == P + 1
    end

    @testset "WMA" begin
        ind = WMA{Float64}(period = P)
        fit!(ind, CLOSE_TMPL)
        @test isapprox(ind.value[end-2], 9.417523; atol = ATOL)
        @test isapprox(ind.value[end-1], 9.527476; atol = ATOL)
        @test isapprox(ind.value[end], 9.605285; atol = ATOL)
        @test length(ind.input) == P
        @test length(ind.value) == P
    end

    @testset "HMA" begin
        ind = HMA{Float64}(period = 20)
        fit!(ind, CLOSE_TMPL)
        @test isapprox(ind.value[end-2], 9.718018; atol = ATOL)
        @test isapprox(ind.value[end-1], 9.940188; atol = ATOL)
        @test isapprox(ind.value[end], 10.104067; atol = ATOL)
        @test length(ind.value) == 20
    end

    @testset "DPO" begin
        ind = DPO{Float64}(period = 20)
        fit!(ind, CLOSE_TMPL)
        @test isapprox(ind.value[end-2], 0.344499; atol = ATOL)
        @test isapprox(ind.value[end-1], 0.116999; atol = ATOL)
        @test isapprox(ind.value[end], 0.011499; atol = ATOL)
        @test length(ind.value) == 20
    end

    @testset "CoppockCurve" begin
        ind = CoppockCurve{Float64}(
            fast_roc_period = 11,
            slow_roc_period = 14,
            wma_period = 10,
        )
        fit!(ind, CLOSE_TMPL)
        @test isapprox(ind.value[end-2], 27.309482; atol = ATOL)
        @test isapprox(ind.value[end-1], 26.109333; atol = ATOL)
        @test isapprox(ind.value[end], 22.941006; atol = ATOL)
        @test length(ind.value) == 10
    end

    @testset "ALMA" begin
        ind = ALMA{Float64}(period = 9, offset = 0.85, sigma = 6.0)
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
        fit!(ind, CLOSE_TMPL)
        @test isapprox(ind.value[end-2], 9.795859; atol = ATOL)
        @test isapprox(ind.value[end-1], 10.121439; atol = ATOL)
        @test isapprox(ind.value[end], 10.257038; atol = ATOL)
        @test length(ind.value) == 9
    end

    @testset_skip "DEMA (buggy - help wanted)" begin
        ind = DEMA{Float64}(period = 20)
        fit!(ind, CLOSE_TMPL)
        @test isapprox(ind.value[end-2], 9.683254; atol = ATOL)
        @test isapprox(ind.value[end-1], 9.813792; atol = ATOL)
        @test isapprox(ind.value[end], 9.882701; atol = ATOL)
        @test length(ind.value) == 20
    end

    @testset_skip "KAMA (buggy - help wanted)" begin
        ind = KAMA{Float64}(
            period = 14,
            fast_ema_constant_period = 2,
            slow_ema_constant_period = 30,
        )
        fit!(ind, CLOSE_TMPL)
        @test isapprox(ind.value[end-2], 8.884374; atol = ATOL)
        @test isapprox(ind.value[end-1], 8.932091; atol = ATOL)
        @test isapprox(ind.value[end], 8.941810; atol = ATOL)
        @test length(ind.input) == 14
        @test length(ind.value) == 14
    end

end