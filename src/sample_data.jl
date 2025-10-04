module SampleData

const OPEN_TMPL = [
    10.81,
    10.58,
    10.07,
    10.58,
    10.56,
    10.4,
    10.74,
    10.16,
    10.29,
    9.4,
    9.62,
    9.35,
    8.64,
    8.8,
    8.31,
    7.56,
    7.61,
    7.04,
    8.56,
    9.26,
    8.95,
    9.31,
    9.1,
    8.51,
    8.42,
    8.3,
    7.87,
    7.94,
    8.1,
    8.08,
    7.49,
    7.4,
    8.09,
    8.86,
    8.81,
    9.16,
    9.69,
    9.45,
    9.18,
    9.4,
    9.0,
    9.11,
    9.23,
    9.34,
    8.49,
    9.3,
    10.23,
    10.29,
    10.77,
    10.28,
]
const HIGH_TMPL = [
    11.02,
    10.74,
    10.65,
    11.05,
    10.7,
    10.73,
    11.16,
    10.86,
    10.29,
    10.8,
    9.62,
    9.35,
    9.43,
    8.91,
    8.84,
    7.82,
    7.61,
    8.84,
    9.42,
    9.5,
    9.29,
    9.4,
    9.1,
    8.51,
    8.95,
    8.7,
    8.95,
    8.75,
    8.39,
    8.28,
    7.58,
    8.17,
    8.83,
    9.2,
    9.25,
    10.1,
    9.88,
    9.65,
    9.32,
    9.4,
    9.01,
    9.36,
    9.46,
    9.34,
    9.4,
    10.5,
    10.3,
    10.86,
    10.77,
    10.39,
]
const LOW_TMPL = [
    9.9,
    9.78,
    9.5,
    10.47,
    10.26,
    10.4,
    10.12,
    9.91,
    9.4,
    9.11,
    9.12,
    8.5,
    8.55,
    8.21,
    7.34,
    7.53,
    6.5,
    7.04,
    8.15,
    8.72,
    8.6,
    8.89,
    8.14,
    8.24,
    8.06,
    7.7,
    7.87,
    7.94,
    8.0,
    7.37,
    7.49,
    7.38,
    8.05,
    8.79,
    8.67,
    9.16,
    8.9,
    9.17,
    8.6,
    8.92,
    8.99,
    9.11,
    9.11,
    8.43,
    8.42,
    9.26,
    10.0,
    10.19,
    10.15,
    9.62,
]
const CLOSE_TMPL = [
    10.5,
    9.78,
    10.46,
    10.51,
    10.55,
    10.72,
    10.16,
    10.25,
    9.4,
    9.5,
    9.23,
    8.5,
    8.8,
    8.33,
    7.53,
    7.61,
    6.78,
    8.6,
    9.21,
    8.95,
    9.22,
    9.1,
    8.31,
    8.37,
    8.3,
    7.78,
    8.05,
    8.1,
    8.08,
    7.49,
    7.58,
    8.17,
    8.83,
    8.91,
    9.2,
    9.76,
    9.42,
    9.3,
    9.32,
    9.04,
    9.0,
    9.33,
    9.34,
    8.49,
    9.21,
    10.15,
    10.3,
    10.59,
    10.23,
    10.0,
]

const VOLUME_TMPL = [
    55.03,
    117.86,
    301.04,
    157.94,
    39.96,
    42.87,
    191.95,
    55.09,
    131.58,
    249.69,
    77.75,
    197.33,
    107.93,
    35.86,
    269.05,
    34.18,
    209.1,
    241.95,
    162.86,
    112.99,
    66.53,
    87.5,
    349.14,
    44.38,
    45.79,
    139.4,
    46.49,
    27.45,
    16.44,
    83.54,
    15.08,
    60.72,
    140.22,
    171.6,
    209.26,
    199.2,
    165.77,
    61.71,
    29.73,
    12.93,
    4.14,
    12.45,
    42.23,
    133.29,
    120.02,
    255.3,
    111.55,
    108.27,
    48.29,
    81.66,
]

const CLOSE_EQUAL_VALUES_TMPL = repeat([10.46], length(CLOSE_TMPL))

using Dates
const DATE_TMPL =
    collect(range(Dates.Date(2020, 1, 1), step = Dates.Day(1), length = length(CLOSE_TMPL)))

using OnlineTechnicalIndicators: OHLCVFactory
const OHLCV_FACTORY =
    OHLCVFactory(OPEN_TMPL, HIGH_TMPL, LOW_TMPL, CLOSE_TMPL; volume = VOLUME_TMPL)  # time is missing here
const V_OHLCV = collect(OHLCV_FACTORY)


const CT_OHLCV = (
    Index = DATE_TMPL,
    Open = OPEN_TMPL,
    High = HIGH_TMPL,
    Low = LOW_TMPL,
    Close = CLOSE_TMPL,
    Volume = VOLUME_TMPL,
)

const RT_OHLCV = [
    (
        Index = DATE_TMPL[i],
        Open = OPEN_TMPL[i],
        High = HIGH_TMPL[i],
        Low = LOW_TMPL[i],
        Close = CLOSE_TMPL[i],
        Volume = VOLUME_TMPL[i],
    ) for i in eachindex(CLOSE_TMPL)
]


using Tables

# const TAB_OHLCV = Tables.table([DATE_TMPL OPEN_TMPL HIGH_TMPL LOW_TMPL CLOSE_TMPL VOLUME_TMPL]; header=[:Index, :Open, :High, :Low, :Close, :Volume])

"""
    TabOHLCV

Sample OHLCV data table implementing the Tables.jl interface.

Contains template financial data with Date indices and Float64 price/volume values.

# Fields
- `Index::Vector{Date}`: Vector of dates
- `Open::Vector{Float64}`: Opening prices
- `High::Vector{Float64}`: High prices
- `Low::Vector{Float64}`: Low prices
- `Close::Vector{Float64}`: Closing prices
- `Volume::Vector{Float64}`: Trading volumes
"""
struct TabOHLCV
    Index::Vector{Date}
    Open::Vector{Float64}
    High::Vector{Float64}
    Low::Vector{Float64}
    Close::Vector{Float64}
    Volume::Vector{Float64}
    TabOHLCV() = new(DATE_TMPL, OPEN_TMPL, HIGH_TMPL, LOW_TMPL, CLOSE_TMPL, VOLUME_TMPL)
end
Tables.istable(::Type{<:TabOHLCV}) = true
Base.names(table::TabOHLCV) = [:Index, :Open, :High, :Low, :Close, :Volume]
Tables.schema(table::TabOHLCV) =
    Tables.Schema(names(table), [Dates.Date, Float64, Float64, Float64, Float64, Float64])
Tables.columnaccess(::Type{<:TabOHLCV}) = true
Tables.columns(table::TabOHLCV) =
    (; (colname => getfield(table, colname) for colname in fieldnames(typeof(table)))...)

const TAB_OHLCV = TabOHLCV()

end
