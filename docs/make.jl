# Inside make.jl
push!(LOAD_PATH, "../src/")
using OnlineTechnicalIndicators
using Documenter
makedocs(
    sitename = "OnlineTechnicalIndicators.jl",
    modules = [OnlineTechnicalIndicators],
    pages = [
        "Home" => "index.md",
        "Package Features" => "features.md",
        "Install" => "install.md",
        "Usage" => "usage.md",
        "Indicators support" => "indicators_support.md",
        "Learn more about usage" => "usage_more.md",
        "Examples" => "examples.md",
        "Internals" => "internals.md",
        "Implementing your own indicator" => "implementing_your_indic.md",
        "API" => "api.md",
        "Projects" => "projects.md"
    ],
)
deploydocs(; repo = "github.com/femtotrader/OnlineTechnicalIndicators.jl")
