# Inside make.jl
push!(LOAD_PATH,"../src/")
using IncTA
using Documenter
makedocs(
         sitename = "IncTA.jl",
         modules  = [IncTA],
         pages=[
                "Home" => "index.md"
               ])
#deploydocs(;
#    repo="github.com/femtotrader/IncTA.jl",
#)
