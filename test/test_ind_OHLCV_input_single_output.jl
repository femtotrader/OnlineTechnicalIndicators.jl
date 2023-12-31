@testset "OHLC input - single output" begin

    @testset "SMA with input_modifier" begin
        ind = SMA{OHLCV{Missing,Float64,Float64}}(
            period = P,
            input_modifier = ValueExtractor.extract_close,
            input_modifier_return_type = Float64,
        )
        @test nobs(ind) == 0
        ind = StatLag(ind, 3)
        fit!(ind, V_OHLCV)
        @test nobs(ind) == length(V_OHLCV)
        @test isapprox(value(ind.lag[end-2]), 9.075500; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]), 9.183000; atol = ATOL)
        @test isapprox(value(ind), 9.308500; atol = ATOL)
    end

    @testset "AccuDist" begin
        ind = AccuDist{OHLCV{Missing,Float64,Float64},Float64}()
        @test nobs(ind) == 0
        ind = StatLag(ind, 3)
        fit!(ind, V_OHLCV)
        @test nobs(ind) == length(V_OHLCV)
        @test isapprox(value(ind.lag[end-2]), -689.203568; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]), -725.031632; atol = ATOL)
        @test isapprox(value(ind), -726.092152; atol = ATOL)
    end

    @testset "BOP" begin
        ind = BOP{OHLCV{Missing,Float64,Float64},Float64}()
        @test nobs(ind) == 0
        ind = StatLag(ind, 3)
        fit!(ind, V_OHLCV)
        @test nobs(ind) == length(V_OHLCV)
        @test isapprox(value(ind.lag[end-2]), 0.447761; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]), -0.870967; atol = ATOL)
        @test isapprox(value(ind), -0.363636; atol = ATOL)
    end

    @testset "CCI" begin
        ind = CCI{OHLCV{Missing,Float64,Float64},Float64}(period = 20)
        @test nobs(ind) == 0
        ind = StatLag(ind, 3)
        fit!(ind, V_OHLCV)
        @test nobs(ind) == length(V_OHLCV)
        @test isapprox(value(ind.lag[end-2]), 179.169127; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]), 141.667617; atol = ATOL)
        @test isapprox(value(ind), 89.601438; atol = ATOL)
    end

    @testset "ChaikinOsc" begin
        ind = ChaikinOsc{OHLCV{Missing,Float64,Float64},Float64}(
            fast_period = 5,
            slow_period = 7,
        )
        @test nobs(ind) == 0
        ind = StatLag(ind, 3)
        fit!(ind, V_OHLCV)
        @test nobs(ind) == length(V_OHLCV)
        @test isapprox(value(ind.lag[end-2]), 31.280810; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]), 28.688536; atol = ATOL)
        @test isapprox(value(ind), 24.913310; atol = ATOL)
    end

    @testset "VWMA" begin
        ind = VWMA{OHLCV{Missing,Float64,Float64},Float64}(period = P)
        @test nobs(ind) == 0
        ind = StatLag(ind, 3)
        fit!(ind, V_OHLCV)
        @test nobs(ind) == length(V_OHLCV)
        @test isapprox(value(ind.lag[end-2]), 9.320203; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]), 9.352602; atol = ATOL)
        @test isapprox(value(ind), 9.457708; atol = ATOL)
    end

    @testset "VWAP" begin
        ind = VWAP{OHLCV{Missing,Float64,Float64},Float64}()
        @test nobs(ind) == 0
        ind = StatLag(ind, length(V_OHLCV))
        fit!(ind, V_OHLCV)
        @test nobs(ind) == length(V_OHLCV)
        @test isapprox(value(ind.lag[1]), 10.47333; atol = ATOL)
        @test isapprox(value(ind.lag[2]), 10.21883; atol = ATOL)
        @test isapprox(value(ind.lag[3]), 10.20899; atol = ATOL)
        @test isapprox(value(ind.lag[end-2]), 9.125770; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]), 9.136613; atol = ATOL)
        @test isapprox(value(ind), 9.149069; atol = ATOL)
    end

    @testset "AO" begin
        ind = AO{OHLCV{Missing,Float64,Float64},Float64}(fast_period = 5, slow_period = 7)
        @test nobs(ind) == 0
        ind = StatLag(ind, 3)
        fit!(ind, V_OHLCV)
        @test nobs(ind) == length(V_OHLCV)
        @test isapprox(value(ind.lag[end-2]), 0.117142; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]), 0.257142; atol = ATOL)
        @test isapprox(value(ind), 0.373285; atol = ATOL)
    end

    @testset "ATR" begin
        ind = ATR{OHLCV{Missing,Float64,Float64},Float64}(period = 5)
        @test nobs(ind) == 0
        ind = StatLag(ind, 3)
        fit!(ind, V_OHLCV)
        @test nobs(ind) == length(V_OHLCV)
        @test isapprox(value(ind.lag[end-2]), 0.676426; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]), 0.665141, ; atol = ATOL)
        @test isapprox(value(ind), 0.686113; atol = ATOL)
    end

    @testset "ForceIndex" begin
        ind = ForceIndex{OHLCV{Missing,Float64,Float64},Float64}(period = 20)
        @test nobs(ind) == 0
        ind = StatLag(ind, 3)
        fit!(ind, V_OHLCV)
        @test nobs(ind) == length(V_OHLCV)
        @test isapprox(value(ind.lag[end-2]), 24.015092; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]), 20.072283; atol = ATOL)
        @test isapprox(value(ind), 16.371894; atol = ATOL)
    end

    @testset "OBV" begin
        ind = OBV{OHLCV{Missing,Float64,Float64},Float64}()
        @test nobs(ind) == 0
        ind = StatLag(ind, 3)
        fit!(ind, V_OHLCV)
        @test nobs(ind) == length(V_OHLCV)
        @test isapprox(value(ind.lag[end-2]), 665.899999; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]), 617.609999; atol = ATOL)
        @test isapprox(value(ind), 535.949999; atol = ATOL)
    end

    @testset "SOBV" begin
        ind = SOBV{OHLCV{Missing,Float64,Float64},Float64}(period = 20)
        @test nobs(ind) == 0
        ind = StatLag(ind, 3)
        fit!(ind, V_OHLCV)
        @test nobs(ind) == length(V_OHLCV)
        @test isapprox(value(ind.lag[end-2]), 90.868499; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]), 139.166499; atol = ATOL)
        @test isapprox(value(ind), 187.558499; atol = ATOL)
    end

    @testset "EMV" begin
        ind = EMV{OHLCV{Missing,Float64,Float64},Float64}(period = 14, volume_div = 10000)
        @test nobs(ind) == 0
        ind = StatLag(ind, 3)
        fit!(ind, V_OHLCV)
        @test nobs(ind) == length(V_OHLCV)
        @test isapprox(value(ind.lag[end-2]), 5.656780; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]), 5.129971; atol = ATOL)
        @test isapprox(value(ind), -0.192883; atol = ATOL)
    end

    @testset "Stoch" begin
        ind =
            Stoch{OHLCV{Missing,Float64,Float64},Float64}(period = 14, smoothing_period = 3)
        @test nobs(ind) == 0
        ind = StatLag(ind, 3)
        fit!(ind, V_OHLCV)
        @test nobs(ind) == length(V_OHLCV)
        @test isapprox(value(ind.lag[end-2]).k, 88.934426; atol = ATOL)
        @test isapprox(value(ind.lag[end-2]).d, 88.344442; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]).k, 74.180327; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]).d, 84.499789; atol = ATOL)
        @test isapprox(value(ind).k, 64.754098; atol = ATOL)
        @test isapprox(value(ind).d, 75.956284; atol = ATOL)
    end

    @testset "MassIndex" begin
        ind = MassIndex{OHLCV{Missing,Float64,Float64},Float64}(
            ma_period = 9,
            ma_ma_period = 9,
            ma_ratio_period = 10,
        )
        @test nobs(ind) == 0
        ind = StatLag(ind, 3)
        fit!(ind, V_OHLCV)
        @test nobs(ind) == length(V_OHLCV)
        @test isapprox(value(ind.lag[end-2]), 9.498975; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]), 9.537927; atol = ATOL)
        @test isapprox(value(ind), 9.648128; atol = ATOL)
    end

    @testset_skip "CHOP - help wanted" begin
        ind = CHOP{OHLCV{Missing,Float64,Float64},Float64}(period = 14)
        @test nobs(ind) == 0
        ind = StatLag(ind, 3)
        fit!(ind, V_OHLCV)
        @test nobs(ind) == length(V_OHLCV)
        @test isapprox(value(ind.lag[end-2]), 49.835100; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]), 50.001477; atol = ATOL)
        @test isapprox(value(ind), 49.289273; atol = ATOL)
    end

    @testset "KVO" begin
        ind = KVO{OHLCV{Missing,Float64,Float64},Float64}(fast_period = 5, slow_period = 10)
        @test nobs(ind) == 0
        ind = StatLag(ind, 3)
        fit!(ind, V_OHLCV)
        @test nobs(ind) == length(V_OHLCV)
        @test isapprox(value(ind.lag[end-2]), 4540.325257; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]), 535.632479; atol = ATOL)
        @test isapprox(value(ind), -2470.776132; atol = ATOL)
    end

    @testset "UO" begin
        ind = UO{OHLCV{Missing,Float64,Float64},Float64}(
            fast_period = 3,
            mid_period = 5,
            slow_period = 7,
        )
        @test nobs(ind) == 0
        ind = StatLag(ind, 3)
        fit!(ind, V_OHLCV)
        @test nobs(ind) == length(V_OHLCV)
        @test isapprox(value(ind.lag[end-2]), 67.574669; atol = ATOL)
        @test isapprox(value(ind.lag[end-1]), 54.423675; atol = ATOL)
        @test isapprox(value(ind), 47.901125; atol = ATOL)
    end

end
