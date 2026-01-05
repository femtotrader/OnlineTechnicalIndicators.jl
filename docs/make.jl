# Inside make.jl
push!(LOAD_PATH, "../src/")
using OnlineTechnicalIndicators
using OnlineTechnicalIndicators.Indicators
using OnlineTechnicalIndicators.Patterns
using Documenter
makedocs(
    sitename = "OnlineTechnicalIndicators.jl",
    modules = [OnlineTechnicalIndicators, OnlineTechnicalIndicators.Indicators, OnlineTechnicalIndicators.Patterns],
    format = Documenter.HTML(
        size_threshold = 300_000,  # 300KB threshold for large API reference page
    ),
    pages = [
        "Home" => "index.md",
        "Package Features" => "features.md",
        "Install" => "install.md",
        "Usage" => "usage.md",
        "Indicators support" => "indicators_support.md",
        "Pattern Recognition" => [
            "Overview" => "patterns/index.md",
            "Quick Start" => "patterns/quickstart.md",
            "Implementation" => "patterns/implementation.md",
        ],
        "Learn more about usage" => "usage_more.md",
        "Examples" => "examples.md",
        "Internals" => "internals.md",
        "Migration Guide" => "migration.md",
        "Implementing your own indicator" => "implementing_your_indic.md",
        "API" => "api.md",
        "Projects" => "projects.md",
    ],
)
deploydocs(; repo = "github.com/femtotrader/OnlineTechnicalIndicators.jl")
