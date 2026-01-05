module Resample
using Dates
using OnlineStatsBase
using OnlineTechnicalIndicators
using OnlineTechnicalIndicators: TechnicalIndicator
using OnlineTechnicalIndicators.Internals: always_true

module TimeUnitType
@enum(TimeUnitTypeEnum, SEC, MIN, HOUR, DAY)
end

"""
    SamplingPeriod

Defines a time period for resampling data.

# Fields
- `type::TimeUnitType.TimeUnitTypeEnum`: Type of time unit (SEC, MIN, HOUR, DAY)
- `length::Integer`: Length of the period in the specified time units
"""
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
    DAY_1 = SamplingPeriod(TimeUnitType.DAY, 1),
)

const CONVERSION_TO_SEC = Dict(
    TimeUnitType.SEC => 1,
    TimeUnitType.MIN => 60,
    TimeUnitType.HOUR => 3600,
    TimeUnitType.DAY => 3600 * 24,
)

"""
    Resampler

Resamples time-series data according to a specified sampling period.

# Fields
- `sampling_period::SamplingPeriod`: The sampling period to use for resampling
"""
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
    num_periods =
        div(Int(Dates.toms(delta) / 1000.0), period_length * CONVERSION_TO_SEC[period_type])

    normalized_dt =
        period_start + Second(num_periods * period_length * CONVERSION_TO_SEC[period_type])

    return normalized_dt
end

"""
    TimedEvent

Represents a data point with an associated timestamp.

# Fields
- `time`: Timestamp of the event
- `data`: The data value at this time
"""
struct TimedEvent
    time::Any
    data::Any
end

"""
    AgregatedStat

Holds aggregated statistical data for a time period.

# Fields
- `time`: Timestamp of the aggregated period
- `data`: The aggregated statistical value
"""
struct AgregatedStat
    time::Any
    data::Any
end

"""
    StatBuilder

Builder for creating new statistical aggregation instances.

# Fields
- `agg`: A callable that creates new aggregation instances when invoked
"""
struct StatBuilder
    agg::Any
end
function (stat_builder::StatBuilder)()
    return stat_builder.agg()
end

module OHLCStatus
@enum(OHLCStatusEnum, INIT, NEW, USED)
end

"""
    OHLC{Tprice}

Mutable OHLC (Open, High, Low, Close) data structure for resampling price data.

# Fields
- `status::OHLCStatus.OHLCStatusEnum`: Status of the OHLC data (INIT, NEW, USED)
- `open::Tprice`: Opening price
- `high::Tprice`: Highest price
- `low::Tprice`: Lowest price
- `close::Tprice`: Closing price
"""
mutable struct OHLC{Tprice}
    status::OHLCStatus.OHLCStatusEnum
    open::Tprice
    high::Tprice
    low::Tprice
    close::Tprice
end
function OHLC{Tprice}() where {Tprice}
    p = zero(Tprice)
    return OHLC(OHLCStatus.INIT, p, p, p, p)
end

"""
    OHLCStat{T} <: OnlineStat{T}

Online statistic for computing OHLC values from streaming price data.

# Fields
- `ohlc::OHLC`: The current OHLC values
- `n::Int`: Number of observations processed
"""
struct OHLCStat{T} <: OnlineStat{T}
    ohlc::OHLC
    n::Int
    function OHLCStat{T}() where {T}
        new(OHLC{T}(), 0)
    end
end
function (ohlc_stat::OHLCStat{T})() where {T}
    OHLC{T}()
end
function OnlineStatsBase._fit!(ohlc_stat::OHLCStat, data)
    ohlc_stat.ohlc.close = data
    if ohlc_stat.ohlc.status != OHLCStatus.INIT
        if data < ohlc_stat.ohlc.low
            ohlc_stat.ohlc.low = data
        end
        if data > ohlc_stat.ohlc.high
            ohlc_stat.ohlc.high = data
        end
        ohlc_stat.ohlc.status = OHLCStatus.USED
    else
        ohlc_stat.ohlc.open = data
        ohlc_stat.ohlc.high = data
        ohlc_stat.ohlc.low = data
        ohlc_stat.ohlc.close = data
        ohlc_stat.ohlc.status = OHLCStatus.NEW
    end
end

"""
    ResamplerBy <: OnlineStat{TimedEvent}

Online statistic that resamples timed events into aggregated periods.

# Fields
- `agg::AgregatedStat`: Current aggregated statistic
- `n::Int`: Number of observations processed
- `sampling_period::SamplingPeriod`: The sampling period to use
- `stat_builder::StatBuilder`: Builder for creating new aggregation instances
- `input_modifier::Function`: Function to modify input data before processing
- `input_filter::Function`: Function to filter input data
"""
mutable struct ResamplerBy <: OnlineStat{TimedEvent}
    agg::AgregatedStat
    n::Int

    sampling_period::SamplingPeriod
    stat_builder::StatBuilder

    input_modifier::Function
    input_filter::Function

    function ResamplerBy(
        sampling_period::SamplingPeriod,
        agg;
        input_filter = always_true,
        input_modifier = identity,
    )
        #input_modifier_return_type = Tval)
        stat_builder = StatBuilder(agg)
        agregated_stat = AgregatedStat(unix2datetime(0), stat_builder())
        new(agregated_stat, 0, sampling_period, stat_builder, input_modifier, input_filter)
    end
end

function OnlineStatsBase._fit!(resampler::ResamplerBy, timed_evt::TimedEvent)
    dt_normalized = normalize(Resampler(resampler.sampling_period), timed_evt.time)
    if dt_normalized == resampler.agg.time
        fit!(resampler.agg.data, timed_evt.data)
    elseif dt_normalized > resampler.agg.time
        resampler.agg = AgregatedStat(dt_normalized, resampler.stat_builder())
        fit!(resampler.agg.data, timed_evt.data)
    else
        error("Not implemented - decreasing time")
    end
end

end
