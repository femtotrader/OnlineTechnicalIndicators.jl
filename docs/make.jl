# Inside make.jl
push!(LOAD_PATH, "../src/")
using OnlineTechnicalIndicators
using OnlineTechnicalIndicators.Candlesticks
using OnlineTechnicalIndicators.Internals
using OnlineTechnicalIndicators.Indicators
using OnlineTechnicalIndicators.Patterns
using Documenter
using DocumenterMermaid
makedocs(
    sitename = "OnlineTechnicalIndicators.jl",
    modules = [OnlineTechnicalIndicators, OnlineTechnicalIndicators.Candlesticks, OnlineTechnicalIndicators.Internals, OnlineTechnicalIndicators.Indicators, OnlineTechnicalIndicators.Patterns],
    warnonly = [:missing_docs],  # Don't fail on missing docs (internal _fit! defined on OnlineStatsBase namespace)
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
        "Architecture & Internals" => [
            "Architecture" => "architecture.md",
            "Project Structure" => "structure.md",
            "Data Flow" => "dataflow.md",
            "Internals" => "internals.md",
        ],
        "Migration Guide" => "migration.md",
        "Implementing your own indicator" => "implementing_your_indic.md",
        "API" => "api.md",
        "Projects" => "projects.md",
    ],
)
deploydocs(; repo = "github.com/femtotrader/OnlineTechnicalIndicators.jl")
