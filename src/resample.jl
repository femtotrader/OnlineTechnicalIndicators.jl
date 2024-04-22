module Resample
    using Dates

    module TimeUnitType
    @enum(TimeUnitTypeEnum,
        SEC,
        MIN,
        HOUR,
        DAY
    )
    end

    struct SamplingPeriod
        type::TimeUnitType.TimeUnitTypeEnum
        length::Integer
    end

    const SamplingPeriodType = (
        SEC_1 = SamplingPeriod(TimeUnitType.SEC, 1),
        SEC_3 = SamplingPeriod(TimeUnitType.SEC, 3),
        SEC_5 = SamplingPeriod(TimeUnitType.SEC, 5),
        SEC_10 = SamplingPeriod(TimeUnitType.SEC, 10),
        SEC_15 = SamplingPeriod(TimeUnitType.SEC, 15),
        SEC_30 = SamplingPeriod(TimeUnitType.SEC, 30),
        MIN_1 = SamplingPeriod(TimeUnitType.MIN, 1),
        MIN_3 = SamplingPeriod(TimeUnitType.MIN, 3),
        MIN_5 = SamplingPeriod(TimeUnitType.MIN, 5),
        MIN_10 = SamplingPeriod(TimeUnitType.MIN, 10),
        MIN_15 = SamplingPeriod(TimeUnitType.MIN, 15),
        MIN_30 = SamplingPeriod(TimeUnitType.MIN, 30),
        HOUR_1 = SamplingPeriod(TimeUnitType.HOUR, 1),
        HOUR_2 = SamplingPeriod(TimeUnitType.HOUR, 2),
        HOUR_3 = SamplingPeriod(TimeUnitType.HOUR, 3),
        HOUR_4 = SamplingPeriod(TimeUnitType.HOUR, 4),
        HOUR_12 = SamplingPeriod(TimeUnitType.HOUR, 12),
        DAY_1 = SamplingPeriod(TimeUnitType.DAY, 1)        
    )

    const CONVERSION_TO_SEC = Dict(
        TimeUnitType.SEC => 1,
        TimeUnitType.MIN => 60,
        TimeUnitType.HOUR => 3600,
        TimeUnitType.DAY => 3600 * 24,
    )

    struct Resampler
        sampling_period::SamplingPeriod
    end

    function normalize(resampler::Resampler, dt::Dates.DateTime)
        sampling_period = resampler.sampling_period

        period_type = sampling_period.type
        period_length = sampling_period.length

        if period_type == TimeUnitType.SEC
            period_start = DateTime(year(dt), month(dt), day(dt), hour(dt), minute(dt))
        elseif period_type == TimeUnitType.MIN
            period_start = DateTime(year(dt), month(dt), day(dt), hour(dt))
        elseif period_type == TimeUnitType.HOUR
            period_start = DateTime(year(dt), month(dt), day(dt))
        elseif period_type == TimeUnitType.DAY
            period_start = DateTime(year(dt), month(dt), 1)
        else
            error("Not implemented period_type $(period_type)")
        end

        delta = dt - period_start
        num_periods = div(Int(Dates.toms(delta) / 1000.0), period_length * CONVERSION_TO_SEC[period_type])

        normalized_dt = period_start + Second(num_periods * period_length * CONVERSION_TO_SEC[period_type])

        return normalized_dt
    end

end
