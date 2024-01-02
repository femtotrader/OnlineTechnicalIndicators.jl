using IncTA: PivotsHLVal

@testset "OHLC input - several output values" begin

    @testset "SuperTrend" begin
        ind = SuperTrend{OHLCV{Missing,Float64,Float64},Float64}(atr_period = 10, mult = 3)
        @test nobs(ind) == 0
        ind = StatLag(ind, 16)
        fit!(ind, V_OHLCV)
        @test nobs(ind) == length(V_OHLCV)

        @test isapprox(value(ind.lag[1]).value, 9.711592; atol = ATOL) # pretty old! (end-15=1)
        @test value(ind.lag[1]).trend == Trend.DOWN # pretty old!

        @test isapprox(value(ind.lag[end-3]).value, 8.110029; atol = ATOL)
        @test value(ind.lag[end-3]).trend == Trend.UP

        @test isapprox(value(ind.lag[end-2]).value, 8.488026; atol = ATOL)
        @test value(ind.lag[end-2]).trend == Trend.UP

        @test isapprox(value(ind.lag[end-1]).value, 8.488026; atol = ATOL)
        @test value(ind.lag[end-1]).trend == Trend.UP

        @test isapprox(value(ind).value, 8.488026; atol = ATOL)
        @test value(ind).trend == Trend.UP
    end

    @testset "VTX" begin
        ind = VTX{OHLCV{Missing,Float64,Float64},Float64}(period = 14)
        @test nobs(ind) == 0
        ind = StatLag(ind, 3)
        fit!(ind, V_OHLCV)
        @test nobs(ind) == length(V_OHLCV)

        @test isapprox(value(ind.lag[end-2]).plus_vtx, 1.133113; atol = ATOL)
        @test isapprox(value(ind.lag[end-2]).minus_vtx, 0.818481; atol = ATOL)

        @test isapprox(value(ind.lag[end-1]).plus_vtx, 1.141292; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]).minus_vtx, 0.834611; atol = ATOL)

        @test isapprox(value(ind).plus_vtx, 1.030133; atol = ATOL)
        @test isapprox(value(ind).minus_vtx, 0.968750; atol = ATOL)
    end

    @testset "DonchianChannels" begin
        ind = DonchianChannels{OHLCV{Missing,Float64,Float64},Float64}(period = 5)
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

    @testset "KeltnerChannels" begin
        ind = KeltnerChannels{OHLCV{Missing,Float64,Float64},Float64}(
            ma_period = 10,
            atr_period = 10,
            atr_mult_up = 2,
            atr_mult_down = 3,
        )

        @test nobs(ind) == 0
        ind = StatLag(ind, 3)
        fit!(ind, V_OHLCV)
        @test nobs(ind) == length(V_OHLCV)

        @test isapprox(value(ind.lag[end-2]).lower, 7.606912; atol = ATOL)
        @test isapprox(value(ind.lag[end-2]).central, 9.643885; atol = ATOL)
        @test isapprox(value(ind.lag[end-2]).upper, 11.001867; atol = ATOL)

        @test isapprox(value(ind.lag[end-1]).lower, 7.731176; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]).central, 9.750451; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]).upper, 11.096635; atol = ATOL)

        @test isapprox(value(ind).lower, 7.747476; atol = ATOL)
        @test isapprox(value(ind).central, 9.795824; atol = ATOL)
        @test isapprox(value(ind).upper, 11.161389; atol = ATOL)

    end

    @testset "ADX" begin
        ind = ADX{OHLCV{Missing,Float64,Float64},Float64}(di_period = 14, adx_period = 14)
        ind = StatLag(ind, 3)
        @test nobs(ind) == 0
        fit!(ind, V_OHLCV)
        @test nobs(ind) == length(V_OHLCV)

        @test isapprox(value(ind.lag[end-2]).adx, 15.734865; atol = ATOL)
        @test isapprox(value(ind.lag[end-2]).plus_di, 33.236743; atol = ATOL)
        @test isapprox(value(ind.lag[end-2]).minus_di, 17.415377; atol = ATOL)

        @test isapprox(value(ind.lag[end-1]).adx, 16.761395; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]).plus_di, 31.116720; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]).minus_di, 16.716048; atol = ATOL)

        @test isapprox(value(ind).adx, 16.698475; atol = ATOL)
        @test isapprox(value(ind).plus_di, 28.670782; atol = ATOL)
        @test isapprox(value(ind).minus_di, 20.812570; atol = ATOL)
    end

    @testset "Aroon" begin
        ind = Aroon{OHLCV{Missing,Float64,Float64},Float64}(period = 10)
        ind = StatLag(ind, 3)
        @test nobs(ind) == 0
        fit!(ind, V_OHLCV)
        @test nobs(ind) == length(V_OHLCV)

        @test isapprox(value(ind.lag[end-2]).up, 100.0; atol = ATOL)
        @test isapprox(value(ind.lag[end-2]).down, 70.0; atol = ATOL)

        @test isapprox(value(ind.lag[end-1]).up, 90.0; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]).down, 60.0; atol = ATOL)

        @test isapprox(value(ind).up, 80.0; atol = ATOL)
        @test isapprox(value(ind).down, 50.0; atol = ATOL)
    end

    @testset "ChandeKrollStop" begin
        ind = ChandeKrollStop{OHLCV{Missing,Float64,Float64},Float64}(
            atr_period = 5,
            atr_mult = 2.0,
            period = 3,
        )
        ind = StatLag(ind, 3)
        @test nobs(ind) == 0
        fit!(ind, V_OHLCV)
        @test nobs(ind) == length(V_OHLCV)

        @test isapprox(value(ind.lag[end-2]).short_stop, 9.507146; atol = ATOL)
        @test isapprox(value(ind.lag[end-2]).long_stop, 9.772853; atol = ATOL)

        @test isapprox(value(ind.lag[end-1]).short_stop, 9.529717; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]).long_stop, 9.750282; atol = ATOL)

        @test isapprox(value(ind).short_stop, 9.529717; atol = ATOL)
        @test isapprox(value(ind).long_stop, 9.750282; atol = ATOL)
    end

    @testset "ParabolicSAR" begin
        ind = ParabolicSAR{OHLCV{Missing,Float64,Float64},Float64}(
            init_accel_factor = 0.02,
            accel_factor_inc = 0.02,
            max_accel_factor = 0.2,
        )
        ind = StatLag(ind, 3)
        @test nobs(ind) == 0
        fit!(ind, V_OHLCV)
        @test nobs(ind) == length(V_OHLCV)

        @test isapprox(value(ind.lag[end-2]).value, 8.075630; atol = ATOL)
        @test value(ind.lag[end-2]).trend == SARTrend.UP
        @test isapprox(value(ind.lag[end-2]).ep, 10.860000; atol = ATOL)
        @test isapprox(value(ind.lag[end-2]).accel_factor, 0.060000; atol = ATOL)

        @test isapprox(value(ind.lag[end-1]).value, 8.242693; atol = ATOL)
        @test value(ind.lag[end-1]).trend == SARTrend.UP
        @test isapprox(value(ind.lag[end-1]).ep, 10.860000; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]).accel_factor, 0.060000; atol = ATOL)

        @test isapprox(value(ind).value, 8.399731; atol = ATOL)
        @test value(ind).trend == SARTrend.UP
        @test isapprox(value(ind).ep, 10.860000; atol = ATOL)
        @test isapprox(value(ind).accel_factor, 0.060000; atol = ATOL)
    end

    @testset "SFX" begin
        ind = SFX{OHLCV{Missing,Float64,Float64},Float64}(
            atr_period = 12,
            std_dev_period = 12,
            std_dev_smoothing_period = 3,
        )
        ind = StatLag(ind, 3)
        @test nobs(ind) == 0
        fit!(ind, V_OHLCV)
        @test nobs(ind) == length(V_OHLCV)

        @test isapprox(value(ind.lag[end-2]).atr, 0.689106; atol = ATOL)
        @test isapprox(value(ind.lag[end-2]).std_dev, 0.572132; atol = ATOL)
        @test isapprox(value(ind.lag[end-2]).ma_std_dev, 0.476715; atol = ATOL)

        @test isapprox(value(ind.lag[end-1]).atr, 0.683347; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]).std_dev, 0.610239; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]).ma_std_dev, 0.551638; atol = ATOL)

        @test isapprox(value(ind).atr, 0.690568; atol = ATOL)
        @test isapprox(value(ind).std_dev, 0.619332; atol = ATOL)
        @test isapprox(value(ind).ma_std_dev, 0.600567; atol = ATOL)
    end

    @testset "TTM" begin
        ind = TTM{OHLCV{Missing,Float64,Float64},Float64}(
            period = 20,
            bb_std_dev_mult = 2.0,
            kc_atr_mult = 2.0,
        )
        ind = StatLag(ind, 12)
        @test nobs(ind) == 0
        fit!(ind, V_OHLCV)
        @test nobs(ind) == length(V_OHLCV)

        @test value(ind.lag[end-12+1]).squeeze
        @test isapprox(value(ind.lag[end-12+1]).histogram, 0.778771; atol = ATOL)

        @test !value(ind.lag[end-2]).squeeze
        @test isapprox(value(ind.lag[end-2]).histogram, 1.135782; atol = ATOL)

        @test !value(ind.lag[end-1]).squeeze
        @test isapprox(value(ind.lag[end-1]).histogram, 1.136939; atol = ATOL)

        @test !value(ind).squeeze
        @test isapprox(value(ind).histogram, 1.036864; atol = ATOL)
    end

    @testset "PivotsHL" begin
        ind = PivotsHL{OHLCV{Missing,Float64,Float64},Float64}(
            high_period = 7,
            low_period = 7,
        )
        @test nobs(ind) == 0

        # be aware that this indicator behave a bit differently than other ones !

        #pivots = PivotsHLVal[]
        #for candle in V_OHLCV
        #    fit!(ind, candle)
        #    #val = value(ind)
        #    #if !ismissing(val) && val.isnew
        #    #    push!(pivots, value(ind))
        #    #end
        #end
        fit!(ind, V_OHLCV)
        @test nobs(ind) == length(V_OHLCV)

        # println(ind.output_values)
        @test length(ind.output_values) == 9

        @test isapprox(ind.output_values[end-2].ohlcv.open, 9.160000; atol = ATOL)
        @test isapprox(ind.output_values[end-2].ohlcv.high, 10.10000; atol = ATOL)
        @test isapprox(ind.output_values[end-2].ohlcv.low, 9.160000; atol = ATOL)
        @test isapprox(ind.output_values[end-2].ohlcv.close, 9.760000; atol = ATOL)
        @test isapprox(ind.output_values[end-2].ohlcv.volume, 199.200000; atol = ATOL)
        @test ind.output_values[end-2].type == HLType.HIGH

        @test isapprox(ind.output_values[end-1].ohlcv.open, 8.490000; atol = ATOL)
        @test isapprox(ind.output_values[end-1].ohlcv.high, 9.400000; atol = ATOL)
        @test isapprox(ind.output_values[end-1].ohlcv.low, 8.420000; atol = ATOL)
        @test isapprox(ind.output_values[end-1].ohlcv.close, 9.210000; atol = ATOL)
        @test isapprox(ind.output_values[end-1].ohlcv.volume, 120.020000; atol = ATOL)
        @test ind.output_values[end-1].type == HLType.LOW

        @test isapprox(ind.output_values[end].ohlcv.open, 10.290000; atol = ATOL)
        @test isapprox(ind.output_values[end].ohlcv.high, 10.860000; atol = ATOL)
        @test isapprox(ind.output_values[end].ohlcv.low, 10.190000; atol = ATOL)
        @test isapprox(ind.output_values[end].ohlcv.close, 10.590000; atol = ATOL)
        @test isapprox(ind.output_values[end].ohlcv.volume, 108.270000; atol = ATOL)
        @test ind.output_values[end].type == HLType.HIGH
    end

end
