const BB_PERIOD = 5
const BB_STD_DEV_MULT = 2.0

struct BBVal{Tval}
    lower::Tval
    central::Tval
    upper::Tval
end

"""
    BB{T}(; period = BB_PERIOD, std_dev_mult = BB_STD_DEV_MULT, ma = SMA)

The `BB` type implements Bollinger Bands indicator.
"""
mutable struct BB{Tval} <: TechnicalIndicator{Tval}
    value::Union{Missing,BBVal{Tval}}
    n::Int

    period::Integer
    std_dev_mult::Tval

    sub_indicators::Series
    central_band::MovingAverageIndicator  # default SMA
    std_dev::StdDev{Tval}

    function BB{Tval}(;
        period = BB_PERIOD,
        std_dev_mult = BB_STD_DEV_MULT,
        ma = SMA,
    ) where {Tval}
        _central_band = MAFactory(Tval)(ma, period = period)
        _std_dev = StdDev{Tval}(period = period)
        sub_indicators = Series(_central_band, _std_dev)
        new{Tval}(missing, 0, period, std_dev_mult, sub_indicators, _central_band, _std_dev)
    end
end

function _calculate_new_value(ind::BB)
    if !has_output_value(ind.central_band)
        ind.value = missing
    else
        lower = value(ind.central_band) - ind.std_dev_mult * value(ind.std_dev)
        central = value(ind.central_band)
        upper = value(ind.central_band) + ind.std_dev_mult * value(ind.std_dev)
        ind.value = BBVal(lower, central, upper)
    end
end
