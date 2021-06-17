### A Pluto.jl notebook ###
# v0.14.8

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ c04eed94-7b45-41a5-81a8-21d8f390bef1
begin
	using Pkg
	Pkg.add("CSV")
	Pkg.add("DataFrames")
	Pkg.add("HTTP")
	Pkg.add("Plots")
	Pkg.add("PlutoUI")
	using CSV, DataFrames, HTTP, Plots, PlutoUI
end

# ╔═╡ 67421fba-f2b9-43d5-bff5-2624da81d1c5
plotly()

# ╔═╡ 4b4ab934-cf6f-11eb-0ce5-5bfeda45ec58
md"""> ## Vocabulary frequencies in *scholia*


See counts of most frequent vocabulary in the *scholia* to books 8-10.

Use the slider to choose how many terms to display.
"""

# ╔═╡ b6455bcc-6efe-4604-ad1e-c2df66b3997a
md"""Number of terms to show: $(@bind lmt Slider(15:500; default=20, show_value=true))"""

# ╔═╡ 547a011b-ecb6-4ec7-a493-10029435f9b6
md"> Functions to count and plot data"

# ╔═╡ 8dd35bdf-d3e0-478a-a57d-54a98fefcbe7
function plotcount(counts, labels, termlimit)
	xtix = (1:termlimit, labels[1:termlimit])
	bar(counts[1:lmt], xticks=xtix, xrotation=45, xlabel="Term", label="Number of occurrences", bar_width=0.7)
end

# ╔═╡ 1270b3f9-c1ec-4711-b25c-fe404c4634c3
# Compose sorted count of values in the :token field of a DataFrame
function wordcounts(tokendf)
	tkns = map(s -> lowercase(s), tokendf[:, :token])
	tkndf = DataFrame(token = tkns)
	tkncounts = groupby(tkndf, :token)

	prs = []
	for k in keys(tkncounts)
    	push!(prs, (nrow(tkncounts[k]), k.token, ))
	end
	histdata = sort(prs; rev=true)
end

# ╔═╡ d099f423-5db0-4a62-b81b-dc7dfe5f152d


# ╔═╡ ac59e702-268f-4fed-b596-ecf617a7ffaa
md"> Data"

# ╔═╡ e60e33de-ae75-473c-8d0b-49c97af5b7f0
# URL for full token index
idxurl = "https://raw.githubusercontent.com/hmteditors/composite-summer21/main/data/scholia-tokens.cex"

# ╔═╡ 6acf8d5b-0682-4f3b-9485-f63adc56f6b3
# Read token index into a DataFrame
df = CSV.File(HTTP.get(idxurl).body) |> DataFrame

# ╔═╡ b139ef55-ba92-486e-9615-0f92136ba574
# Sorted pairs of count, term
counttuples = wordcounts(df)

# ╔═╡ 94cd7053-8ebe-48b4-a2d8-e1c979bc0df4
# Sorted list of tokens
labels = map(pr -> pr[2], counttuples)


# ╔═╡ 6932c8d8-a011-420b-be45-d2fcc2fca4da
# Sorted list of frequencies
counts = map(pr -> pr[1], counttuples)

# ╔═╡ d6f01465-0d57-41cc-b42f-bbeccc53fcc6
plotcount(counts, labels,lmt)

# ╔═╡ Cell order:
# ╠═c04eed94-7b45-41a5-81a8-21d8f390bef1
# ╟─67421fba-f2b9-43d5-bff5-2624da81d1c5
# ╟─4b4ab934-cf6f-11eb-0ce5-5bfeda45ec58
# ╟─b6455bcc-6efe-4604-ad1e-c2df66b3997a
# ╟─d6f01465-0d57-41cc-b42f-bbeccc53fcc6
# ╟─547a011b-ecb6-4ec7-a493-10029435f9b6
# ╠═8dd35bdf-d3e0-478a-a57d-54a98fefcbe7
# ╟─1270b3f9-c1ec-4711-b25c-fe404c4634c3
# ╠═d099f423-5db0-4a62-b81b-dc7dfe5f152d
# ╟─ac59e702-268f-4fed-b596-ecf617a7ffaa
# ╟─b139ef55-ba92-486e-9615-0f92136ba574
# ╟─94cd7053-8ebe-48b4-a2d8-e1c979bc0df4
# ╟─6932c8d8-a011-420b-be45-d2fcc2fca4da
# ╟─e60e33de-ae75-473c-8d0b-49c97af5b7f0
# ╟─6acf8d5b-0682-4f3b-9485-f63adc56f6b3
