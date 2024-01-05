using OnlineStatsBase
using IncTA
using IncTA: TechnicalIndicator
using IncTA.SampleData: OPEN_TMPL, HIGH_TMPL, LOW_TMPL, CLOSE_TMPL, VOLUME_TMPL, DATE_TMPL


mutable struct TechnicalIndicatorIterator{T, I}
    indicator_type::T
    args::Tuple
    kwargs::Base.Pairs
    iterable_input
    input_iterator #::I  # should be iterable
    indicator_instance::TechnicalIndicator

    function TechnicalIndicatorIterator(indicator_type, iterable_input, args...; kwargs...)
        ind = indicator_type{eltype(iterable_input)}(args...; kwargs...)
        input_iterator = Iterators.Stateful(iterable_input)
        new{typeof(indicator_type), typeof(input_iterator)}(indicator_type, args, kwargs, iterable_input, input_iterator, ind)
    end

end

function Base.iterate(itr::TechnicalIndicatorIterator, state=0)
    iter_result = iterate(itr.input_iterator, state)
    if iter_result !== nothing
        (element, state) = iter_result
        state = nobs(itr.indicator_instance)
        fit!(itr.indicator_instance, element)
        return (value(itr.indicator_instance), state)
    end
end

# Base.eltype(::Type{TechnicalIndicatorIterator}) = Float64
# Base.IteratorEltype(::Type{TechnicalIndicatorIterator}) = Base.HasEltype()
# Base.IteratorSize(::Type{TechnicalIndicatorIterator}) = Base.IsInfinite()

function Iterators.reset!(itr::TechnicalIndicatorIterator)
    Iterators.reset!(itr.input_iterator)
    itr.indicator_instance = itr.indicator_type{eltype(itr.iterable_input)}(itr.args...; itr.kwargs...)
end

Base.length(itr::TechnicalIndicatorIterator) = length(itr.input_iterator)


# === Usage


# SISO indicator

itr = TechnicalIndicatorIterator(SMA, CLOSE_TMPL; period = 3)

println("First iteration")
for (i, val) in enumerate(itr)
    println("$(i): $(val)")
end

println("")

println("Second iteration")
Iterators.reset!(itr)
for (i, val) in enumerate(itr)
    println("$(i): $(val)")
end

println("")

println("Third iteration with collect")
# itr = TechnicalIndicatorIterator(SMA, CLOSE_TMPL; period = 3)
# or
Iterators.reset!(itr)
println(collect(itr))

# SIMO indicator
itr = TechnicalIndicatorIterator(BB, CLOSE_TMPL)
println(collect(itr))