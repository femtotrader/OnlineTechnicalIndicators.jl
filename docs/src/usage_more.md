# Learn more about IncTA usage

## Feeding a technical analysis indicator one observation at a time

- A technical indicator can be feeded using `fit!` function.

- It's feeded *one observation at a time*.


### Showing sample data (close prices)

Some sample data are provided for testing purpose.

```julia
julia> using IncTA
julia> using IncTA.SampleData: CLOSE_TMPL, V_OHLCV
julia> CLOSE_TMPL
50-element Vector{Float64}:
 10.5
  9.78
 10.46
 10.51
  ⋮
 10.15
 10.3
 10.59
 10.23
 10.0
```

### Calculate `SMA` (simple moving average)

```julia
julia> ind = SMA{Float64}(period = 3)  # this is a SISO (single input / single output) indicator
SMA: n=0 | value=missing

julia> for p in CLOSE_TMPL
           fit!(ind, p)
           println(value(ind))
       end
missing
missing
10.246666666666668
10.250000000000002
10.50666666666667
10.593333333333335
10.476666666666668
 ⋮
9.283333333333339
9.886666666666672
10.346666666666671
10.373333333333338
10.273333333333339
```

### Calculate BB (Bollinger bands)

```julia
julia> ind = BB{Float64}(period = 3)  # this is a SIMO (single input / multiple output) indicator
       for p in CLOSE_TMPL
           fit!(ind, p)
           println(value(ind))
       end
missing
missing
IncTA.BBVal{Float64}(9.585892709687261, 10.246666666666668, 10.907440623646075)
IncTA.BBVal{Float64}(9.584067070444279, 10.250000000000002, 10.915932929555725)
IncTA.BBVal{Float64}(10.433030926552087, 10.50666666666667, 10.580302406781252)
 ⋮
IncTA.BBVal{Float64}(7.923987085233826, 9.283333333333339, 10.642679581432851)
IncTA.BBVal{Float64}(8.921909932792502, 9.886666666666672, 10.851423400540842)
IncTA.BBVal{Float64}(9.981396599151932, 10.346666666666671, 10.71193673418141)
IncTA.BBVal{Float64}(10.061635473931714, 10.373333333333338, 10.685031192734963)
IncTA.BBVal{Float64}(9.787718030627357, 10.273333333333339, 10.758948636039321)
```

### Showing sample data (OHLCV data)

```julia
julia> V_OHLCV  # fields are open/high/low/close/volume/time
50-element Vector{OHLCV{Missing, Float64, Float64}}:
 OHLCV{Missing, Float64, Float64}(10.81, 11.02, 9.9, 10.5, 55.03, missing)
 OHLCV{Missing, Float64, Float64}(10.58, 10.74, 9.78, 9.78, 117.86, missing)
 OHLCV{Missing, Float64, Float64}(10.07, 10.65, 9.5, 10.46, 301.04, missing)
 OHLCV{Missing, Float64, Float64}(10.58, 11.05, 10.47, 10.51, 157.94, missing)
 ⋮
 OHLCV{Missing, Float64, Float64}(9.3, 10.5, 9.26, 10.15, 255.3, missing)
 OHLCV{Missing, Float64, Float64}(10.23, 10.3, 10.0, 10.3, 111.55, missing)
 OHLCV{Missing, Float64, Float64}(10.29, 10.86, 10.19, 10.59, 108.27, missing)
 OHLCV{Missing, Float64, Float64}(10.77, 10.77, 10.15, 10.23, 48.29, missing)
 OHLCV{Missing, Float64, Float64}(10.28, 10.39, 9.62, 10.0, 81.66, missing)
```

### Calculate ATR (Average true range)

```julia
julia> ind = ATR{OHLCV}(period = 3)  # this is a MISO (multi input / single output) indicator
ATR: n=0 | value=missing

julia> for candle in V_OHLCV
           fit!(ind, candle)
           println(value(ind))
       end
missing
missing
1.0766666666666669
0.9144444444444445
0.7562962962962961
 ⋮
0.898122497312842
0.6987483315418949
0.6891655543612633
0.6661103695741752
0.700740246382784
```

