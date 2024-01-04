using TSFrames

using IncTA
using IncTA: TechnicalIndicator
using IncTA.SampleData: OPEN_TMPL, HIGH_TMPL, LOW_TMPL, CLOSE_TMPL, VOLUME_TMPL, DATE_TMPL
const OHLCV_TSFRAME = TSFrame(
    [OPEN_TMPL HIGH_TMPL LOW_TMPL CLOSE_TMPL VOLUME_TMPL],
    DATE_TMPL,
    colnames = [:Open, :High, :Low, :Close, :Volume],
)


function apply_func_single_input(
    ts::TSFrame,
    IND::Type{I},
    input_field::Symbol,
    rename_flds::Vector{Symbol},
    args...;
    kwargs...,
) where {I<:TechnicalIndicator}
    vct = ts[:, input_field]
    ind = IND{eltype(vct)}(args...; kwargs...)
    mapped = map(val -> value(fit!(ind, val)), vct)
    return TSFrame(collect(mapped), index(ts), colnames = rename_flds)
end


SMA(x::TSFrame, input_field = :Close, args...; kwargs...) =
    apply_func_single_input(x, IncTA.SMA, input_field, [:SMA], args...; kwargs...)



SMA(OHLCV_TSFRAME)
