using IncTA
using Test

const P = 20  # default period
const ATOL = 0.00001  # default absolute tolerance

const OPEN_TMPL = [10.81, 10.58, 10.07, 10.58, 10.56, 10.4, 10.74, 10.16, 10.29, 9.4, 9.62, 9.35, 8.64, 8.8, 8.31, 7.56, 7.61, 7.04, 8.56, 9.26, 8.95, 9.31, 9.1, 8.51, 8.42, 8.3, 7.87, 7.94, 8.1, 8.08, 7.49, 7.4, 8.09, 8.86, 8.81, 9.16, 9.69, 9.45, 9.18, 9.4, 9.0, 9.11, 9.23, 9.34, 8.49, 9.3, 10.23, 10.29, 10.77, 10.28]
const HIGH_TMPL = [11.02, 10.74, 10.65, 11.05, 10.7, 10.73, 11.16, 10.86, 10.29, 10.8, 9.62, 9.35, 9.43, 8.91, 8.84, 7.82, 7.61, 8.84, 9.42, 9.5, 9.29, 9.4, 9.1, 8.51, 8.95, 8.7, 8.95, 8.75, 8.39, 8.28, 7.58, 8.17, 8.83, 9.2, 9.25, 10.1, 9.88, 9.65, 9.32, 9.4, 9.01, 9.36, 9.46, 9.34, 9.4, 10.5, 10.3, 10.86, 10.77, 10.39]
const LOW_TMPL = [9.9, 9.78, 9.5, 10.47, 10.26, 10.4, 10.12, 9.91, 9.4, 9.11, 9.12, 8.5, 8.55, 8.21, 7.34, 7.53, 6.5, 7.04, 8.15, 8.72, 8.6, 8.89, 8.14, 8.24, 8.06, 7.7, 7.87, 7.94, 8.0, 7.37, 7.49, 7.38, 8.05, 8.79, 8.67, 9.16, 8.9, 9.17, 8.6, 8.92, 8.99, 9.11, 9.11, 8.43, 8.42, 9.26, 10.0, 10.19, 10.15, 9.62]
const CLOSE_TMPL = [10.5, 9.78, 10.46, 10.51, 10.55, 10.72, 10.16, 10.25, 9.4, 9.5, 9.23, 8.5, 8.8, 8.33, 7.53, 7.61, 6.78, 8.6, 9.21, 8.95, 9.22, 9.1, 8.31, 8.37, 8.3, 7.78, 8.05, 8.1, 8.08, 7.49, 7.58, 8.17, 8.83, 8.91, 9.2, 9.76, 9.42, 9.3, 9.32, 9.04, 9.0, 9.33, 9.34, 8.49, 9.21, 10.15, 10.3, 10.59, 10.23, 10.0]

const VOLUME_TMPL = [55.03, 117.86, 301.04, 157.94, 39.96, 42.87, 191.95, 55.09, 131.58, 249.69, 77.75, 197.33, 107.93, 35.86, 269.05, 34.18, 209.1, 241.95, 162.86, 112.99, 66.53, 87.5, 349.14, 44.38, 45.79, 139.4, 46.49, 27.45, 16.44, 83.54, 15.08, 60.72, 140.22, 171.6, 209.26, 199.2, 165.77, 61.71, 29.73, 12.93, 4.14, 12.45, 42.23, 133.29, 120.02, 255.3, 111.55, 108.27, 48.29, 81.66]

const CLOSE_EQUAL_VALUES_TMPL = [10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46, 10.46]

const OHLCV_FACTORY = OHLCVFactory(OPEN_TMPL, HIGH_TMPL, LOW_TMPL, CLOSE_TMPL; volume=VOLUME_TMPL)  # time is missing here
V_OHLCV = collect(OHLCV_FACTORY)


const MEMORY = length(CLOSE_TMPL)  # 50


import Test: Test, finish
using Test: DefaultTestSet, Broken
using Test: parse_testset_args

"""
Skip a testset

Use `@testset_skip` to replace `@testset` for some tests which should be skipped.

Usage
-----
Replace `@testset` with `@testset "reason"` where `"reason"` is a string saying why the
test should be skipped (which should come before the description string, if that is
present).
"""
macro testset_skip(args...)
    isempty(args) && error("No arguments to @testset_skip")
    length(args) < 2 && error("First argument to @testset_skip giving reason for "
                              * "skipping is required")

    skip_reason = args[1]

    desc, testsettype, options = parse_testset_args(args[2:end-1])

    ex = quote
        # record the reason for the skip in the description, and mark the tests as
        # broken, but don't run tests
        local ts = DefaultTestSet(string($desc, " - ", $skip_reason))
        push!(ts.results, Broken(:skipped, "skipped tests"))
        local ret = finish(ts)
        ret
    end

    return ex
end


