using IncTA
using IncTA: expected_return_type
using IncTA: BBVal, MACDVal, StochRSIVal, KSTVal  # SIMO
using IncTA:
    StochVal,
    SuperTrendVal,
    VTXVal,
    DonchianChannelsVal,
    KeltnerChannelsVal,
    ADXVal,
    AroonVal,
    ChandeKrollStopVal,
    ParabolicSARVal,
    SFXVal,
    TTMVal  # MIMO
using IncTA.SampleData:
    OPEN_TMPL,
    HIGH_TMPL,
    LOW_TMPL,
    CLOSE_TMPL,
    CLOSE_EQUAL_VALUES_TMPL,
    VOLUME_TMPL,
    V_OHLCV
using OnlineStatsBase
using OnlineStats: StatLag

using Test

import Test: Test, finish
using Test: DefaultTestSet, Broken
using Test: parse_testset_args

const P = 20  # default period
const ATOL = 0.00001  # default absolute tolerance

const MEMORY = length(CLOSE_TMPL)  # 50

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
    length(args) < 2 &&
        error("First argument to @testset_skip giving reason for " * "skipping is required")

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
    include("test_ohlcv.jl")

    @testset "indicators" begin
        include("test_indicators_interface.jl")
        include("test_ind_single_input_single_output.jl")  # SISO
        include("test_ind_single_input_several_outputs.jl")  # SIMO
        include("test_ind_OHLCV_input_single_output.jl")  # MISO
        include("test_ind_OHLCV_input_several_outputs.jl")  # MIMO
    end

end
