# IncTA internals

## Sub-indicator(s)

An indicator *can* be composed *internally* of sub-indicator(s). Input values catched by `fit!` calls are transmitted to each `sub_indicators` to be processed to `_calculate_new_value` function which calculates value of indicator output.

Example: Bollinger Bands (`BB`) indicator owns 2 internal sub-indicators
- `central_band` which is a simple moving average of prices,
- `std_dev` which is standard deviation of prices.

## Composing new indicators

### Indicators chaining

All indicators come with a great feature named **indicators chaining**. It's like building new indicator with Lego™ bricks.

Example:

- `DEMA` : **2** `EMA` chained together
- `TEMA` : **3** `EMA` chained together

### Filtering and transforming input

Thanks to this indicator chaining feature it's possible to **compose more complex indicators** on top of the existing and simpler ones.

A mechanism for **filtering and transforming** input of an indicator which is feeded by an another one (using generally anonymous functions) have also be implemented.

Input of an indicator can be filtered / transformed to be used internaly by sub-indicators or be processed directly by `_calculate_new_value` function.

### Moving average factory

- `SMA`, `EMA`, ... are moving average.

Most complex indicators uses in their **original form** SMA or EMA as default moving average.

In some markets they can perform better by using instead **an other kind of moving average**.

A **moving average factory** have been implemented 

This kind of indicators have a `ma` parameter in order to **bypass** their default moving average uses.
