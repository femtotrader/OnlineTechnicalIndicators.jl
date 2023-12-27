@testset "OHLC input - several output values" begin

    @testset_skip "SuperTrend" begin
        ind = SuperTrend{OHLCV{Missing,Float64,Float64},Float64}(atr_period = 10, mult = 3)
        @test nobs(ind) == 0
        #ind = StatLag(ind, 16)
        fit!(ind, V_OHLCV)
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

    @testset_skip "VTX" begin
        ind = VTX{OHLCV{Missing,Float64,Float64},Float64}(period = 14)
        @test nobs(ind) == 0
        ind = StatLag(ind, 3)
        fit!(ind, V_OHLCV)
        @test nobs(ind) == 14

        @test isapprox(value(ind.lag[end-2]).plus_vtx, 1.133113; atol = ATOL)
        @test isapprox(value(ind.lag[end-2]).minus_vtx, 0.818481; atol = ATOL)

        @test isapprox(value(ind.lag[end-1]).plus_vtx, 1.141292; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]).minus_vtx, 0.834611; atol = ATOL)

        @test isapprox(value(ind).plus_vtx, 1.030133; atol = ATOL)
        @test isapprox(value(ind).minus_vtx, 0.968750; atol = ATOL)
    end

    @testset "DonchianChannels" begin
        ind = DonchianChannels{OHLCV{Missing,Float64,Float64},Float64}(
            period = 5,
        )
        @test nobs(ind) == 0
        ind = StatLag(ind, 3)
        fit!(ind, V_OHLCV)
        @test nobs(ind) == length(V_OHLCV)

        @test isapprox(value(ind.lag[end-2]).lower, 8.420000; atol = ATOL)
        @test isapprox(value(ind.lag[end-2]).central, 9.640000; atol = ATOL)
        @test isapprox(value(ind.lag[end-2]).upper, 10.860000; atol = ATOL)

        @test isapprox(value(ind.lag[end-1]).lower, 8.420000; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]).central, 9.640000; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]).upper, 10.860000; atol = ATOL)

        @test isapprox(value(ind).lower, 9.260000; atol = ATOL)
        @test isapprox(value(ind).central, 10.059999; atol = ATOL)
        @test isapprox(value(ind).upper, 10.860000; atol = ATOL)
    end

end
