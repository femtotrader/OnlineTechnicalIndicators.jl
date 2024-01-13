# Implementing your own indicator

## Categorization of your indicator

Categorization of indicators is done to better understand *implementation* of indicators, not to understand the *role* of each indicator. To better understand the role of each indicator other categories such as moving averages, momentum indicators, volatility indicators are better suited.

### SISO indicators (🔢 🔢)

A **SISO** indicator takes one simple observation (price of an asset, volume of assets traded...) and output just one value for this observation.

`SMA`, `EMA` are good examples of such indicator category (but also most of others moving average indicators).

### SIMO indicators (🔢 Ⓜ️)

The very famous `BB` (Bollinger Bands developed by financial analyst John Bollinger) indicator is an example of **SIMO** indicator. Like a SISO indicator it takes one simple value at a time. But contrary to SISO indicator, SIMO indicators generate several values at a time (upper band, central value, lower band in the case of Bollinger Bands indicator).

### MISO indicators (🕯️ 🔢)

IncTA have also some **MISO** indicators ie indicators which takes several values at a time. It can be candlestick OHLCV data for example. Average True Range (ATR) is an example of such an indicator. It's the average of true ranges over the specified period. ATR measures volatility, taking into account any gaps in the price movement. It was developed by a very prolific author named J. Welles Wilder (also author of RSI, ParabolicSAR and ADX).

### MIMO indicators (🕯️ Ⓜ️)

The last implementation type of indicator are **MIMO** indicators ie indicator which take several values at a time (such a candlestick data) and ouput several values at a time. Stochastic oscillator (`Stoch` also known as KD indicator) is an example of such indicator implementation category). It was developed in the late 1950s by a technical analyst named Georges Lane. This method attempts to predict price turning points by comparing the closing price of a security to its price range. Such indicator ouputs 2 values at a time : k and d.

## Steps to implement your own indicator

1. First step to implement your own indicator is to **categorized** it in the SISO, SIMO, MISO, MIMO category.
2. Look at **indicator dependencies** and try to find out an existing indicator of similar category with similar features used.
3. **Watch existing code** of an indicator of a similar category with quite similar dependencies.
4. Copy file into `src\indicators` directory with same name for `struct` and filename (that's important for tests)
5. Increment number of indicators in `test_indicators_interface.jl`
    
    `@test length(files) == ...  # number of indicators`

6. Create unit tests (in the correct category) and ensure they are passing.
