module IncTA

    export SMA, EMA

    using DataStructures

    abstract type AbstractIncTAIndicator end

    function Base.append!(ind::T, values) where {T <: AbstractIncTAIndicator}
        for value in values
            push!(ind, value)
        end
    end

    include("SMA.jl")
    include("EMA.jl")

end
