#=

This example demonstrates how to use an OnlineTechnicalIndicators technical analysis indicator by feeding a compatible Tables.jl table such as TSFrame.

=#


using MarketData
using TSFrames
using OnlineTechnicalIndicators

print("Get input data")
ta = random_ohlcv()  # should return a TimeSeries.TimeArray  (need latest dev version of MarketData) with random prices and volume
ts = TSFrame(ta)  # converts a TimeSeries.TimeArray to TSFrames.TSFrame
println(ts)

print("Calculate Simple Moving Average (SMA) of close prices")
println(SMA(ts; period = 3))

println("")

print("Calculate Simple Moving Average (SMA) of open prices")
println(SMA(ts; period = 3, default = :Open))

println("")

println("Calculate BB (Bollinger bands)")
println(BB(ts; period = 3))

println("")

println("Calculate ATR (Average true range)")
println(ATR(ts; period = 3))

println("")

println("Calculate Stoch (Stochastic)")
println(Stoch(ts; period = 3))
