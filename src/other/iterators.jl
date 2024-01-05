using IncTA
using IncTA: TechnicalIndicator
using IncTA.SampleData: OPEN_TMPL, HIGH_TMPL, LOW_TMPL, CLOSE_TMPL, VOLUME_TMPL, DATE_TMPL


mutable struct TechnicalIndicatorIterator{T, I}
    indicator_type::T
    args::Tuple
    kwargs::Base.Pairs
    iterable_input::I  # should be iterable
    indicator_instance::TechnicalIndicator

    function TechnicalIndicatorIterator(indicator_type, iterable_input, args...; kwargs...)
        ind = indicator_type{eltype(iterable_input)}(args...; kwargs...)
        new{typeof(indicator_type), typeof(iterable_input)}(indicator_type, args, kwargs, iterable_input, ind)
    end

end

function Base.iterate(itr::TechnicalIndicatorIterator, state=0)
    iter_result = iterate(itr.iterable_input, state)
    return iter_result
    #if state < 0
    #    
    #end
    #println(itr)
    #iter_result = iterate(itr.iterable_input)
    #while iter_result !== nothing
    #    (element, state) = iter_result
    #    #println(state)
    #    #fit!(itr.indicator_instance, element)
    #    #println(element, "\t", value(itr.indicator_instance))
    #    #return value(itr.indicator_instance)
    #    iter_result = iterate(itr.iterable_input, state)
    #end
    #=
    iter_result = iterate(itr.input, state)
    if iter_result !== nothing
        println("not")
        println(iter_result)
        #return ()
    else
        return nothing
    end
    =#
end

Base.length(itr::TechnicalIndicatorIterator) = length(itr.iterable_input)

#Base.IteratorSize(::Type{TechnicalIndicatorIterator})



# === Usage


#itr = TechnicalIndicatorIterator(SMA{Float64}(), CLOSE_TMPL)

#itr = TechnicalIndicatorIterator(SMA, CLOSE_TMPL, args..., kwargs...)
itr = TechnicalIndicatorIterator(SMA, CLOSE_TMPL; period = 3)

println("First iteration")
for val in itr
    println(val)
end

println("")

println("Second iteration")
for val in itr
    println(val)
end

println("")

println("Third iteration with collect")
println(collect(itr))
