@testset "single input - several output values" begin

    @testset "BB" begin
        ind = BB{Float64}(period = 5, std_dev_multiplier = 2.0)
        fit!(ind, CLOSE_TMPL)

        @test isapprox(ind.value[end-2].lower, 8.186646; atol = ATOL)
        @test isapprox(ind.value[end-2].central, 9.748000; atol = ATOL)
        @test isapprox(ind.value[end-2].upper, 11.309353; atol = ATOL)

        @test isapprox(ind.value[end-1].lower, 9.161539; atol = ATOL)
        @test isapprox(ind.value[end-1].central, 10.096000; atol = ATOL)
        @test isapprox(ind.value[end-1].upper, 11.030460; atol = ATOL)

        @test isapprox(ind.value[end].lower, 9.863185; atol = ATOL)
        @test isapprox(ind.value[end].central, 10.254000; atol = ATOL)
        @test isapprox(ind.value[end].upper, 10.644814; atol = ATOL)
    end

    @testset_skip "MACD (buggy - help wanted)" begin
        ind = MACD{Float64}(fast_period = 12, slow_period = 26, signal_period = 9)
        fit!(ind, CLOSE_TMPL)

        @test isapprox(ind.value[end-2].macd, 0.293541; atol = ATOL)
        @test isapprox(ind.value[end-2].signal, 0.098639; atol = ATOL)
        @test isapprox(ind.value[end-2].histogram, 0.194901; atol = ATOL)

        @test isapprox(ind.value[end-1].macd, 0.326186; atol = ATOL)
        @test isapprox(ind.value[end-1].signal, 0.144149; atol = ATOL)
        @test isapprox(ind.value[end-1].histogram, 0.182037; atol = ATOL)

        @test isapprox(ind.value[end].macd, 0.329698; atol = ATOL)
        @test isapprox(ind.value[end].signal, 0.181259; atol = ATOL)
        @test isapprox(ind.value[end].histogram, 0.148439; atol = ATOL)

        #@test length(ind.value) == 12
    end

    @testset_skip "KST (buggy - help wanted)" begin
        ind = KST{Float64}(
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
        fit!(ind, CLOSE_TMPL)

        @test isapprox(ind.value[end-2].kst, 136.602283; atol = ATOL)
        @test isapprox(ind.value[end-2].signal, 103.707431; atol = ATOL)

        @test isapprox(ind.value[end-1].kst, 158.252762; atol = ATOL)
        @test isapprox(ind.value[end-1].signal, 113.964023; atol = ATOL)

        @test isapprox(ind.value[end].kst, 155.407034; atol = ATOL)
        @test isapprox(ind.value[end].signal, 122.246497; atol = ATOL)

    end

end
