@testset "resample" begin

    using IncTA.Resample: TimeUnitType, SamplingPeriodType, Resampler, normalize
    using Dates

    @testset "Units" begin
        @test Integer(TimeUnitType.SEC) == 0
        @test Integer(TimeUnitType.MIN) == 1
        @test Integer(TimeUnitType.HOUR) == 2
        @test Integer(TimeUnitType.DAY) == 3
    end

    @testset "Sampling period" begin
        sampling_period = SamplingPeriodType.MIN_15
        @test sampling_period.type == TimeUnitType.MIN
        @test sampling_period.length == 15
    end

    @testset "Normalize" begin
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


end
