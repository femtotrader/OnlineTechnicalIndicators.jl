const Aroon_PERIOD = 10

struct AroonVal{Tval}
    up::Tval
    down::Tval
end

"""
    Aroon{Tohlcv,S}(; period = Aroon_PERIOD)

The `Aroon` type implements an Aroon indicator.
"""
mutable struct Aroon{Tohlcv,S} <: TechnicalIndicator{Tohlcv}
    value::Union{Missing,AroonVal{S}}
    n::Int

    period::Integer

    input::CircBuff

    function Aroon{Tohlcv,S}(; period = Aroon_PERIOD) where {Tohlcv,S}
        input = CircBuff(Tohlcv, period + 1, rev = false)
        new{Tohlcv,S}(missing, 0, period, input)
    end
end

function OnlineStatsBase._fit!(ind::Aroon, candle)
    fit!(ind.input, candle)
    ind.n += 1

    # search in reversed list in order to get the right-most index
    price_low = 0.0
    price_high = 0.0
    day_high = 0
    day_low = 0
    rng = (ind.period+1):-1:1
    println(collect(rng))
    for i in rng
        cdl = ind.input[i]
        if cdl.high > price_high
            price_high = cdl.high
            day_high = i
        end
        if cdl.low < price_low
            price_low = cdl.low
            day_low = i
        end
    end
    days_high = ind.period - day_high
    days_low = ind.period - day_low

    #days_high = ind.period - argmax([cdl.high for cdl in reverse(value(ind.input))])
    #days_low = ind.period - argmin([cdl.low for cdl in reverse(value(ind.input))])

    #=
    days_high = ind.period - max(reversed(range(ind.period + 1)),
                                    key = lambda x: ind.input[-ind.period - 1:][x].high)
    days_low = ind.period - min(reversed(range(ind.period + 1)),
                                    key = lambda x: ind.input_values[-ind.period - 1:][x].low)
    =#

    ind.value = AroonVal(
        100.0 * (ind.period - days_high) / ind.period,
        100.0 * (ind.period - days_low) / ind.period,
    )
end
