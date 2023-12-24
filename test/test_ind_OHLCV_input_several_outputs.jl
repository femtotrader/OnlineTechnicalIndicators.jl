
@testset "OHLC input - several output values" begin

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
