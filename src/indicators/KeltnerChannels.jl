const KeltnerChannels_MA_PERIOD = 10
const KeltnerChannels_ATR_PERIOD = 10
const KeltnerChannels_ATR_MULT_UP = 2.0
const KeltnerChannels_ATR_MULT_DOWN = 3.0


#=
# See https://github.com/joshday/OnlineStats.jl/issues/271
# See FilterTransform https://joshday.github.io/OnlineStats.jl/latest/api/#OnlineStatsBase.FilterTransform

struct ValueExtractor{T,O<:OnlineStat{T},F<:Function} <: OnlineStat{T}
    stat::O
    f::F
end
#ValueExtractor{T}(o::O, f::F) where {T, O<:OnlineStat{T}, F} = ValueExtractor{T, O, F}(o, f)
function _fit!(o::ValueExtractor, arg)
    _fit!(o.stat, f(arg))
end
=#

struct KeltnerChannelsVal{Tval}
    lower::Tval
    central::Tval
    upper::Tval
end

"""
    KeltnerChannels{Tohlcv,S}(; ma_period = KeltnerChannels_MA_PERIOD, atr_period = KeltnerChannels_ATR_PERIOD, atr_mult_up = KeltnerChannels_ATR_MULT_UP, atr_mult_down = KeltnerChannels_ATR_MULT_DOWN)

The KeltnerChannels type implements a Keltner Channels indicator.
"""
mutable struct KeltnerChannels{Tohlcv,S} <: OnlineStat{Tohlcv}
    value::Union{Missing,KeltnerChannelsVal{S}}
    n::Int

    ma_period::Integer
    atr_period::Integer
    atr_mult_up::S
    atr_mult_down::S

    atr::ATR
    cb::EMA
    #cb::ValueExtractor  # EMA candle.close (see also CallFun)

    function KeltnerChannels{Tohlcv,S}(;
        ma_period = KeltnerChannels_MA_PERIOD,
        atr_period = KeltnerChannels_ATR_PERIOD,
        atr_mult_up = KeltnerChannels_ATR_MULT_UP,
        atr_mult_down = KeltnerChannels_ATR_MULT_DOWN,
    ) where {Tohlcv,S}
        atr = ATR{Tohlcv,S}(period = atr_period)
        cb = EMA{S}(period = ma_period)
        #cb = ValueExtractor{Float64,OnlineStat{Tohlcv},Function}(o, candle -> candle.close)  # CallFun, ValueExtractor
        new{Tohlcv,S}(
            missing,
            0,
            ma_period,
            atr_period,
            atr_mult_up,
            atr_mult_down,
            atr,
            cb,
        )
    end
end

function OnlineStatsBase._fit!(ind::KeltnerChannels, candle)
    fit!(ind.atr, candle)
    # fit!(ind.cb, candle)  # something like a ValueExtractor should be implemented taking a function like candle->candle.close as argument
    fit!(ind.cb, candle.close)
    ind.n += 1
    if has_output_value(ind.atr) && has_output_value(ind.cb)
        ind.value = KeltnerChannelsVal(
            value(ind.cb) - ind.atr_mult_down * value(ind.atr),
            value(ind.cb),
            value(ind.cb) + ind.atr_mult_up * value(ind.atr),
        )
    else
        ind.value = missing
    end
end
