### A Pluto.jl notebook ###
# v0.19.40

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 3fd38d00-d413-11ee-35a1-a9c997e0c8fe
begin
	import Pkg
	Pkg.activate(mktempdir())
	Pkg.add([
		Pkg.PackageSpec(url = "https://github.com/femtotrader/OnlineTechnicalIndicators.jl"),
	])
	Pkg.add(["Random", "PlutoUI", "Plots", "DataStructures"])
	using PlutoUI, Plots, DataStructures
	using Dates
	gr()
	using Random
	using OnlineTechnicalIndicators
	using OnlineTechnicalIndicators: StatLag
end

# ╔═╡ f78dc6f0-f725-4829-bda4-827b96bf1517
md"""# Feed OnlineTechnicalIndicators indicators with live random data"""

# ╔═╡ 72e8c266-b3d4-45ad-be3f-36f74a9e3105
begin
	ticks_per_sec = 20
	ΔT_s = 1 / ticks_per_sec
	ΔT = Dates.Millisecond(round(ΔT_s * 1_000))
	last_time = [0.0]
	buffsize = 200
	
	cb_dt = CircularBuffer{DateTime}(buffsize)
	cb_price = CircularBuffer{Float64}(buffsize)
	cb_volume = CircularBuffer{Float64}(buffsize)
	cb_framerate = CircularBuffer{Float64}(buffsize)

	dt_now = now(Dates.UTC)
	append!(cb_dt, dt_now - buffsize * ΔT:ΔT:dt_now)

	fill!(cb_price, 1000.0)
	fill!(cb_volume, 0.0)
	
	ma_fast = StatLag(SMA{Float64}(period=3), buffsize)
	ma_slow = StatLag(SMA{Float64}(period=21), buffsize)
	rsi_fast = StatLag(RSI{Float64}(period=9), buffsize)
	rsi_slow = StatLag(RSI{Float64}(period=14), buffsize)
	for i in 1:buffsize
		fit!(ma_fast, 0.0)
		fit!(ma_slow, 0.0)
		fit!(rsi_fast, 0.0)
		fit!(rsi_slow, 0.0)
	end

	rng = Random.GLOBAL_RNG
	fill!(cb_framerate, 0.0)
end

# ╔═╡ 3b5db701-72c9-4bba-8ea5-7b1d69217c4e
@bind ticks Clock(ΔT_s, true)

# ╔═╡ 3e4843e6-fcd6-4b7f-bcdc-9fb412aba795
begin
	ticks

	price_plt = plot(cb_dt, cb_price, label="price", leg=:left, color=:cyan4)
	plot!(cb_dt, value.(value(ma_fast.lag)), label="ma_fast", color=:red)
	plot!(cb_dt, value.(value(ma_slow.lag)), label="ma_slow", color=:green)
	#p = twinx()
	#bar!(cb_dt, cb_volume, label="volume", alpha=0.2)

	volume_plt = plot(bar(cb_dt, cb_volume, label="volume", leg=:left, alpha=0.2))

	rsi_plt = plot(cb_dt, value.(value(rsi_fast.lag)), label="rsi_fast", color=:red, leg=:left, ylims=(0, 100))
	hline!([80], label="rsi_up", color=:grey)
	hline!([20], label="rsi_down", color=:grey)
	plot!(cb_dt, value.(value(rsi_slow.lag)), label="rsi_slow", color=:green)

	framerate_plt = plot(cb_dt, cb_framerate, label="framerate", leg=:left)

	#plot(price_plt, rsi_plt, framerate_plt, layout=(4, 1))
	plot(price_plt, volume_plt, rsi_plt, framerate_plt, layout=(4, 1))
end

# ╔═╡ 1a842954-19fa-4ceb-8271-093651063150
begin
	ticks
	price = cb_price[end] + randn()
	push!(cb_price, price)

	volume = rand(rng, 0:0.1:100)
	push!(cb_volume, volume)

	fit!(ma_fast, price)
	fit!(ma_slow, price)
	fit!(rsi_fast, price)
	fit!(rsi_slow, price)
	
	dt = now(Dates.UTC)
	push!(cb_dt, dt)

	new_time = datetime2unix(dt)
	delta = new_time - last_time[1]
	last_time[1] = new_time
	push!(cb_framerate, 1 / delta)
end;

# ╔═╡ Cell order:
# ╠═f78dc6f0-f725-4829-bda4-827b96bf1517
# ╠═3fd38d00-d413-11ee-35a1-a9c997e0c8fe
# ╠═72e8c266-b3d4-45ad-be3f-36f74a9e3105
# ╠═3b5db701-72c9-4bba-8ea5-7b1d69217c4e
# ╠═3e4843e6-fcd6-4b7f-bcdc-9fb412aba795
# ╠═1a842954-19fa-4ceb-8271-093651063150
