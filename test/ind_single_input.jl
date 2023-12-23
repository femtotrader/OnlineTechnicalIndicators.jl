@testset "simple indicators" begin  # take only a single value as input

    @testset "single output values" begin
        @testset "SMA" begin
            ind = SMA{Float64}(period=P)
            append!(ind, CLOSE_TMPL)
            @test isapprox(ind.output[end - 2], 9.075500; atol=ATOL)
            @test isapprox(ind.output[end - 1], 9.183000; atol=ATOL)
            @test isapprox(ind.output[end], 9.308500; atol=ATOL)
            @test length(ind.input) == P
            @test length(ind.output) == P
        end

        @testset "SMA_v2" begin
            ind = SMA_v2{Float64}(period=P)
            append!(ind, CLOSE_TMPL)
            @test isapprox(ind.output[end - 2], 9.075500; atol=ATOL)
            @test isapprox(ind.output[end - 1], 9.183000; atol=ATOL)
            @test isapprox(ind.output[end], 9.308500; atol=ATOL)
            @test length(ind.input) == P
            @test length(ind.output) == P
        end

        @testset "SMA_v3" begin
            ind = SMA_v3{Float64}(period=P)
            append!(ind, CLOSE_TMPL)
            @test isapprox(ind.output[end - 2], 9.075500; atol=ATOL)
            @test isapprox(ind.output[end - 1], 9.183000; atol=ATOL)
            @test isapprox(ind.output[end], 9.308500; atol=ATOL)
            # @test length(ind.input) == P  #  no method matching length(::OnlineStats.MovingWindow{...})
            # @test length(ind.output) == P  #  no method matching length(::OnlineStats.MovingWindow{...})
        end

        @testset "EMA" begin
            ind = EMA{Float64}(period=P)
            append!(ind, CLOSE_TMPL)
            @test isapprox(ind.output[end - 2], 9.319374; atol=ATOL)
            @test isapprox(ind.output[end - 1], 9.406100; atol=ATOL)
            @test isapprox(ind.output[end], 9.462662; atol=ATOL)
            @test length(ind.input) == P
            @test length(ind.output) == P
        end

        @testset "SMMA" begin
            @testset "last 3 values" begin
                ind = SMMA{Float64}(period=P)
                append!(ind, CLOSE_TMPL)
                @test ind.rolling
                @test isapprox(ind.output[end - 2], 9.149589; atol=ATOL)
                @test isapprox(ind.output[end - 1], 9.203610; atol=ATOL)
                @test isapprox(ind.output[end], 9.243429; atol=ATOL)
                @test length(ind.input) == P
                @test length(ind.output) == P
            end

            @testset "vector" begin
                ind = SMMA{Float64}(period=P)
                calculated = map(v -> push!(ind, v), CLOSE_TMPL)
                expected = [missing, missing, missing, missing, missing, missing, missing, missing, missing, missing, missing, missing, missing, missing, missing, missing, missing, missing, missing, 9.268500000000001, 9.266075, 9.257771250000001, 9.210382687500001, 9.168363553125001, 9.124945375468752, 9.057698106695314, 9.00731320136055, 8.96194754129252, 8.917850164227895, 8.8464576560165, 8.783134773215675, 8.75247803455489, 8.756354132827147, 8.76403642618579, 8.7858346048765, 8.834542874632675, 8.86381573090104, 8.885624944355989, 8.90734369713819, 8.91397651228128, 8.918277686667215, 8.938863802333856, 8.958920612217163, 8.935474581606305, 8.94920085252599, 9.00924080989969, 9.073778769404708, 9.149589830934472, 9.203610339387748, 9.24342982241836]
                @test sum(ismissing.(calculated)) == P - 1  # 19
                @test isapprox(calculated[P:end], expected[P:end]; atol=ATOL)
            end
        end

        @testset "RSI" begin
            ind = RSI{Float64}(period=P)
            append!(ind, CLOSE_TMPL)
            @test isapprox(ind.output[end - 2], 57.880437; atol=ATOL)
            @test isapprox(ind.output[end - 1], 55.153392; atol=ATOL)
            @test isapprox(ind.output[end], 53.459494; atol=ATOL)
            @test length(ind.input) == P
            @test length(ind.output) == P
        end

        @testset "MeanDev" begin
            ind = MeanDev{Float64}(period=P)
            append!(ind, CLOSE_TMPL)
            @test isapprox(ind.output[end - 2], 0.608949; atol=ATOL)
            @test isapprox(ind.output[end - 1], 0.595400; atol=ATOL)
            @test isapprox(ind.output[end], 0.535500; atol=ATOL)
            @test length(ind.input) == P
            @test length(ind.output) == P
        end

        @testset "StdDev" begin
            ind = StdDev{Float64}(period=P)
            append!(ind, CLOSE_TMPL)
            @test isapprox(ind.output[end - 2], 0.800377; atol=ATOL)
            @test isapprox(ind.output[end - 1], 0.803828; atol=ATOL)
            @test isapprox(ind.output[end], 0.721424; atol=ATOL)
            @test length(ind.input) == P
            @test length(ind.output) == P
        end

        @testset "ROC" begin
            ind = ROC{Float64}(period=P)
            append!(ind, CLOSE_TMPL)
            @test isapprox(ind.output[end - 2], 30.740740; atol=ATOL)
            @test isapprox(ind.output[end - 1], 26.608910; atol=ATOL)
            @test isapprox(ind.output[end], 33.511348; atol=ATOL)
            @test length(ind.input) == P + 1
            @test length(ind.output) == P + 1
        end

        @testset "WMA" begin
            ind = WMA{Float64}(period=P)
            append!(ind, CLOSE_TMPL)
            @test isapprox(ind.output[end - 2], 9.417523; atol=ATOL)
            @test isapprox(ind.output[end - 1], 9.527476; atol=ATOL)
            @test isapprox(ind.output[end], 9.605285; atol=ATOL)
            @test length(ind.input) == P
            @test length(ind.output) == P
        end


        @testset "HMA" begin
            ind = HMA{Float64}(period=20)
            append!(ind, CLOSE_TMPL)
            @test isapprox(ind.output[end - 2], 9.718018; atol=ATOL)
            @test isapprox(ind.output[end - 1], 9.940188; atol=ATOL)
            @test isapprox(ind.output[end], 10.104067; atol=ATOL)
            @test length(ind.output) == 20
        end

        @testset "ALMA" begin
            ind = ALMA{Float64}(period=9, offset=0.85, sigma=6.0)
            w_expected = [0.000335, 0.003865, 0.028565, 0.135335, 0.411112, 0.800737, 1.0, 0.800737, 0.411112]
            for (i, w_expected_val) in enumerate(w_expected)
                @test isapprox(ind.w[i], w_expected_val; atol=ATOL)
            end
            @test isapprox(ind.w_sum, 3.591801; atol=ATOL)
            append!(ind, CLOSE_TMPL)
            @test isapprox(ind.output[end - 2], 9.795859; atol=ATOL)
            @test isapprox(ind.output[end - 1], 10.121439; atol=ATOL)
            @test isapprox(ind.output[end], 10.257038; atol=ATOL)
            @test length(ind.output) == 9
        end

        @testset_skip "DEMA (buggy - help wanted)" begin
            ind = DEMA{Float64}(period=20)
            append!(ind, CLOSE_TMPL)
            @test isapprox(ind.output[end - 2], 9.683254; atol=ATOL)
            @test isapprox(ind.output[end - 1], 9.813792; atol=ATOL)
            @test isapprox(ind.output[end], 9.882701; atol=ATOL)
            @test length(ind.output) == 20
        end

        @testset_skip "KAMA (buggy - help wanted)" begin
            ind = KAMA{Float64}(period=14, fast_ema_constant_period=2, slow_ema_constant_period=30)
            append!(ind, CLOSE_TMPL)
            @test isapprox(ind.output[end - 2], 8.884374; atol=ATOL)
            @test isapprox(ind.output[end - 1], 8.932091; atol=ATOL)
            @test isapprox(ind.output[end], 8.941810; atol=ATOL)
            @test length(ind.input) == 14
            @test length(ind.output) == 14
        end

    end



    @testset "several output values" begin
        @testset "BB" begin
            ind = BB{Float64}(period=5, std_dev_multiplier=2.0)
            append!(ind, CLOSE_TMPL)

            @test isapprox(ind.output[end - 2].lower, 8.186646; atol=ATOL)
            @test isapprox(ind.output[end - 2].central, 9.748000; atol=ATOL)
            @test isapprox(ind.output[end - 2].upper, 11.309353; atol=ATOL)

            @test isapprox(ind.output[end - 1].lower, 9.161539; atol=ATOL)
            @test isapprox(ind.output[end - 1].central, 10.096000; atol=ATOL)
            @test isapprox(ind.output[end - 1].upper, 11.030460; atol=ATOL)

            @test isapprox(ind.output[end].lower, 9.863185; atol=ATOL)
            @test isapprox(ind.output[end].central, 10.254000; atol=ATOL)
            @test isapprox(ind.output[end].upper, 10.644814; atol=ATOL)
        end

        @testset_skip "MACD (buggy - help wanted)" begin
            ind = MACD{Float64}(fast_period=12, slow_period=26, signal_period=9)
            append!(ind, CLOSE_TMPL)

            @test isapprox(ind.output[end - 2].macd, 0.293541; atol=ATOL)
            @test isapprox(ind.output[end - 2].signal, 0.098639; atol=ATOL)
            @test isapprox(ind.output[end - 2].histogram, 0.194901; atol=ATOL)

            @test isapprox(ind.output[end - 1].macd, 0.326186; atol=ATOL)
            @test isapprox(ind.output[end - 1].signal, 0.144149; atol=ATOL)
            @test isapprox(ind.output[end - 1].histogram, 0.182037; atol=ATOL)

            @test isapprox(ind.output[end].macd, 0.329698; atol=ATOL)
            @test isapprox(ind.output[end].signal, 0.181259; atol=ATOL)
            @test isapprox(ind.output[end].histogram, 0.148439; atol=ATOL)         
            
            #@test length(ind.output) == 12
        end

    end
    
end