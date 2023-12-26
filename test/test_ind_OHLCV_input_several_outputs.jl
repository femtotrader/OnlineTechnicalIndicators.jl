@testset "OHLC input - several output values" begin

    @testset "SuperTrend" begin
        ind = SuperTrend{OHLCV{Missing,Float64,Float64}}(atr_period = 10, mult = 3)
        @test nobs(ind) == 0
        fit!(ind, V_OHLCV)
        #ind = StatLag(ind, 16)
        #@test nobs(ind) == length(V_OHLCV)

        # @test isapprox(ind[end-15].value, 9.711592; atol=ATOL) # pretty old!
        # @test ind[end-15].trend == Trend.DOWN # pretty old!

        #@test isapprox(value(ind.lag[end-3]).value, 8.110029; atol = ATOL)
        #@test value(ind.lag[end-3]).trend == Trend.UP

        #@test isapprox(value(ind.lag[end-2]).value, 8.488026; atol = ATOL)
        #@test value(ind.lag[end-2]).trend == Trend.UP

        #@test isapprox(value(ind.lag[end-1]).value, 8.488026; atol = ATOL)
        #@test value(ind.lag[end-1]).trend == Trend.UP

        @test isapprox(value(ind).value, 8.488026; atol = ATOL)
        @test value(ind).trend == Trend.UP
    end

end
