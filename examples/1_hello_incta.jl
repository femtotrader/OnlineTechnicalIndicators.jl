#=

This example demonstrates how to uses an IncTA technical analysis indicator in an incremental approach feeding new data one observation at a time.

=#

using IncTA
using IncTA.SampleData: CLOSE_TMPL, V_OHLCV


println("Show close prices")
println(CLOSE_TMPL)

println("Calculate SMA (simple moving average)")
ind = SMA{Float64}(period = 3)  # this is a SISO indicator
for p in CLOSE_TMPL
    fit!(ind, p)
    println(value(ind))
end

println("")

println("Calculate BB (Bollinger bands)")
ind = BB{Float64}(period = 3)  # this is a SIMO indicator
for p in CLOSE_TMPL
    fit!(ind, p)
    println(value(ind))
end

println("")

println("Show candlestick data")
println(V_OHLCV)

println("Calculate ATR (Average true range)")
ind = ATR{OHLCV}(period = 3)  # this is a MISO indicator
for candle in V_OHLCV
    fit!(ind, candle)
    println(value(ind))
end

println("")

println("Calculate Stoch (Stochastic)")
ind = Stoch{OHLCV{Missing,Float64,Float64}}(period = 3)  # this is a MIMO indicator
for candle in V_OHLCV
    fit!(ind, candle)
    println(value(ind))
end


# to learn more about this library usage, look at unit tests
