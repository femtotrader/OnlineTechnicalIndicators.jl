# Inside make.jl
push!(LOAD_PATH, "../src/")
using IncTA
using Documenter
makedocs(
    sitename = "IncTA.jl",
    modules = [IncTA],
    pages = [
        "Home" => "index.md",
        "Package Features" => "features.md",
        "Install" => "install.md",
        "Usage" => "usage.md",
        "Indicators support" => "indicators_support.md",
        "Learn more about usage" => "usage_more.md",
        "Internals" => "internals.md",
        "Implementing your own indicator" => "implementing_your_indic.md",
    ],
)
deploydocs(; repo = "github.com/femtotrader/IncTA.jl")
