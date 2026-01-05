using OnlineTechnicalIndicators: TechnicalIndicator, always_true, ismultiinput, ismultioutput, macd_to_ohlcv
using OnlineTechnicalIndicators.Indicators:
    SISO_INDICATORS,
    SIMO_INDICATORS,
    MISO_INDICATORS,
    MIMO_INDICATORS,
    OTHERS_INDICATORS,
    MACDVal
using OnlineTechnicalIndicators.SampleData: RT_OHLCV, TAB_OHLCV

@testitem "Indicators - Unified Interface" begin
    using OnlineTechnicalIndicators
    using OnlineTechnicalIndicators.Indicators

    files = readdir("../src/indicators")
    # Filter out the module file Indicators.jl
    indicator_files = filter(f -> f != "Indicators.jl", files)
    @test length(indicator_files) == 65  # number of indicators (Smoother moved to src/wrappers/)

    _exported = names(OnlineTechnicalIndicators.Indicators)

    for file in indicator_files
        stem, suffix = splitext(file)

        @test suffix == ".jl"  # only .jl files should be in this directory

        # each file should have a struct with the exact same name that the .jl file
        @test Symbol(stem) in _exported

        # type DataType from stem (String)
        O = getfield(OnlineTechnicalIndicators.Indicators, Symbol(stem))

        # OnlineStatsBase interface
        ## each indicator should have a `value` field
        hasfield(O, :value)
        ## each indicator should have a `n` field
        @test hasfield(O, :n)

        @test fieldtype(O, :n) == Int
        # TechnicalIndicator
        # NOTE: The following fields have been REMOVED from built-in indicators
        # as part of the OnlineStatsChains migration:
        #   - output_listeners: No longer used - StatDAG handles propagation
        #   - input_indicator: No longer used - StatDAG tracks connections
        #   - input_filter: No longer used in built-in indicators - StatDAG filtered edges replace this
        #   - input_modifier: No longer used in built-in indicators - StatDAG transform replaces this
        #
        # Legacy support for input_filter/input_modifier still exists for custom indicators
        # that may define these fields, but built-in indicators use StatDAG.
        #
        # These conditional checks remain for backward compatibility with any
        # user-defined indicators that might still use the old pattern.
        if hasfield(O, :output_listeners)
            @test fieldtype(O, :output_listeners) == Series
        end
        if hasfield(O, :input_indicator)
            @test fieldtype(O, :input_indicator) == Union{Missing,TechnicalIndicator}
        end
    end
end

@testitem "Indicators - SISO Expected Return Type" begin
    using OnlineTechnicalIndicators: ismultiinput, ismultioutput, expected_return_type
    using OnlineTechnicalIndicators.Indicators: SISO_INDICATORS

    for IND_name in SISO_INDICATORS
        IND = getfield(OnlineTechnicalIndicators.Indicators, Symbol(IND_name))
        @test !ismultiinput(IND)
        @test !ismultioutput(IND)
        ind = IND{Float64}()
        @test expected_return_type(ind) == Float64
    end
end

@testitem "Indicators - SIMO Expected Return Type" begin
    using OnlineTechnicalIndicators: ismultiinput, ismultioutput
    using OnlineTechnicalIndicators.Indicators: SIMO_INDICATORS

    for IND_name in SIMO_INDICATORS
        IND = getfield(OnlineTechnicalIndicators.Indicators, Symbol(IND_name))
        @test !ismultiinput(IND)
        @test ismultioutput(IND)
        ind = IND{Float64}()
        # @test expected_return_type(ind) == ...  # see in others tests
    end
end

@testitem "Indicators - MISO Expected Return Type" begin
    using OnlineTechnicalIndicators: OHLCV, ismultiinput, ismultioutput, expected_return_type
    using OnlineTechnicalIndicators.Indicators: MISO_INDICATORS

    for IND_name in MISO_INDICATORS
        IND = getfield(OnlineTechnicalIndicators.Indicators, Symbol(IND_name))
        @test ismultiinput(IND)
        @test !ismultioutput(IND)
        ind = IND{OHLCV{Missing,Float64,Float64}}()
        @test expected_return_type(ind) == Float64
    end
end

@testitem "Indicators - MIMO Expected Return Type" begin
    using OnlineTechnicalIndicators: OHLCV, ismultiinput, ismultioutput
    using OnlineTechnicalIndicators.Indicators: MIMO_INDICATORS

    for IND_name in MIMO_INDICATORS
        IND = getfield(OnlineTechnicalIndicators.Indicators, Symbol(IND_name))
        @test ismultiinput(IND)
        @test ismultioutput(IND)
        ind = IND{OHLCV{Missing,Float64,Float64}}()
        # @test expected_return_type(ind) == ...  # see in others tests
    end
