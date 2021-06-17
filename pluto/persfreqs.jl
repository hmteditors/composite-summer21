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

# ╔═╡ 0268a63a-368b-453e-9ee6-e5d001945e9a
md"(The hidden cells above configure the notebook for use with Pluto 0.15 or later.)"

# ╔═╡ b6455bcc-6efe-4604-ad1e-c2df66b3997a
md"""Number to show: $(@bind lmt Slider(15:500; default=20, show_value=true))"""

# ╔═╡ 547a011b-ecb6-4ec7-a493-10029435f9b6
md"> Functions to count and plot data"

# ╔═╡ 8dd35bdf-d3e0-478a-a57d-54a98fefcbe7
function plotcount(counts, labels, termlimit)
	lim = termlimit > length(counts) ? length(counts) : termlimit
	xtix = (1:lim, labels[1:lim])
	bar(counts[1:lim], xticks=xtix, xrotation=45, xlabel="Person", label="Occurrences", bar_width=0.7)
end

# ╔═╡ 1270b3f9-c1ec-4711-b25c-fe404c4634c3
# Compose sorted count of values in the :token field of a DataFrame
function wordcounts(tokendf)
	tkns = map(s -> lowercase(s), tokendf[:, :person])
	tkndf = DataFrame(token = tkns)
	tkncounts = groupby(tkndf, :token)

	prs = []
	for k in keys(tkncounts)
    	push!(prs, (nrow(tkncounts[k]), k.token, ))
	end
	histdata = sort(prs; rev=true)
end

# ╔═╡ ac59e702-268f-4fed-b596-ecf617a7ffaa
md"> Data"

# ╔═╡ e60e33de-ae75-473c-8d0b-49c97af5b7f0
# URL for full index of personal names
idxurl = "https://raw.githubusercontent.com/hmteditors/composite-summer21/main/data/persnameidx.cex"

# ╔═╡ 6acf8d5b-0682-4f3b-9485-f63adc56f6b3
# Read token index into a DataFrame
df = CSV.File(HTTP.get(idxurl).body) |> DataFrame

# ╔═╡ b139ef55-ba92-486e-9615-0f92136ba574
# Sorted pairs of count, term
counttuples = wordcounts(df)

# ╔═╡ c18c230e-4587-4863-abd3-c2b5cd76c11d
# Sorted list of tokens
labelurns = map(pr -> pr[2], counttuples)

# ╔═╡ 6932c8d8-a011-420b-be45-d2fcc2fca4da
# Sorted list of frequencies
counts = map(pr -> pr[1], counttuples)

# ╔═╡ 4b4ab934-cf6f-11eb-0ce5-5bfeda45ec58
md"""> ## Frequencies of personal names


See counts in books 8-10 for **$(length(counts))** personal names.

Use the slider to choose how many names to display.
"""

# ╔═╡ 9c412fce-2064-4227-8e11-76c06d50058c
authurl  = "https://raw.githubusercontent.com/homermultitext/hmt-authlists/master/data/hmtnames.cex"

# ╔═╡ 83799089-1f4f-4c91-98bb-7458dd67b416
authdf = CSV.File(HTTP.get(authurl).body; delim = "#", header = 2) |> DataFrame

# ╔═╡ 96c92572-70b1-4bcb-969b-17f00ecd5f4b
function labelforurn(u)
	matched = filter( r -> r.urn == u, authdf)
	if nrow(matched) < 1
		u
	else
		matched[1,:label]
	end
end

# ╔═╡ 94cd7053-8ebe-48b4-a2d8-e1c979bc0df4
# Sorted list of tokens
labels = map(pr -> labelforurn(pr[2]), counttuples)


# ╔═╡ d6f01465-0d57-41cc-b42f-bbeccc53fcc6
plotcount(counts, labels,lmt)

# ╔═╡ Cell order:
# ╟─c04eed94-7b45-41a5-81a8-21d8f390bef1
# ╟─67421fba-f2b9-43d5-bff5-2624da81d1c5
# ╟─0268a63a-368b-453e-9ee6-e5d001945e9a
# ╟─4b4ab934-cf6f-11eb-0ce5-5bfeda45ec58
# ╟─b6455bcc-6efe-4604-ad1e-c2df66b3997a
# ╟─d6f01465-0d57-41cc-b42f-bbeccc53fcc6
# ╟─547a011b-ecb6-4ec7-a493-10029435f9b6
# ╟─8dd35bdf-d3e0-478a-a57d-54a98fefcbe7
# ╟─1270b3f9-c1ec-4711-b25c-fe404c4634c3
# ╟─ac59e702-268f-4fed-b596-ecf617a7ffaa
# ╟─b139ef55-ba92-486e-9615-0f92136ba574
# ╟─94cd7053-8ebe-48b4-a2d8-e1c979bc0df4
# ╟─96c92572-70b1-4bcb-969b-17f00ecd5f4b
# ╟─c18c230e-4587-4863-abd3-c2b5cd76c11d
# ╟─6932c8d8-a011-420b-be45-d2fcc2fca4da
# ╟─e60e33de-ae75-473c-8d0b-49c97af5b7f0
# ╟─6acf8d5b-0682-4f3b-9485-f63adc56f6b3
# ╟─9c412fce-2064-4227-8e11-76c06d50058c
# ╟─83799089-1f4f-4c91-98bb-7458dd67b416
