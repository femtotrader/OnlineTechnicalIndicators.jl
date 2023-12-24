@testset "OHLCV indicators" begin  # take an OHLCV candle as input
    @testset "single output values" begin
        @testset "VWMA" begin
            ind = VWMA{Missing,Float64,Float64}(period = P)
            fit!(ind, V_OHLCV)
            @test isapprox(ind.value[end-2], 9.320203; atol = ATOL)
            @test isapprox(ind.value[end-1], 9.352602; atol = ATOL)
            @test isapprox(ind.value[end], 9.457708; atol = ATOL)
            @test length(ind.input) == P
            @test length(ind.value) == P
        end

        @testset "VWAP" begin
            ind = VWAP{Float64,Float64}(memory = MEMORY)
            fit!(ind, V_OHLCV)
            @test isapprox(ind.value[1], 10.47333; atol = ATOL)
            @test isapprox(ind.value[2], 10.21883; atol = ATOL)
            @test isapprox(ind.value[3], 10.20899; atol = ATOL)
            @test isapprox(ind.value[end-2], 9.125770; atol = ATOL)
            @test isapprox(ind.value[end-1], 9.136613; atol = ATOL)
            @test isapprox(ind.value[end], 9.149069; atol = ATOL)
        end

        @testset "AO" begin
            ind = AO{Float64}(fast_period = 5, slow_period = 7)
            fit!(ind, V_OHLCV)
            @test isapprox(ind.value[end-2], 0.117142; atol = ATOL)
            @test isapprox(ind.value[end-1], 0.257142; atol = ATOL)
            @test isapprox(ind.value[end], 0.373285; atol = ATOL)
            @test length(ind.value) == 7
        end

        @testset "ATR" begin
            ind = ATR{Missing,Float64,Float64}(period = 5)
            fit!(ind, V_OHLCV)
            @test isapprox(ind.value[end-2], 0.676426; atol = ATOL)
            @test isapprox(ind.value[end-1], 0.665141, ; atol = ATOL)
            @test isapprox(ind.value[end], 0.686113; atol = ATOL)
        end

        @testset "AccuDist" begin
            ind = AccuDist{Float64}(memory = 3)
            fit!(ind, V_OHLCV)
            @test isapprox(ind.value[end-2], -689.203568; atol = ATOL)
            @test isapprox(ind.value[end-1], -725.031632; atol = ATOL)
            @test isapprox(ind.value[end], -726.092152; atol = ATOL)
            @test length(ind.value) == 3
        end

        @testset "BOP" begin
            ind = BOP{Float64}(memory = P)
            fit!(ind, V_OHLCV)
            @test isapprox(ind.value[end-2], 0.447761; atol = ATOL)
            @test isapprox(ind.value[end-1], -0.870967; atol = ATOL)
            @test isapprox(ind.value[end], -0.363636; atol = ATOL)
            @test length(ind.value) == P
        end

        @testset "ForceIndex" begin
            ind = ForceIndex{Missing,Float64,Float64}(period = 20)
            fit!(ind, V_OHLCV)
            @test isapprox(ind.value[end-2], 24.015092; atol = ATOL)
            @test isapprox(ind.value[end-1], 20.072283; atol = ATOL)
            @test isapprox(ind.value[end], 16.371894; atol = ATOL)
            @test length(ind.value) == P
        end

        @testset "OBV" begin
            ind = OBV{Missing,Float64,Float64}(memory = 3)
            fit!(ind, V_OHLCV)
            @test isapprox(ind.value[end-2], 665.899999; atol = ATOL)
            @test isapprox(ind.value[end-1], 617.609999; atol = ATOL)
            @test isapprox(ind.value[end], 535.949999; atol = ATOL)
            @test length(ind.value) == 3
        end

        @testset "SOBV" begin
            ind = SOBV{Missing,Float64,Float64}(period = 20)
            fit!(ind, V_OHLCV)
            @test isapprox(ind.value[end-2], 90.868499; atol = ATOL)
            @test isapprox(ind.value[end-1], 139.166499; atol = ATOL)
            @test isapprox(ind.value[end], 187.558499; atol = ATOL)
            @test length(ind.value) == 20
        end

        @testset "EMV" begin
            ind = EMV{Missing,Float64,Float64}(period = 14, volume_div = 10000)
            fit!(ind, V_OHLCV)
            @test isapprox(ind.value[end-2], 5.656780; atol = ATOL)
            @test isapprox(ind.value[end-1], 5.129971; atol = ATOL)
            @test isapprox(ind.value[end], -0.192883; atol = ATOL)
            @test length(ind.value) == 14
        end

        @testset "CCI" begin
            ind = CCI{Float64}(period = 20)
            fit!(ind, V_OHLCV)
            @test isapprox(ind.value[end-2], 179.169127; atol = ATOL)
            @test isapprox(ind.value[end-1], 141.667617; atol = ATOL)
            @test isapprox(ind.value[end], 89.601438; atol = ATOL)
            @test length(ind.value) == P
        end

        @testset "ChaikinOsc" begin
            ind = ChaikinOsc{Float64}(fast_period = 5, slow_period = 7)
            fit!(ind, V_OHLCV)
            @test isapprox(ind.value[end-2], 31.280810; atol = ATOL)
            @test isapprox(ind.value[end-1], 28.688536; atol = ATOL)
            @test isapprox(ind.value[end], 24.913310; atol = ATOL)
            @test length(ind.value) == 5
        end

        @testset_skip "MassIndex - help wanted" begin
            ind = MassIndex{Float64}(
                ema_period = 9,
                ema_ema_period = 9,
                ema_ratio_period = 10,
            )
            fit!(ind, V_OHLCV)
            @test isapprox(ind.value[end-2], 9.498975; atol = ATOL)
            @test isapprox(ind.value[end-1], 9.537927; atol = ATOL)
            @test isapprox(ind.value[end], 9.648128; atol = ATOL)
            @test length(ind.value) == 9
        end

        @testset_skip "CHOP - help wanted" begin
            ind = CHOP{Missing,Float64,Float64}(period = 14)
            fit!(ind, V_OHLCV)
            @test isapprox(ind.value[end-2], 49.835100; atol = ATOL)
            @test isapprox(ind.value[end-1], 50.001477; atol = ATOL)
            @test isapprox(ind.value[end], 49.289273; atol = ATOL)
            @test length(ind.value) == 14
        end

        @testset "Stoch" begin
            ind = Stoch{Missing,Float64,Float64}(period=14, smoothing_period=3)
            fit!(ind, V_OHLCV)
            @test isapprox(ind.value[end-2].k, 88.934426; atol=ATOL)
            @test isapprox(ind.value[end-2].d, 88.344442; atol=ATOL)
            @test isapprox(ind.value[end-1].k, 74.180327; atol=ATOL)
            @test isapprox(ind.value[end-1].d, 84.499789; atol=ATOL)
            @test isapprox(ind.value[end].k, 64.754098; atol=ATOL)
            @test isapprox(ind.value[end].d, 75.956284; atol=ATOL)
            @test length(ind.value) == 14
        end
    end

    @testset "several output values" begin
        @testset "SuperTrend" begin
            ind = SuperTrend{Missing,Float64,Float64}(atr_period = 10, mult = 3)
            fit!(ind, V_OHLCV)
            # @test isapprox(ind.value[end - 15].value, 9.711592; atol=ATOL) # pretty old!
            # @test ind.value[end - 15].trend == Trend.DOWN # pretty old!

            @test isapprox(ind.value[end-3].value, 8.110029; atol = ATOL)
            @test ind.value[end-3].trend == Trend.UP

            @test isapprox(ind.value[end-2].value, 8.488026; atol = ATOL)
            @test ind.value[end-2].trend == Trend.UP

            @test isapprox(ind.value[end-1].value, 8.488026; atol = ATOL)
            @test ind.value[end-1].trend == Trend.UP

            @test isapprox(ind.value[end].value, 8.488026; atol = ATOL)
            @test ind.value[end].trend == Trend.UP

            @test length(ind.value) == 10
        end

    end

end