end

@testitem "Indicators - STC Expected Return Type" begin
    using OnlineTechnicalIndicators.Indicators: STC
    using OnlineTechnicalIndicators: ismultiinput, ismultioutput, expected_return_type

    ind = STC{Float64}()  # SISO
    @test !ismultiinput(STC)
    @test !ismultioutput(STC)
    @test expected_return_type(ind) == Float64
end

@testitem "Indicators - SISO with Vector Input" begin
    using OnlineTechnicalIndicators.Indicators: SISO_INDICATORS
    using OnlineTechnicalIndicators.SampleData: CLOSE_TMPL

    # SISO indicators with vector input of close prices
    for IND_name in SISO_INDICATORS
        IND = getfield(OnlineTechnicalIndicators.Indicators, Symbol(IND_name))
        ind = IND(CLOSE_TMPL)
        @test 1 == 1
    end
end

@testitem "Indicators - SIMO with Vector Input" begin
    using OnlineTechnicalIndicators.Indicators: SIMO_INDICATORS
    using OnlineTechnicalIndicators.SampleData: CLOSE_TMPL

    # SIMO indicators with vector input of close prices
    for IND_name in SIMO_INDICATORS
        IND = getfield(OnlineTechnicalIndicators.Indicators, Symbol(IND_name))
        ind = IND(CLOSE_TMPL)
        @test 1 == 1
    end
end

@testitem "Indicators - MISO with Vector Input" begin
    using OnlineTechnicalIndicators.Indicators: MISO_INDICATORS
    using OnlineTechnicalIndicators.SampleData: V_OHLCV

    # MISO indicators with vector input of candlestick
    for IND_name in MISO_INDICATORS
        IND = getfield(OnlineTechnicalIndicators.Indicators, Symbol(IND_name))
        ind = IND(V_OHLCV)
        @test 1 == 1
    end
end

@testitem "Indicators - MIMO with Vector Input" begin
    using OnlineTechnicalIndicators.Indicators: MIMO_INDICATORS
    using OnlineTechnicalIndicators.SampleData: V_OHLCV

    # MIMO indicators with vector input of candlestick
    for IND_name in MIMO_INDICATORS
        IND = getfield(OnlineTechnicalIndicators.Indicators, Symbol(IND_name))
        ind = IND(V_OHLCV)
        @test 1 == 1
    end
end

@testitem "Indicators - STC with Vector Input" begin
    using OnlineTechnicalIndicators.Indicators: STC
    using OnlineTechnicalIndicators.SampleData: CLOSE_TMPL

    ind = STC(CLOSE_TMPL)
    @test 1 == 1
end

@testitem "Indicators - Iterator SISO SMA" begin
    using OnlineTechnicalIndicators.Indicators: SMA
    using OnlineTechnicalIndicators: TechnicalIndicatorIterator
    using OnlineTechnicalIndicators.SampleData: CLOSE_TMPL

    const P = 20  # default period
    const ATOL = 0.00001  # default absolute tolerance

    itr = TechnicalIndicatorIterator(SMA, CLOSE_TMPL, period = P)
    values = collect(itr)
    @test eltype(values) == Union{Missing,Float64}
    @test length(values) == length(CLOSE_TMPL)
    @test isapprox(values[end-2], 9.075500; atol = ATOL)
    @test isapprox(values[end-1], 9.183000; atol = ATOL)
    @test isapprox(values[end], 9.308500; atol = ATOL)
end

@testitem "Indicators - Iterator SIMO BB" begin
    using OnlineTechnicalIndicators.Indicators: BB, BBVal
    using OnlineTechnicalIndicators: TechnicalIndicatorIterator
    using OnlineTechnicalIndicators.SampleData: CLOSE_TMPL

    const ATOL = 0.00001  # default absolute tolerance

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

@testitem "Indicators - Iterator MISO ATR" begin
    using OnlineTechnicalIndicators.Indicators: ATR
    using OnlineTechnicalIndicators: TechnicalIndicatorIterator
    using OnlineTechnicalIndicators.SampleData: V_OHLCV, CLOSE_TMPL

    const ATOL = 0.00001  # default absolute tolerance

    itr = TechnicalIndicatorIterator(ATR, V_OHLCV, period = 5)
    values = collect(itr)
    @test eltype(values) == Union{Missing,Float64}
    @test length(values) == length(CLOSE_TMPL)
    @test isapprox(values[end-2], 0.676426; atol = ATOL)
    @test isapprox(values[end-1], 0.665141; atol = ATOL)
    @test isapprox(values[end], 0.686113; atol = ATOL)
