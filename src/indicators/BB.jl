const BB_PERIOD = 5
const BB_STD_DEV_MULTIPLIER = 2.0

struct BBVal{Tval}
    lower::Tval
    central::Tval
    upper::Tval
end

"""
    BB{T}(; period = BB_PERIOD, std_dev_multiplier = BB_STD_DEV_MULTIPLIER)

The BB type implements Bollinger Bands indicator.
"""
mutable struct BB{Tval} <: OnlineStat{Tval}
    value::Union{Missing,BBVal{Tval}}
    n::Int

    period::Integer
    std_dev_multiplier::Tval

    central_band::SMA{Tval}
    std_dev::StdDev{Tval}

    function BB{Tval}(;
        period = BB_PERIOD,
        std_dev_multiplier = BB_STD_DEV_MULTIPLIER,
    ) where {Tval}
        central_band = SMA{Tval}(period = period)
        std_dev = StdDev{Tval}(period = period)
        new{Tval}(missing, 0, period, std_dev_multiplier, central_band, std_dev)
    end
end

function OnlineStatsBase._fit!(ind::BB{Tval}, data::Tval) where {Tval}
    fit!(ind.central_band, data)
    fit!(ind.std_dev, data)
    if ind.n != ind.period
        ind.n += 1
    end
    if !has_output_value(ind.central_band)
        ind.value = missing
    else
        lower = value(ind.central_band) - ind.std_dev_multiplier * value(ind.std_dev)
        central = value(ind.central_band)
        upper = value(ind.central_band) + ind.std_dev_multiplier * value(ind.std_dev)
        ind.value = BBVal{Tval}(lower, central, upper)
    end
end
