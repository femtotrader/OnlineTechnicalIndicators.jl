struct MAFactory
    T::Type
end

function (f::MAFactory)(ma::Type{MA}, args...; kwargs...) where {MA<:TechnicalIndicator}
    return ma{f.T}(args...; kwargs...)
end
