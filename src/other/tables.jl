using Tables
using IncTA: ismultiinput

struct TechnicalIndicatorWrapper{T}
    indicator_type::T
    args::Tuple
    kwargs::Base.Pairs
    function TechnicalIndicatorWrapper(indicator_type, args...; kwargs...)
        new{typeof(indicator_type)}(indicator_type, args, kwargs)
    end
end

struct TechnicalIndicatorResults{Ttime,Tout}
    index::Vector
    output::Vector
    function TechnicalIndicatorResults{Ttime,Tout}() where {Ttime,Tout}
        new{Ttime,Tout}(Ttime[], Tout[])
    end
end

function Base.push!(results::TechnicalIndicatorResults, result)
    (tim, val) = result
    push!(results.index, tim)
    push!(results.output, val)
end


function load!(
    table,
    ti_wrap::TechnicalIndicatorWrapper,
    default_field = :Close,
    index_field = :Index,
    candle_fields = [:Open, :High, :Low, :Close],
    volume_field = :Volume,
)
    rows = Tables.rows(table)
    sch = Tables.schema(table)
    _names = sch.names  # name of columns of input

    Ttime =
        index_field ∈ sch.names ? sch.types[argmax((sch.names .== index_field))] : Missing
    Tin =
        default_field ∈ sch.names ? sch.types[argmax((sch.names .== default_field))] :
        throw(ArgumentError("default field `$default_field` not found"))
    if !ismultioutput(ti_wrap.indicator_type)
        Tout = Union{Missing,Tin}
    else
        Tout = Union{Missing,expected_return_type(ti_wrap.indicator_type){Tin}}
    end
    results = TechnicalIndicatorResults{Ttime,Tout}()

    if !ismultiinput(ti_wrap.indicator_type)
        ind = ti_wrap.indicator_type{Tin}(ti_wrap.args...; ti_wrap.kwargs...)
        for row in rows
            println(row)
            tim = index_field ∈ _names ? row[index_field] : missing
            data = row[default_field]
            println(tim, " ", data)
            fit!(ind, data)
            push!(results, (tim, value(ind)))
        end
    else
        ind = ti_wrap.indicator_type{OHLCV}(ti_wrap.args...; ti_wrap.kwargs...)
        for candle_field in candle_fields
            (candle_field ∉ _names) && throw(
                ArgumentError(
                    "field `$candle_field` not found - $candle_fields are expected in input data",
                ),
            )
        end
        for row in rows
            println(row)
            tim = index_field ∈ _names ? row[index_field] : missing
            opn = row[candle_fields[1]]
            hig = row[candle_fields[2]]
            low = row[candle_fields[3]]
            cls = row[candle_fields[4]]
            vol = volume_field ∈ _names ? row[volume_field] : missing
            data = OHLCV(opn, hig, low, cls, volume = vol, time = tim)
            fit!(ind, data)
            push!(results, (tim, value(ind)))
        end
    end
    return results
end
