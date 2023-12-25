### A Pluto.jl notebook ###
# v0.19.35

using Markdown
using InteractiveUtils

# ╔═╡ a5921210-a1ff-11ee-3a16-17cde0f76b44
begin
	using Pkg
	cd(joinpath(@__DIR__, ".."))
	Pkg.activate(".")
	using FlexPoints
end

# ╔═╡ aa806ed0-d52f-46a4-a356-f336b3abc0ff
html"""<style>
main {
    max-width: 850px;
}
"""

# ╔═╡ c0e53d44-04ea-4c87-8e58-fb16ac07e082
MIT_BIH_ARRHYTHMIA_2K

# ╔═╡ 9d4e4dd5-2516-4d96-9d1b-638bf0456a31
MIT_BIH_ARRHYTHMIA_5K

# ╔═╡ b9f17831-40ba-4a66-8761-0e108923f567
MIT_BIH_ARRHYTHMIA_FULL

# ╔═╡ 7d58c877-acfa-4dfe-bc1d-ce5c6073f857
# ╠═╡ show_logs = false
@time results2k = benchmark(MIT_BIH_ARRHYTHMIA_2K)

# ╔═╡ c2a29ac7-5726-4bc6-9b93-22fbb4972f01
# ╠═╡ show_logs = false
@time results5k = benchmark(MIT_BIH_ARRHYTHMIA_5K)

# ╔═╡ 52aae532-e39b-48f1-a8ad-c5879648f6e5
@time resultsfull = benchmark(MIT_BIH_ARRHYTHMIA_FULL)

# ╔═╡ Cell order:
# ╠═a5921210-a1ff-11ee-3a16-17cde0f76b44
# ╠═aa806ed0-d52f-46a4-a356-f336b3abc0ff
# ╠═c0e53d44-04ea-4c87-8e58-fb16ac07e082
# ╠═9d4e4dd5-2516-4d96-9d1b-638bf0456a31
# ╠═b9f17831-40ba-4a66-8761-0e108923f567
# ╠═7d58c877-acfa-4dfe-bc1d-ce5c6073f857
# ╠═c2a29ac7-5726-4bc6-9b93-22fbb4972f01
# ╠═52aae532-e39b-48f1-a8ad-c5879648f6e5
