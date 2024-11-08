using OnlineTechnicalIndicators:
    TechnicalIndicator,
    SISO_INDICATORS,
    SIMO_INDICATORS,
    MISO_INDICATORS,
    MIMO_INDICATORS,
    OTHERS_INDICATORS,
    ALL_INDICATORS
using OnlineTechnicalIndicators: always_true, ismultiinput, ismultioutput
using OnlineTechnicalIndicators: MACDVal, macd_to_ohlcv
using OnlineTechnicalIndicators.SampleData: RT_OHLCV, TAB_OHLCV

@testset "indicators interface" begin

    @testset "unified interface" begin
        files = readdir("../src/indicators")
        @test length(files) == 54  # number of indicators

        _exported = names(OnlineTechnicalIndicators)

        for file in files
            stem, suffix = splitext(file)

            @testset "interface `$(stem)`" begin
                @test suffix == ".jl"  # only .jl files should be in this directory

                # each file should have a struct with the exact same name that the .jl file
                @test Symbol(stem) in _exported

                # type DataType from stem (String)
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


    @testset "expected_return_type / SI or MO" begin
        @testset "SISO" begin
            for IND in SISO_INDICATORS
                @testset "$(IND)" begin
                    IND = eval(Meta.parse(IND))
                    @test !ismultiinput(IND)
                    @test !ismultioutput(IND)
                    ind = IND{Float64}()
                    @test expected_return_type(ind) == Float64
                end
            end
        end

        @testset "SIMO" begin
            for IND in SIMO_INDICATORS
                @testset "$(IND)" begin
                    IND = eval(Meta.parse(IND))
                    @test !ismultiinput(IND)
                    @test ismultioutput(IND)
                    ind = IND{Float64}()
                    # @test expected_return_type(ind) == ...  # see in others tests
                end
            end
        end

        @testset "MISO" begin
            for IND in MISO_INDICATORS
                @testset "$(IND)" begin
                    IND = eval(Meta.parse(IND))
                    @test ismultiinput(IND)
                    @test !ismultioutput(IND)
                    ind = IND{OHLCV{Missing,Float64,Float64}}()
                    @test expected_return_type(ind) == Float64
                end
            end
        end

        @testset "MIMO" begin
            for IND in MIMO_INDICATORS
                @testset "$(IND)" begin
                    IND = eval(Meta.parse(IND))
                    @test ismultiinput(IND)
                    @test ismultioutput(IND)
                    ind = IND{OHLCV{Missing,Float64,Float64}}()
                    # @test expected_return_type(ind) == ...  # see in others tests
                end
            end
        end

        @testset "Others" begin
            @testset "STC" begin
                ind = STC{Float64}()  # SISO
                @test !ismultiinput(STC)
                @test !ismultioutput(STC)
                @test expected_return_type(ind) == Float64
            end
        end

    end



    @testset "input filter/modifier" begin
        @testset "SISO" begin
            # SISO indicator with OHLCV input but with an input_modifier which extract close value
            for IND in SISO_INDICATORS
                @testset "$(IND)" begin
                    IND = eval(Meta.parse(IND))
                    ind = IND{OHLCV{Missing,Float64,Float64}}(
                        input_filter = always_true,
                        input_modifier = ValueExtractor.extract_close,
                        input_modifier_return_type = Float64,
                    )
                    candle = OHLCV(2.0, 4.0, 1.0, 3.0)
                    @test ind.input_filter(candle) == true
                    @test ind.input_modifier(candle) == 3.0
                    fit!(ind, V_OHLCV)
                    @test 1 == 1
                end
            end
        end
        @testset "SIMO" begin
            # SIMO indicator with OHLCV input but with an input_modifier which extract close value
            for IND in SIMO_INDICATORS
                @testset "$(IND)" begin
                    IND = eval(Meta.parse(IND))
                    ind = IND{OHLCV{Missing,Float64,Float64}}(
                        input_filter = always_true,
                        input_modifier = ValueExtractor.extract_close,
                        input_modifier_return_type = Float64,
                    )
                    candle = OHLCV(2.0, 4.0, 1.0, 3.0)
                    @test ind.input_filter(candle) == true
                    @test ind.input_modifier(candle) == 3.0
                    fit!(ind, V_OHLCV)
                    @test 1 == 1
                end
            end
        end
        @testset "MISO" begin
            # MISO indicator with MACDVal input but with an input_modifier which return OHLCV from MACDVal
            for IND in MISO_INDICATORS
                @testset "$(IND)" begin
                    IND = eval(Meta.parse(IND))
                    ind = IND{MACDVal}(
                        input_filter = always_true,
                        input_modifier = macd_to_ohlcv,
                        input_modifier_return_type = OHLCV{Missing,Float64,Float64},
                    )
                    macd_val = MACDVal(0.0, 0.0, 0.0)
                    @test ind.input_filter(macd_val) == true
                    @test ind.input_modifier(macd_val) ==
                          OHLCV(0.0, 0.0, 0.0, 0.0, volume = 0.0)
                    fit!(ind, macd_val)
                    @test 1 == 1
                end
            end
        end

        @testset "MIMO" begin
            # MIMO indicator with MACDVal input but with an input_modifier which return OHLCV from MACDVal
            for IND in MIMO_INDICATORS
                @testset "$(IND)" begin
                    IND = eval(Meta.parse(IND))
                    ind = IND{MACDVal}(
                        input_filter = always_true,
                        input_modifier = macd_to_ohlcv,
                        input_modifier_return_type = OHLCV{Missing,Float64,Float64},
                    )
                    macd_val = MACDVal(0.0, 0.0, 0.0)
                    @test ind.input_filter(macd_val) == true
                    @test ind.input_modifier(macd_val) ==
                          OHLCV(0.0, 0.0, 0.0, 0.0, volume = 0.0)
                    fit!(ind, macd_val)
                    @test 1 == 1
                end
            end
        end

        @testset "Others" begin
            # others indicators (ie more complex indicators which are of one category SISO, SIMO, MISO, MIMO but are using indicators of an other one category)
            @testset "STC" begin
                ind = STC{OHLCV}(
                    input_filter = always_true,
                    input_modifier = ValueExtractor.extract_close,
                    input_modifier_return_type = Float64,
                )
                fit!(ind, OHLCV(0.0, 0.0, 0.0, 0.0, volume = 0.0))
            end
        end

    end

    @testset "input as vector" begin
        @testset "SISO" begin
            # SISO indicators with vector input of close prices
            for IND in SISO_INDICATORS
                @testset "$(IND)" begin
                    IND = eval(Meta.parse(IND))
                    ind = IND(CLOSE_TMPL)
                    @test 1 == 1
                end
            end
        end

        @testset "SIMO" begin
            # SIMO indicators with vector input of close prices
            for IND in SIMO_INDICATORS
                @testset "$(IND)" begin
                    IND = eval(Meta.parse(IND))
                    ind = IND(CLOSE_TMPL)
                    @test 1 == 1
                end
            end
        end

        @testset "MISO" begin
            # MISO indicators with vector input of candlestick
            for IND in MISO_INDICATORS
                @testset "$(IND)" begin
                    IND = eval(Meta.parse(IND))
                    ind = IND(V_OHLCV)
                    @test 1 == 1
                end
            end
        end

        @testset "MIMO" begin
            # MIMO indicators with vector input of candlestick
            for IND in MIMO_INDICATORS
                @testset "$(IND)" begin
                    IND = eval(Meta.parse(IND))
                    ind = IND(V_OHLCV)
                    @test 1 == 1
                end
            end
        end

        @testset "Others" begin
            @testset "STC" begin
                ind = STC(CLOSE_TMPL)
                @test 1 == 1
            end
        end

    end

    using OnlineTechnicalIndicators: TechnicalIndicatorIterator
    @testset "iterator" begin
        @testset "SISO" begin
            @testset "SMA" begin
                itr = TechnicalIndicatorIterator(SMA, CLOSE_TMPL, period = P)
                values = collect(itr)
                @test eltype(values) == Union{Missing,Float64}
                @test length(values) == length(CLOSE_TMPL)
                @test isapprox(values[end-2], 9.075500; atol = ATOL)
                @test isapprox(values[end-1], 9.183000; atol = ATOL)
                @test isapprox(values[end], 9.308500; atol = ATOL)
            end
        end

        @testset "SIMO" begin
            @testset "BB" begin
                itr = TechnicalIndicatorIterator(
                    BB,
                    CLOSE_TMPL,
                    period = 5,
                    std_dev_mult = 2.0,
                )
                values = collect(itr)
                @test eltype(values) == Union{Missing,BBVal{Float64}}
                @test length(values) == length(CLOSE_TMPL)
                @test isapprox(values[end-2].lower, 8.186646; atol = ATOL)
                @test isapprox(values[end-2].central, 9.748000; atol = ATOL)
                @test isapprox(values[end-2].upper, 11.309353; atol = ATOL)
                @test isapprox(values[end-1].lower, 9.161539; atol = ATOL)
                @test isapprox(values[end-1].central, 10.096000; atol = ATOL)
                @test isapprox(values[end-1].upper, 11.030460; atol = ATOL)
                @test isapprox(values[end].lower, 9.863185; atol = ATOL)
                @test isapprox(values[end].central, 10.254000; atol = ATOL)
                @test isapprox(values[end].upper, 10.644814; atol = ATOL)
            end
        end

        @testset "MISO" begin
            @testset "ATR" begin
                itr = TechnicalIndicatorIterator(ATR, V_OHLCV, period = 5)
                values = collect(itr)
                @test eltype(values) == Union{Missing,Float64}
                @test length(values) == length(CLOSE_TMPL)
                @test isapprox(values[end-2], 0.676426; atol = ATOL)
                @test isapprox(values[end-1], 0.665141; atol = ATOL)
                @test isapprox(values[end], 0.686113; atol = ATOL)
            end
        end

        @testset "MIMO" begin
            @testset "ATR" begin
                itr = TechnicalIndicatorIterator(
                    Stoch,
                    V_OHLCV,
                    period = 14,
                    smoothing_period = 3,
                )
                values = collect(itr)
                @test eltype(values) == Union{Missing,StochVal{Float64}}
                @test length(values) == length(CLOSE_TMPL)
                @test isapprox(values[end-2].k, 88.934426; atol = ATOL)
                @test isapprox(values[end-2].d, 88.344442; atol = ATOL)
                @test isapprox(values[end-1].k, 74.180327; atol = ATOL)
                @test isapprox(values[end-1].d, 84.499789; atol = ATOL)
                @test isapprox(values[end].k, 64.754098; atol = ATOL)
                @test isapprox(values[end].d, 75.956284; atol = ATOL)
            end
        end

    end


    using OnlineTechnicalIndicators: TechnicalIndicatorWrapper, load!
    using Tables
    @testset "table" begin
        @testset "some tests examples" begin
            @testset "SISO" begin
                @testset "SMA" begin
                    wrap = TechnicalIndicatorWrapper(SMA, period = P)
                    results = load!(RT_OHLCV, wrap)
                    @test results.name == :SMA
                    @test length(results.fieldnames) == 1
                    @test results.fieldnames[1] == :value
                    @test results.fieldtypes == (Float64,)
                    values = results.output
                    @test eltype(values) == Union{Missing,Float64}
                    @test isapprox(values[end-2], 9.075500; atol = ATOL)
                    @test isapprox(values[end-1], 9.183000; atol = ATOL)
                    @test isapprox(values[end], 9.308500; atol = ATOL)
                    @test Tables.istable(typeof(results))
                    @test names(results) == [:SMA]  # simpler than SMA_value
                    @test Tables.rowaccess(typeof(results))
                    # @test Tables.rows(results) === results
                end
            end

            @testset "SIMO" begin
                @testset "BB" begin
                    wrap = TechnicalIndicatorWrapper(BB, period = 5, std_dev_mult = 2.0)
                    results = load!(RT_OHLCV, wrap)
                    @test results.name == :BB
                    @test length(results.fieldnames) == 3
                    @test results.fieldnames == (:lower, :central, :upper)
                    @test results.fieldtypes == (Float64, Float64, Float64)
                    values = results.output
                    @test eltype(values) == Union{Missing,BBVal{Float64}}
                    @test isapprox(values[end-2].lower, 8.186646; atol = ATOL)
                    @test isapprox(values[end-2].central, 9.748000; atol = ATOL)
                    @test isapprox(values[end-2].upper, 11.309353; atol = ATOL)
                    @test isapprox(values[end-1].lower, 9.161539; atol = ATOL)
                    @test isapprox(values[end-1].central, 10.096000; atol = ATOL)
                    @test isapprox(values[end-1].upper, 11.030460; atol = ATOL)
                    @test isapprox(values[end].lower, 9.863185; atol = ATOL)
                    @test isapprox(values[end].central, 10.254000; atol = ATOL)
                    @test isapprox(values[end].upper, 10.644814; atol = ATOL)
                    @test Tables.istable(typeof(results))
                    @test names(results) == [:BB_lower, :BB_central, :BB_upper]
                end
            end

            @testset "MISO" begin
                @testset "ATR" begin
                    wrap = TechnicalIndicatorWrapper(ATR, period = 5)
                    results = load!(RT_OHLCV, wrap)
                    @test results.name == :ATR
                    @test length(results.fieldnames) == 1
                    @test results.fieldnames[1] == :value
                    @test results.fieldtypes == (Float64,)
                    values = results.output
                    @test eltype(values) == Union{Missing,Float64}
                    @test isapprox(values[end-2], 0.676426; atol = ATOL)
                    @test isapprox(values[end-1], 0.665141; atol = ATOL)
                    @test isapprox(values[end], 0.686113; atol = ATOL)
                    @test Tables.istable(typeof(results))
                    @test names(results) == [:ATR]  # simpler than ATR_value
                end
            end

            @testset "MIMO" begin
                @testset "Stoch" begin
                    wrap =
                        TechnicalIndicatorWrapper(Stoch, period = 14, smoothing_period = 3)
                    results = load!(RT_OHLCV, wrap)
                    @test results.name == :Stoch
                    @test length(results.fieldnames) == 2
                    @test results.fieldnames == (:k, :d)
                    @test results.fieldtypes == (Float64, Union{Missing,Float64})
                    values = results.output
                    @test eltype(values) == Union{Missing,StochVal{Float64}}
                    @test isapprox(values[end-2].k, 88.934426; atol = ATOL)
                    @test isapprox(values[end-2].d, 88.344442; atol = ATOL)
                    @test isapprox(values[end-1].k, 74.180327; atol = ATOL)
                    @test isapprox(values[end-1].d, 84.499789; atol = ATOL)
                    @test isapprox(values[end].k, 64.754098; atol = ATOL)
                    @test isapprox(values[end].d, 75.956284; atol = ATOL)
                    @test Tables.istable(typeof(results))
                    @test names(results) == [:Stoch_k, :Stoch_d]
                end
            end
        end

        @testset_skip "All indicators should accept table as input" begin
            for IND in ALL_INDICATORS
                @testset "$(IND)" begin
                    IND = eval(Meta.parse(IND))
                    table = TAB_OHLCV
                    result = IND(table)
                    @test 1 == 1
                end
            end

        end

    end



end
