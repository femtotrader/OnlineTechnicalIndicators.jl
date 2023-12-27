function MAFactory(::Type{MA}, T::Type, period) where {MA}
    return MA{T}(period=period)
end
