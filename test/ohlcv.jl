@testset "ohlcv" begin

    @testset "OHLCV with volume but missing time" begin
        ohlcv = OHLCV(10.81, 11.02, 9.9, 10.5; volume=55.03)
        @test ohlcv.open == 10.81
        @test ohlcv.high == 11.02
        @test ohlcv.low == 9.9
        @test ohlcv.close == 10.5
        @test ohlcv.volume == 55.03
        @test ismissing(ohlcv.time)
    end

    @testset "OHLCV factory" begin
        ohlcv_factory = OHLCVFactory(OPEN_TMPL, HIGH_TMPL, LOW_TMPL, CLOSE_TMPL; volume=VOLUME_TMPL)  # time is missing here
        v_ohlcv = collect(ohlcv_factory)
        @test length(v_ohlcv) == length(CLOSE_TMPL)
        @test eltype(v_ohlcv) == OHLCV{Missing, Float64, Float64}
    end

end
