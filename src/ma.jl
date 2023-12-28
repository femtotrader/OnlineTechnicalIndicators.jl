struct MAFactory
    T::Type
end

function (f::MAFactory)(ma::Type{MA}, period, args...; kwargs...) where {MA <: TechnicalIndicator}
    return ma{f.T}(args..., period=period, kwargs...)
end
