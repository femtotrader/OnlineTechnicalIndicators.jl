using IncTA
using Test

const CLOSE_TMPL = [10.5, 9.78, 10.46, 10.51, 10.55, 10.72, 10.16, 10.25, 9.4, 9.5, 9.23, 8.5, 8.8, 8.33, 7.53, 7.61, 6.78, 8.6, 9.21, 8.95, 9.22, 9.1, 8.31, 8.37, 8.3, 7.78, 8.05, 8.1, 8.08, 7.49, 7.58, 8.17, 8.83, 8.91, 9.2, 9.76, 9.42, 9.3, 9.32, 9.04, 9.0, 9.33, 9.34, 8.49, 9.21, 10.15, 10.3, 10.59, 10.23, 10.0]

@testset "IncTA.jl" begin
    # Write your tests here.

    @testset "SMA" begin
        ind = SMA{Float64}(20)
        append!(ind, CLOSE_TMPL)
        @test isapprox(ind.output[end - 2], 9.075500; atol=0.00001)
        @test isapprox(ind.output[end - 1], 9.183000; atol=0.00001)
        @test isapprox(ind.output[end], 9.308500; atol=0.00001)
    end

    @testset "EMA" begin
        ind = EMA{Float64}(20)
        append!(ind, CLOSE_TMPL)
        @test isapprox(ind.output[end - 2], 9.319374; atol=0.00001)
        @test isapprox(ind.output[end - 1], 9.406100; atol=0.00001)
        @test isapprox(ind.output[end], 9.462662; atol=0.00001)
    end

end