@testset "IncTA.jl" begin
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

    @testset "indicators" begin
        @testset "simple indicators" begin
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

            @testset_skip "KAMA (buggy - help wanted)" begin
                ind = KAMA{Float64}(period=14, fast_ema_constant_period=2, slow_ema_constant_period=30)
                append!(ind, CLOSE_TMPL)
                @test isapprox(ind.output[end - 2], 8.884374; atol=ATOL)
                @test isapprox(ind.output[end - 1], 8.932091; atol=ATOL)
                @test isapprox(ind.output[end], 8.941810; atol=ATOL)
                @test length(ind.input) == 14
                @test length(ind.output) == 14
            end

            @testset "HMA" begin
                ind = HMA{Float64}(period=20)
                append!(ind, CLOSE_TMPL)
                @test isapprox(ind.output[end - 2], 9.718018; atol=ATOL)
                @test isapprox(ind.output[end - 1], 9.940188; atol=ATOL)
                @test isapprox(ind.output[end], 10.104067; atol=ATOL)
                @test length(ind.output) == 20
            end
            
        end

        @testset "OHLCV indicators" begin
            @testset "VWMA" begin
                ind = VWMA{Missing, Float64, Float64}(period=P)
                append!(ind, V_OHLCV)
                @test isapprox(ind.output[end - 2], 9.320203; atol=ATOL)
                @test isapprox(ind.output[end - 1], 9.352602; atol=ATOL)
                @test isapprox(ind.output[end], 9.457708; atol=ATOL)
                @test length(ind.input) == P
                @test length(ind.output) == P    
            end

            @testset "VWAP" begin
                ind = VWAP{Float64, Float64}(memory=MEMORY)
                append!(ind, V_OHLCV)
                @test isapprox(ind.output[1], 10.47333; atol=ATOL)
                @test isapprox(ind.output[2], 10.21883; atol=ATOL)
                @test isapprox(ind.output[3], 10.20899; atol=ATOL)
                @test isapprox(ind.output[end - 2], 9.125770; atol=ATOL)
                @test isapprox(ind.output[end - 1], 9.136613; atol=ATOL)
                @test isapprox(ind.output[end], 9.149069; atol=ATOL)
            end

            @testset "AO" begin
                ind = AO{Float64}(fast_period=5, slow_period=7)
                append!(ind, V_OHLCV)
                @test isapprox(ind.output[end - 2], 0.117142; atol=ATOL)
                @test isapprox(ind.output[end - 1], 0.257142; atol=ATOL)
                @test isapprox(ind.output[end], 0.373285; atol=ATOL)
                @test length(ind.output) == 7
            end

            @testset "ATR" begin
                ind = ATR{Missing, Float64, Float64}(period=5)
                append!(ind, V_OHLCV)
                @test isapprox(ind.output[end - 2], 0.676426; atol=ATOL)
                @test isapprox(ind.output[end - 1], 0.665141,; atol=ATOL)
                @test isapprox(ind.output[end], 0.686113; atol=ATOL)
            end

            @testset "AccuDist" begin
                ind = AccuDist{Float64}(memory=3)
                append!(ind, V_OHLCV)
                @test isapprox(ind.output[end - 2], -689.203568; atol=ATOL)
                @test isapprox(ind.output[end - 1], -725.031632; atol=ATOL)
                @test isapprox(ind.output[end], -726.092152; atol=ATOL)
                @test length(ind.output) == 3
            end

            @testset "BOP" begin
                ind = BOP{Float64}(memory=P)
                append!(ind, V_OHLCV)
                @test isapprox(ind.output[end - 2], 0.447761; atol=ATOL)
                @test isapprox(ind.output[end - 1], -0.870967; atol=ATOL)
                @test isapprox(ind.output[end], -0.363636; atol=ATOL)
                @test length(ind.output) == P
            end            

            @testset "ForceIndex" begin
                ind = ForceIndex{Missing, Float64, Float64}(period=20)
                append!(ind, V_OHLCV)
                @test isapprox(ind.output[end - 2], 24.015092; atol=ATOL)
                @test isapprox(ind.output[end - 1], 20.072283; atol=ATOL)
                @test isapprox(ind.output[end], 16.371894; atol=ATOL)
                @test length(ind.output) == P
            end

            @testset "OBV" begin
                ind = OBV{Missing, Float64, Float64}(memory=3)
                append!(ind, V_OHLCV)
                @test isapprox(ind.output[end - 2], 665.899999; atol=ATOL)
                @test isapprox(ind.output[end - 1], 617.609999; atol=ATOL)
                @test isapprox(ind.output[end], 535.949999; atol=ATOL)
                @test length(ind.output) == 3
            end

            @testset "CCI" begin
                ind = CCI{Float64}(period=20)
                append!(ind, V_OHLCV)
                @test isapprox(ind.output[end - 2], 179.169127; atol=ATOL)
                @test isapprox(ind.output[end - 1], 141.667617; atol=ATOL)
                @test isapprox(ind.output[end], 89.601438; atol=ATOL)
                @test length(ind.output) == P
            end

            @testset_skip "MassIndex - help wanted" begin
                ind = MassIndex{Float64}(ema_period=9, ema_ema_period=9, ema_ratio_period=10)
                append!(ind, V_OHLCV)
                @test isapprox(ind.output[end - 2], 9.498975; atol=ATOL)
                @test isapprox(ind.output[end - 1], 9.537927; atol=ATOL)
                @test isapprox(ind.output[end], 9.648128; atol=ATOL)
                @test length(ind.output) == 9
            end
            
        end


    end

end
