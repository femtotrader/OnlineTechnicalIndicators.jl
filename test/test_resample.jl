using OnlineTechnicalIndicators.Resample:
    TimeUnitType, SamplingPeriodType, Resampler, normalize, TimedEvent, ResamplerBy
using OnlineTechnicalIndicators.Resample: OHLC, OHLCStat, Sum
using Dates

@testitem "Resample Units" begin
    using OnlineTechnicalIndicators.Resample: TimeUnitType

    @test Integer(TimeUnitType.SEC) == 0
    @test Integer(TimeUnitType.MIN) == 1
    @test Integer(TimeUnitType.HOUR) == 2
    @test Integer(TimeUnitType.DAY) == 3
end

@testitem "Resample Sampling period" begin
    using OnlineTechnicalIndicators.Resample: TimeUnitType, SamplingPeriodType

    sampling_period = SamplingPeriodType.MIN_15
    @test sampling_period.type == TimeUnitType.MIN
    @test sampling_period.length == 15
end

@testitem "Resample Normalize" begin
    using OnlineTechnicalIndicators.Resample: SamplingPeriodType, Resampler, normalize
    using Dates

    dt = DateTime(2024, 4, 22, 17, 21, 53)

    sampling_period = SamplingPeriodType.SEC_5
    sampler = Resampler(sampling_period)
    @test normalize(sampler, dt) == DateTime(2024, 4, 22, 17, 21, 50)

    sampling_period = SamplingPeriodType.MIN_15
    sampler = Resampler(sampling_period)
    @test normalize(sampler, dt) == DateTime(2024, 4, 22, 17, 15, 0)

    sampling_period = SamplingPeriodType.HOUR_2
    sampler = Resampler(sampling_period)
    @test normalize(sampler, dt) == DateTime(2024, 4, 22, 16, 0, 0)

    sampling_period = SamplingPeriodType.DAY_1
    sampler = Resampler(sampling_period)
    @test normalize(sampler, dt) == DateTime(2024, 4, 22, 0, 0, 0)
end

@testitem "Resample sum" begin
    using OnlineTechnicalIndicators.Resample: SamplingPeriodType, ResamplerBy, TimedEvent, Sum
    using Dates

    sampling_period = SamplingPeriodType.MIN_1
    resampler = ResamplerBy(sampling_period, Sum)

    dt = DateTime(2024, 4, 22, 17, 21, 53)
    vol = 1.0
    event = TimedEvent(dt, vol)
    fit!(resampler, event)
    result = value(resampler)
    @test result.time == DateTime(2024, 4, 22, 17, 21, 0)
    @test value(result.data) == 1.0

    dt = DateTime(2024, 4, 22, 17, 21, 55)
    vol = 5.1
    event = TimedEvent(dt, vol)
    fit!(resampler, event)
    result = value(resampler)
    @test result.time == DateTime(2024, 4, 22, 17, 21, 0)
    @test value(result.data) == 6.1

    dt = DateTime(2024, 4, 22, 17, 22, 1)
    vol = 2.1
    event = TimedEvent(dt, vol)
    fit!(resampler, event)
    result = value(resampler)
    @test result.time == DateTime(2024, 4, 22, 17, 22, 0)
    @test value(result.data) == 2.1
end

@testitem "Resample OHLC" begin
    using OnlineTechnicalIndicators.Resample: SamplingPeriodType, ResamplerBy, TimedEvent, OHLCStat
    using Dates

    sampling_period = SamplingPeriodType.MIN_1
    resampler = ResamplerBy(sampling_period, OHLCStat{Float64})
    dt = DateTime(2024, 4, 22, 21, 16, 2)
    event = TimedEvent(dt, 1000.0)
    fit!(resampler, event)
    dt = DateTime(2024, 4, 22, 21, 16, 3)
    event = TimedEvent(dt, 1500.0)
    fit!(resampler, event)
    dt = DateTime(2024, 4, 22, 21, 16, 4)
    event = TimedEvent(dt, 800.0)
    fit!(resampler, event)
    dt = DateTime(2024, 4, 22, 21, 16, 5)
    event = TimedEvent(dt, 900.0)
    fit!(resampler, event)
    result = value(resampler)
    @test result.time == DateTime(2024, 4, 22, 21, 16, 0)
    cdl = value(result.data)
    @test cdl.open == 1000.0
    @test cdl.high == 1500.0
    @test cdl.low == 800.0
    @test cdl.close == 900.0
end
