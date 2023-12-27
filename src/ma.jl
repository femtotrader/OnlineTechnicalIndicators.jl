struct MAFactory
    T::Type
end

function (f::MAFactory)(ma::Type{MA}, period) where {MA <: OnlineStat}
    return ma{f.T}(period=period)
end
