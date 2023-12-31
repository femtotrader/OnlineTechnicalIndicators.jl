@testset "interfaces" begin
    files = readdir("../src/indicators")
    @test length(files) == 51  # number of indicators

    using IncTA: TechnicalIndicator

    _exported = names(IncTA)

    for file in files
        stem, suffix = splitext(file)

        @testset "interface `$(stem)`" begin
            @test suffix == ".jl"  # only .jl files should be in this directory
            
            # each file should have a struct with the exact same name that the .jl file
            @test Symbol(stem) in _exported

            O = eval(Meta.parse(stem))
            # OnlineStatsBase interface
            ## each indicator should have a `value` field
            hasfield(O, :value)
            ## each indicator should have a `n` field
            @test hasfield(O, :n)
          
            @test fieldtype(O, :n) == Int
            # TechnicalIndicator
            ## Filter/Transform : each indicator should have `input_filter` (`Function`), `input_modifier` (`Function`)
            #@test hasfield(O, :input_filter)
            @test fieldtype(O, :input_filter) == Function
            #@test hasfield(O, :input_modifier)
            @test fieldtype(O, :input_modifier) == Function
            ## Chaining : each indicator should have an `output_listeners` field (`Series`) and `input_indicator` (`Union{Missing,TechnicalIndicator}`)
            @test fieldtype(O, :output_listeners) == Series
            @test fieldtype(O, :input_indicator) == Union{Missing,TechnicalIndicator}
        end
    end
end