### Calculate Stoch (Stochastic)

```julia
julia> ind = Stoch{OHLCV{Missing,Float64,Float64}}(period = 3)  # this is a MIMO indicator
Stoch: n=0 | value=missing

julia> for candle in V_OHLCV
           fit!(ind, candle)
           println(value(ind))
       end
IncTA.StochVal{Float64}(53.57142857142858, missing)
IncTA.StochVal{Float64}(0.0, missing)
IncTA.StochVal{Float64}(63.15789473684218, 38.90977443609025)
IncTA.StochVal{Float64}(65.1612903225806, 42.77306168647426)
IncTA.StochVal{Float64}(67.74193548387099, 65.35370684776458)
 ⋮
IncTA.StochVal{Float64}(83.17307692307695, 54.98661936768733)
IncTA.StochVal{Float64}(90.38461538461543, 83.17307692307693)
IncTA.StochVal{Float64}(83.12500000000001, 85.56089743589745)
IncTA.StochVal{Float64}(26.744186046511697, 66.75126714370903)
IncTA.StochVal{Float64}(30.645161290322637, 46.83811577894477)
```

## Feeding a technical analysis indicator with a compatible Tables.jl table such as TSFrame

A technical analysis indicator can also accept a [Tables.jl](https://tables.juliadata.org/) compatible table (`TSFrame`) as input parameter.

### Showing sample data (OHLCV data)

```julia
julia> using MarketData
julia> using TSFrames
julia> using Random
julia> Random.seed!(1234)  # to have reproductible results (so won't be really random)
julia> ta = random_ohlcv()  # should return a TimeSeries.TimeArray
julia> ts = TSFrame(ta)  # converts a TimeSeries.TimeArray to TSFrames.TSFrame
500×5 TSFrame with DateTime Index
 Index                Open     High     Low      Close    Volume
 DateTime             Float64  Float64  Float64  Float64  Float64
──────────────────────────────────────────────────────────────────
 2020-01-01T00:00:00   326.75   334.03   326.18   333.16     83.6
 2020-01-01T01:00:00   333.29   334.6    330.01   330.3      45.9
 2020-01-01T02:00:00   330.79   336.7    329.99   334.0      71.2
 2020-01-01T03:00:00   334.83   339.79   334.83   338.39     97.1
 2020-01-01T04:00:00   338.36   339.09   331.22   331.22     79.1
          ⋮              ⋮        ⋮        ⋮        ⋮        ⋮
 2020-01-21T15:00:00   353.2    360.62   349.99   358.86     59.0
 2020-01-21T16:00:00   358.81   364.03   354.5    364.03      4.2
 2020-01-21T17:00:00   363.06   367.52   362.31   362.31     90.0
 2020-01-21T18:00:00   362.03   364.81   360.4    363.3      45.6
 2020-01-21T19:00:00   362.35   363.23   358.28   361.52     19.8
```

### Simple Moving Average (`SMA`) of close prices

```julia
julia> SMA(ts; period = 3)
500×1 TSFrame with DateTime Index
 Index                SMA
 DateTime             Float64?
──────────────────────────────────
 2020-01-01T00:00:00  missing
 2020-01-01T01:00:00  missing
 2020-01-01T02:00:00      332.487
 2020-01-01T03:00:00      334.23
 2020-01-01T04:00:00      334.537
          ⋮                ⋮
 2020-01-21T15:00:00      352.087
 2020-01-21T16:00:00      358.41
 2020-01-21T17:00:00      361.733
 2020-01-21T18:00:00      363.213
 2020-01-21T19:00:00      362.377
```

### Simple Moving Average (`SMA`) of open prices

```julia
julia> SMA(ts; period = 3, default = :Open)
500×1 TSFrame with DateTime Index
 Index                SMA
 DateTime             Float64?
──────────────────────────────────
 2020-01-01T00:00:00  missing
 2020-01-01T01:00:00  missing
 2020-01-01T02:00:00      330.277
 2020-01-01T03:00:00      332.97
 2020-01-01T04:00:00      334.66
          ⋮                ⋮
 2020-01-21T15:00:00      346.72
 2020-01-21T16:00:00      352.293
 2020-01-21T17:00:00      358.357
 2020-01-21T18:00:00      361.3
 2020-01-21T19:00:00      362.48
```

### Calculate `BB` (Bollinger bands)

```julia
julia> BB(ts; period = 3)
500×3 TSFrame with DateTime Index
 Index                BB_lower     BB_central   BB_upper
 DateTime             Float64?     Float64?     Float64?
────────────────────────────────────────────────────────────
 2020-01-01T00:00:00  missing      missing      missing
 2020-01-01T01:00:00  missing      missing      missing
 2020-01-01T02:00:00      329.319      332.487      335.654
 2020-01-01T03:00:00      327.617      334.23       340.843
 2020-01-01T04:00:00      328.633      334.537      340.44
          ⋮                ⋮            ⋮            ⋮
 2020-01-21T15:00:00      340.813      352.087      363.36
 2020-01-21T16:00:00      348.844      358.41       367.976
 2020-01-21T17:00:00      357.434      361.733      366.033
 2020-01-21T18:00:00      361.804      363.213      364.623
 2020-01-21T19:00:00      360.92       362.377      363.833
```

### Calculate `ATR` (Average true range)

```julia
julia> ATR(ts; period = 3)
500×1 TSFrame with DateTime Index
 Index                ATR
 DateTime             Float64?
────────────────────────────────────
 2020-01-01T00:00:00  missing
 2020-01-01T01:00:00  missing
 2020-01-01T02:00:00        6.38333
 2020-01-01T03:00:00        6.18556
 2020-01-01T04:00:00        6.74704
          ⋮                 ⋮
 2020-01-21T15:00:00        8.53068
 2020-01-21T16:00:00        8.86378
 2020-01-21T17:00:00        7.64586
 2020-01-21T18:00:00        6.56724
 2020-01-21T19:00:00        6.05149
```

### Calculate `Stoch` (Stochastic)

```julia
julia> Stoch(ts; period = 3)
500×2 TSFrame with DateTime Index
 Index                Stoch_k    Stoch_d
 DateTime             Float64    Float64?
───────────────────────────────────────────────
 2020-01-01T00:00:00   88.9172   missing
 2020-01-01T01:00:00   48.9311   missing
 2020-01-01T02:00:00   74.3346        70.7276
 2020-01-01T03:00:00   85.7143        69.66
 2020-01-01T04:00:00   12.551         57.5333
          ⋮               ⋮            ⋮
 2020-01-21T15:00:00   91.4272        93.9504
 2020-01-21T16:00:00  100.0           97.1424
 2020-01-21T17:00:00   70.2795        87.2356
 2020-01-21T18:00:00   67.5883        79.2893
 2020-01-21T19:00:00   35.0649        57.6443
```

## Sample notebooks

### IncTA.jl notebook

- [Pluto notebook](https://github.com/femtotrader/IncTA.jl/blob/main/examples/notebooks/incta_notebook.jl)
- [PDF export](https://github.com/femtotrader/IncTA.jl/blob/main/examples/notebooks/incta_notebook.pdf)

### Feed IncTA indicators with live random data

![random walk with MA and RSI](https://github.com/femtotrader/IncTA.jl/raw/main/examples/notebooks/random_walk_with_ma_rsi.png)

- [Pluto notebook](https://github.com/femtotrader/IncTA.jl/blob/main/examples/notebooks/incta_notebook_live_randomwalk.jl)

## Examples

See content of [examples](https://github.com/femtotrader/IncTA.jl/tree/main/examples) directory.
