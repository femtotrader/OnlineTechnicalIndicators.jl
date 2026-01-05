### A Pluto.jl notebook ###
# v0.20.21

using Markdown
using InteractiveUtils

# ╔═╡ e5bc1ac4-415c-40e8-b27c-0af01c834ede
begin
	import Pkg;
	#Pkg.activate("..");
	#Pkg.add("OnlineTechnicalIndicators")
	Pkg.develop("OnlineTechnicalIndicators")
end

# ╔═╡ b22340af-7262-480e-a5dc-74e73a39bddc
begin
	using OnlineTechnicalIndicators.Indicators: SMA, BB, ATR, Stoch
	using OnlineTechnicalIndicators.Indicators: fit!, value
	using OnlineTechnicalIndicators.Candlesticks: OHLCV
	using OnlineTechnicalIndicators.SampleData: CLOSE_TMPL, V_OHLCV
end

# ╔═╡ c095cbc9-93fc-4f30-b4ac-19e1bcbc2fef
using MarketData

# ╔═╡ 988bdc26-1563-4fe2-9d12-9f96e5ad991c
using TSFrames

# ╔═╡ 60ee2452-d281-4456-bc87-b53be3b232f7
md"""# OnlineTechnicalIndicators.jl tutorial notebook"""

# ╔═╡ c679d3bf-6611-4e33-88ae-036cf6177be9
md"""## Using OnlineTechnicalIndicators indicators feeding one value at a time with `fit!`


The following examples demonstrate how to use an OnlineTechnicalIndicators technical analysis indicator in an incremental approach feeding new data one observation at a time.

You first need to import [OnlineTechnicalIndicators.jl](https://github.com/femtotrader/OnlineTechnicalIndicators.jl) library.
"""

# ╔═╡ d8b1703a-5847-4b4f-b1c8-5c661b34ddc9
md"""and also some sample data"""

# ╔═╡ d00eabf0-947f-4be7-b802-a7880ce87b01
md"""Import also Plots.jl for plotting"""

# ╔═╡ 2d08ee40-26e9-43ca-bb5e-37282a790441
# using Plots

# ╔═╡ b0e5be4f-c3d9-4159-a97b-b7ad9bd13153
md"""### Show close prices"""

# ╔═╡ 99b0bf9b-2dac-4aa6-b299-048a87e13cf7
CLOSE_TMPL

# ╔═╡ 68627c9a-e9e6-439e-adca-9a491aaae7f5
md"""### Calculate SMA (simple moving average)"""

# ╔═╡ 13aff320-c058-4436-86e3-b9465ea93b20
begin
    function show_sma1()
        ind = SMA{Float64}(period = 3)  # this is a SISO indicator
        for p in CLOSE_TMPL
            fit!(ind, p)
            println(value(ind))
        end
    end
    show_sma1()
end

# ╔═╡ 01fd1937-d9d3-4423-a6aa-1afb3b35be65


# ╔═╡ 04374981-a626-413d-9476-1b7c6ec03542


# ╔═╡ af3df771-caa4-4daa-b40e-fe11bd2ddb84


# ╔═╡ 28e0fb3a-f5fa-407f-981a-84ccc80b074d
md"""### Calculate BB (Bollinger bands)"""

# ╔═╡ 8c44d1db-f905-4621-b0e9-ca21d5b85ebb
begin
    function show_bb1()
        ind = BB{Float64}(period = 3)  # this is a SIMO indicator
        for p in CLOSE_TMPL
            fit!(ind, p)
            println(value(ind))
        end
    end
    show_bb1()
end

# ╔═╡ 2f8045ca-97ae-4c07-9a46-74be7cfd6632
md"""### Show candlestick data"""

# ╔═╡ c1716197-3679-47f2-a9c3-16793221ae4e
V_OHLCV

# ╔═╡ a3349049-4e56-43d4-a469-5354442695db
md"""### Calculate ATR (Average true range)"""

# ╔═╡ fa335c82-947d-477e-ae72-bd627061ed21
begin
    function show_atr1()
        ind = ATR{OHLCV}(period = 3)  # this is a MISO indicator
        for candle in V_OHLCV
            fit!(ind, candle)
            println(value(ind))
        end
    end
    show_atr1()
end

# ╔═╡ 0944670f-06c2-4135-9383-b73af60e7386
md"""### Calculate Stoch (Stochastic)"""

# ╔═╡ 07a3c533-b3f4-40e9-a1a8-0f2560fc5f41
begin
    function show_stoch1()
        ind = Stoch{OHLCV{Missing,Float64,Float64}}(period = 3)  # this is a MIMO indicator
        for candle in V_OHLCV
            fit!(ind, candle)
            println(value(ind))
        end
    end
    show_stoch1()
end

# ╔═╡ 77e61b06-39a9-41c2-a2bc-6e00f83b49d0
md"""## Using OnlineTechnicalIndicators indicators with `TSFrames.TSFrame`


The following examples demonstrate how to use an OnlineTechnicalIndicators technical analysis indicator by feeding a compatible Tables.jl table such as TSFrame.

You first need to import some aditional libraries:

- [`MarketData.jl`](https://github.com/JuliaQuant/MarketData.jl) : to get some random data
- [`TSFrames.jl`](https://github.com/xKDR/TSFrames.jl) : to get a kind of DataFrame structure which is specialized for timeseries
"""

