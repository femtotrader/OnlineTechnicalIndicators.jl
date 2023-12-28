struct MAFactory
    T::Type
end

function (f::MAFactory)(ma::Type{MA}, period) where {MA <: TechnicalIndicator}
    return ma{f.T}(period=period)
end
