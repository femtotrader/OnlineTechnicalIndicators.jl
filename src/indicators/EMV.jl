const EMV_PERIOD = 20
const EMV_VOLUME_DIV = 10000

"""
    EMV{Tohlcv}(; period = EMV_PERIOD, volume_div = EMV_VOLUME_DIV)

The EMV type implements a Ease of Movement indicator.
"""
mutable struct EMV{Tohlcv} <: OnlineStat{Tohlcv}
    value::Union{Missing,Float64}  # Tprice
    n::Int

    period::Integer
    volume_div::Integer

    emv_sma::SMA{Float64}  # Tprice

    input::CircBuff{Tohlcv}

    function EMV{Tohlcv}(;
        period = EMV_PERIOD,
        volume_div = EMV_VOLUME_DIV,
    ) where {Tohlcv}
        Tprice = Float64
        emv_sma = SMA{Tprice}(period = period)
        input = CircBuff(Tohlcv, period, rev = false)
        new{Tohlcv}(missing, 0, period, volume_div, emv_sma, input)
    end
end

function OnlineStatsBase._fit!(ind::EMV, candle::OHLCV)
    fit!(ind.input, candle)
    ind.n += 1
    if ind.n >= 2
        #candle = ind.input[end]
        candle_prev = ind.input[end-1]
        if candle.high != candle.low
            distance = ((candle.high + candle.low) / 2) - ((candle_prev.high + candle_prev.low) / 2)
            box_ratio = (candle.volume / ind.volume_div / (candle.high - candle.low))
            emv = distance / box_ratio
        else
            emv = 0.0
        end
    
        fit!(ind.emv_sma, emv)
    
        if length(ind.emv_sma.value) >= 1
            ind.value = value(ind.emv_sma)
        else
            ind.value = missing
        end            
    else
        ind.value = missing
    end
end