# ╔═╡ c79c467b-2032-4d07-a4fb-3b1f264974df
md"""### Get input data

Get a `TimeSeries.TimeArray` with random prices and volume
"""

# ╔═╡ dc2dd86f-4b8f-4d92-8ff4-e2db51c6cfab
begin
    ta = random_ohlcv()
    ta
end

# ╔═╡ d5171332-5c3a-45b1-bb11-baf021aecc99
md"""Converts a `TimeSeries.TimeArray` to `TSFrames.TSFrame`"""

# ╔═╡ f82172a7-c3ee-46b8-9486-73f28d8dada5
ts = TSFrame(ta)

# ╔═╡ 851fd819-2cfa-442e-9f59-0d5e133df44a
md"""### Calculate Simple Moving Average (SMA) of close prices"""

# ╔═╡ e58aa83c-1fd5-413f-82a3-f0a5b48d39e5
SMA(ts; period = 3)

# ╔═╡ 661892d4-7aba-492a-82c4-5f0b755bd229
# plot(ts)

# ╔═╡ 19a0e845-8b18-4bd5-900c-b1c7298d190f
md"""### Calculate Simple Moving Average (SMA) of open prices"""

# ╔═╡ dabf9795-c864-4f5a-991c-e27839c0891f
SMA(ts; period = 3, default = :Open)

# ╔═╡ 76932a79-a236-4db0-aa52-50b249d628c8
md"""### Calculate BB (Bollinger bands)"""

# ╔═╡ eb1345d9-583a-4a74-b05a-fc46c801d6ca
BB(ts; period = 3)

# ╔═╡ d4647c65-67ca-4b06-980b-ad18d271ad94
md"""### Calculate ATR (Average true range)"""

# ╔═╡ 07be4dc2-04ca-41f5-8ee2-9261d95351b9
ATR(ts; period = 3)

# ╔═╡ 053a554a-f456-4c07-b43b-116e0bf68dbe
md"""### Calculate Stoch (Stochastic)"""

# ╔═╡ 28363f93-df0a-4ba0-a892-2cb1e8433966
Stoch(ts; period = 3)

# ╔═╡ Cell order:
# ╟─60ee2452-d281-4456-bc87-b53be3b232f7
# ╠═e5bc1ac4-415c-40e8-b27c-0af01c834ede
# ╟─c679d3bf-6611-4e33-88ae-036cf6177be9
# ╟─d8b1703a-5847-4b4f-b1c8-5c661b34ddc9
# ╠═b22340af-7262-480e-a5dc-74e73a39bddc
# ╟─d00eabf0-947f-4be7-b802-a7880ce87b01
# ╠═2d08ee40-26e9-43ca-bb5e-37282a790441
# ╟─b0e5be4f-c3d9-4159-a97b-b7ad9bd13153
# ╠═99b0bf9b-2dac-4aa6-b299-048a87e13cf7
# ╠═68627c9a-e9e6-439e-adca-9a491aaae7f5
# ╠═13aff320-c058-4436-86e3-b9465ea93b20
# ╠═01fd1937-d9d3-4423-a6aa-1afb3b35be65
# ╠═04374981-a626-413d-9476-1b7c6ec03542
# ╠═af3df771-caa4-4daa-b40e-fe11bd2ddb84
# ╠═28e0fb3a-f5fa-407f-981a-84ccc80b074d
# ╠═8c44d1db-f905-4621-b0e9-ca21d5b85ebb
# ╟─2f8045ca-97ae-4c07-9a46-74be7cfd6632
# ╠═c1716197-3679-47f2-a9c3-16793221ae4e
# ╠═a3349049-4e56-43d4-a469-5354442695db
# ╠═fa335c82-947d-477e-ae72-bd627061ed21
# ╟─0944670f-06c2-4135-9383-b73af60e7386
# ╠═07a3c533-b3f4-40e9-a1a8-0f2560fc5f41
# ╟─77e61b06-39a9-41c2-a2bc-6e00f83b49d0
# ╠═c095cbc9-93fc-4f30-b4ac-19e1bcbc2fef
# ╠═988bdc26-1563-4fe2-9d12-9f96e5ad991c
# ╟─c79c467b-2032-4d07-a4fb-3b1f264974df
# ╠═dc2dd86f-4b8f-4d92-8ff4-e2db51c6cfab
# ╟─d5171332-5c3a-45b1-bb11-baf021aecc99
# ╠═f82172a7-c3ee-46b8-9486-73f28d8dada5
# ╠═851fd819-2cfa-442e-9f59-0d5e133df44a
# ╠═e58aa83c-1fd5-413f-82a3-f0a5b48d39e5
# ╠═661892d4-7aba-492a-82c4-5f0b755bd229
# ╠═19a0e845-8b18-4bd5-900c-b1c7298d190f
# ╠═dabf9795-c864-4f5a-991c-e27839c0891f
# ╟─76932a79-a236-4db0-aa52-50b249d628c8
# ╠═eb1345d9-583a-4a74-b05a-fc46c801d6ca
# ╟─d4647c65-67ca-4b06-980b-ad18d271ad94
# ╠═07be4dc2-04ca-41f5-8ee2-9261d95351b9
# ╟─053a554a-f456-4c07-b43b-116e0bf68dbe
# ╠═28363f93-df0a-4ba0-a892-2cb1e8433966