end

@testitem "Indicators - Iterator MIMO Stoch" begin
    using OnlineTechnicalIndicators.Indicators: Stoch, StochVal
    using OnlineTechnicalIndicators: TechnicalIndicatorIterator
    using OnlineTechnicalIndicators.SampleData: V_OHLCV, CLOSE_TMPL

    const ATOL = 0.00001  # default absolute tolerance

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

@testitem "Indicators - Table SISO SMA" begin
    using OnlineTechnicalIndicators
    using OnlineTechnicalIndicators.Indicators: SMA
    using OnlineTechnicalIndicators: TechnicalIndicatorWrapper, load!
    using OnlineTechnicalIndicators.SampleData: RT_OHLCV
    using Tables

    const P = 20  # default period
    const ATOL = 0.00001  # default absolute tolerance

    wrap = TechnicalIndicatorWrapper(SMA, period = P)
    results = load!(RT_OHLCV, wrap)
    @test String(results.name) == "OnlineTechnicalIndicators.Indicators.SMA" || results.name == :SMA
    @test length(results.fieldnames) == 1
    @test results.fieldnames[1] == :value
    @test results.fieldtypes == (Float64,)
    values = results.output
    @test eltype(values) == Union{Missing,Float64}
    @test isapprox(values[end-2], 9.075500; atol = ATOL)
    @test isapprox(values[end-1], 9.183000; atol = ATOL)
    @test isapprox(values[end], 9.308500; atol = ATOL)
    @test Tables.istable(typeof(results))
    @test length(names(results)) == 1  # Should have one column
    @test Tables.rowaccess(typeof(results))
    # @test Tables.rows(results) === results
end

@testitem "Indicators - Table SIMO BB" begin
    using OnlineTechnicalIndicators
    using OnlineTechnicalIndicators.Indicators: BB, BBVal
    using OnlineTechnicalIndicators: TechnicalIndicatorWrapper, load!
    using OnlineTechnicalIndicators.SampleData: RT_OHLCV
    using Tables

    const ATOL = 0.00001  # default absolute tolerance

    wrap = TechnicalIndicatorWrapper(BB, period = 5, std_dev_mult = 2.0)
    results = load!(RT_OHLCV, wrap)
    @test String(results.name) == "OnlineTechnicalIndicators.Indicators.BB" || results.name == :BB
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
    @test length(names(results)) == 3  # Should have three columns
end

@testitem "Indicators - Table MISO ATR" begin
    using OnlineTechnicalIndicators
    using OnlineTechnicalIndicators.Indicators: ATR
    using OnlineTechnicalIndicators: TechnicalIndicatorWrapper, load!
    using OnlineTechnicalIndicators.SampleData: RT_OHLCV
    using Tables

    const ATOL = 0.00001  # default absolute tolerance

    wrap = TechnicalIndicatorWrapper(ATR, period = 5)
    results = load!(RT_OHLCV, wrap)
    @test String(results.name) == "OnlineTechnicalIndicators.Indicators.ATR" || results.name == :ATR
    @test length(results.fieldnames) == 1
    @test results.fieldnames[1] == :value
    @test results.fieldtypes == (Float64,)
    values = results.output
    @test eltype(values) == Union{Missing,Float64}
    @test isapprox(values[end-2], 0.676426; atol = ATOL)
    @test isapprox(values[end-1], 0.665141; atol = ATOL)
    @test isapprox(values[end], 0.686113; atol = ATOL)
    @test Tables.istable(typeof(results))
    @test length(names(results)) == 1  # Should have one column
end

@testitem "Indicators - Table MIMO Stoch" begin
    using OnlineTechnicalIndicators
    using OnlineTechnicalIndicators.Indicators: Stoch, StochVal
    using OnlineTechnicalIndicators: TechnicalIndicatorWrapper, load!
    using OnlineTechnicalIndicators.SampleData: RT_OHLCV
    using Tables

    const ATOL = 0.00001  # default absolute tolerance

    wrap = TechnicalIndicatorWrapper(Stoch, period = 14, smoothing_period = 3)
    results = load!(RT_OHLCV, wrap)
    @test String(results.name) == "OnlineTechnicalIndicators.Indicators.Stoch" || results.name == :Stoch
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
    @test length(names(results)) == 2  # Should have two columns
end
