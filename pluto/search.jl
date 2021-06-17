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

# ╔═╡ 58b9fb4b-64a2-4f89-804e-9042cf8a013d
begin
	using Pkg
	Pkg.activate(pwd() |> dirname)
	Pkg.instantiate()
	using CitableText, CitableCorpus, PolytonicGreek, Dates
	using PlutoUI
	
end

# ╔═╡ 2a260b76-ceb3-11eb-3429-c55e6e1df240
md"""> ### Search text of scholia
>
> Enter text in Greek with no accents.
"""

# ╔═╡ a538c813-8808-4562-b03a-27b0373eb3a8
md"""Search for: $(@bind s TextField())"""

# ╔═╡ aec1ac3d-e4dd-4ba0-834c-e2c13101851e
md"> Search and formatting"

# ╔═╡ 7bbc6e78-d5fe-4046-960a-eee8660ef5b4
# Find index of all ws-delimited "words" in text of a citable node matching s
function matchindices(cn, s)
	wrds = split(cn.text)
	findall(wd -> contains(wd, s) , wrds)
end

# ╔═╡ fc616d86-c81e-4ff2-b695-0795888b3123
function formatted(psgs, s)
    formatted = [
		string("<p>Number of matching passages: ", "<b>", length(psgs), "</b></p>"),
		"<ol>"
	]
	for psg in psgs
        urn = string("<b>", psg.urn.urn, "</b>")
		indices = matchindices(psg, s)
		words = split(psg.text)
		for i in indices
			words[i] = """<span class="hl">$(words[i])</span>"""
		end
        #txt = replace(psg.text, s => """<span class="hl">$s</span>""")
        push!(formatted, string("<li>", urn, " ", join(words, " "), "</li>"))
    end
	push!(formatted, "</ol>")
    HTML(join(formatted, "\n"))
end

# ╔═╡ d2288dd7-d6c6-4926-9fe4-e2de2bc2159e
css = html"""
<style>

.hint {
color: silver;
}

span.hl {
	background-color: yellow;
	font-weight: strong;
}
</style>
"""

# ╔═╡ a071a954-9f76-4ce6-a308-5201eea3de43
md"""> Data"""

# ╔═╡ 7943cd64-8b41-4984-ad69-08a3ef45049c
c = begin 
	reporoot = pwd() |> dirname
	f = string(reporoot, "/data/s21corpus-normed.cex")
	fromfile(CitableTextCorpus, f)
	
end

# ╔═╡ 70bcea19-28ba-45fb-aff2-0583063cbf9b
c.corpus |> length

# ╔═╡ 6f3f8ecc-459d-4fe6-a2dd-fdfbcd602c6d
noaccs = begin
	stripped = []
	for cn in c.corpus
		push!(stripped, CitableNode(cn.urn, rmaccents(cn.text)))
	end
	stripped
end

# ╔═╡ d7dd02f0-2327-4a7e-b15f-ef32f07506b2
scholia = filter(cn -> endswith(cn.urn.urn, "comment"), noaccs)

# ╔═╡ ca5f124a-5252-429a-8726-56816c2375e4
function searchpsgs(str)
	matches = filter(cn -> occursin(str, cn.text), scholia)
end

# ╔═╡ 1994a2ab-66ae-4793-8dce-be27fbb7cdbf
function searchresults(str)
	
	if isempty(str)
		HTML("""<span class="hint">Enter a Greek string without accents</span>""")
	elseif length(str) < 4
		HTML("""<span class="hint">Enter at least 4 characters</span>""")
	else
		psgs = searchpsgs(str)
		generic = map(cn -> dropversion(cn.urn), psgs)
		accentedmatches = []
		for urn in generic
			accented = filter(cn -> dropversion(cn.urn) == urn, c.corpus)
			push!(accentedmatches, accented)
		end
		resultarray = accentedmatches |> Iterators.flatten |> collect
		formatted(resultarray, str)
	end
end

# ╔═╡ 8cf8d639-141d-42d0-a37d-d90dbb2ad2b9
begin
	#dosearch
	searchresults(s)
end

# ╔═╡ Cell order:
# ╟─58b9fb4b-64a2-4f89-804e-9042cf8a013d
# ╟─2a260b76-ceb3-11eb-3429-c55e6e1df240
# ╟─a538c813-8808-4562-b03a-27b0373eb3a8
# ╟─8cf8d639-141d-42d0-a37d-d90dbb2ad2b9
# ╟─aec1ac3d-e4dd-4ba0-834c-e2c13101851e
# ╟─1994a2ab-66ae-4793-8dce-be27fbb7cdbf
# ╟─ca5f124a-5252-429a-8726-56816c2375e4
# ╟─fc616d86-c81e-4ff2-b695-0795888b3123
# ╟─7bbc6e78-d5fe-4046-960a-eee8660ef5b4
# ╟─d2288dd7-d6c6-4926-9fe4-e2de2bc2159e
# ╟─a071a954-9f76-4ce6-a308-5201eea3de43
# ╟─7943cd64-8b41-4984-ad69-08a3ef45049c
# ╟─70bcea19-28ba-45fb-aff2-0583063cbf9b
# ╟─6f3f8ecc-459d-4fe6-a2dd-fdfbcd602c6d
# ╟─d7dd02f0-2327-4a7e-b15f-ef32f07506b2
