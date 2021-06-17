### A Pluto.jl notebook ###
# v0.15.0

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

# ╔═╡ 341e5820-5ad2-4b7d-8f2d-af5010e30c52
begin
	using Pkg
	Pkg.add("CitableText")
	Pkg.add("CitableCorpus")
	Pkg.add("EditorsRepo")
	Pkg.add("PlutoUI")
	Pkg.add("Markdown")
	Pkg.add("CSV")
	Pkg.add("HTTP")
	Pkg.add("DataFrames")
	using CitableText, CitableCorpus, EditorsRepo, PlutoUI, Markdown
	using CSV, HTTP, DataFrames
end

# ╔═╡ 418cd2a9-752d-4a4e-8be4-49d2f29c5bff
html"<p><span class=\"hint\">(The hidden cell above this one configures this notebook for use with Pluto prior to version 0.14.)</span></p>"


# ╔═╡ cd866e42-ce94-11eb-36b9-793a7473fc0f
md"> ### Multitextual scholia reader"

# ╔═╡ a49511bc-7c6c-4195-b3ac-d804c821f723
md"""Enter an *Iliad* passage (`book.line`) $(@bind psg TextField((6,1); default="8.1"))"""	

# ╔═╡ f245588b-ee3b-48a1-83a5-682100623b72
md"> Datasets"

# ╔═╡ 3996a15e-8ebf-4b74-a75a-f2e2bac9ce82
# Load current corpus 
c = begin 
	reporoot = pwd() |> dirname
	url = "https://raw.githubusercontent.com/hmteditors/composite-summer21/main/data/s21corpus-normed.cex"
	fromurl(CitableTextCorpus, url, "|")
end

# ╔═╡ 9d985a3b-182d-45f8-8cd2-33615971ce09
# Corpus after dropping citable node with "ref" info in scholia.
noreff = filter(cn -> ! endswith(cn.urn.urn, "ref"),  c.corpus) 

# ╔═╡ 548e5db0-25bf-4e0d-927a-71f3484f2a08
# Build a vector of tuples pairing CTS URNs for a scholion and an Iliad passage
function buildindex()
	idxurl = "https://raw.githubusercontent.com/hmteditors/composite-summer21/main/data/scholia-iliad-idx.cex"
	df = CSV.File(HTTP.get(idxurl).body) |> DataFrame
	scholia = map(u -> CtsUrn(u), df[:, 1])
	iliad = map(u -> CtsUrn(u), df[:, 2])
	zip(scholia, iliad) |> collect
end

# ╔═╡ 0ee82e23-85e7-40e5-8a2a-27e7609d25aa
# Load current index of scholia to Iliad
idx = buildindex()

# ╔═╡ 3a71212c-d174-4f56-b998-58490c0fde1d
md"> Functions and formatting"

# ╔═╡ 55ff794c-9159-4bde-8e1f-b7df001ca6d8
# Compose HTML to display a list of CitableNodes
function formatscholia(nodes)
	outputlines = [string("**", length(nodes), "** scholia comment on the line.", "")]
	for n in nodes
		siglum = workparts(n)[2]
		ref = passagecomponent(n)
		matches = filter(cn -> urncontains(dropversion(n), cn.urn), noreff)
		for sch in matches
			psg = string("- **", siglum, ", ", ref, "** ", sch.text)
			push!(outputlines, psg)
		end

	end
	
	output = join(outputlines,"\n")
	Markdown.parse(output)
end

# ╔═╡ 4ef41735-2532-40a2-b1b1-21bdf9bf9765
# Use index to lookup URNs for scholia commenting on Iliad line
function findscholia(psgstr)
	if isempty(psgstr)
		msg = "Enter a passage (<code>book.line</code>)"
		HTML(string("<span class=\"hint\">", msg, "</span>"))
	else
		urn = CtsUrn("urn:cts:greekLit:tlg0012.tlg001:$psgstr")
		matches = filter(pr -> urncontains(urn, pr[2]), idx)
		scholia = map(pr -> pr[1], matches)
		formatscholia(scholia)
	end
end

# ╔═╡ 79807bcc-a844-4d5d-983f-6659b5f7f09e
begin
	findscholia(psg)
end

# ╔═╡ b23b45f7-1f82-4ad4-b2d6-4099588b7902
# Compose HTML to display a list of CitableNodes
function formatiliad(nodes)
	outputlines = [string("**", length(nodes), "** manuscripts include line *", passagecomponent(nodes[1].urn), "*"), ""]
	
	
	
	for n in nodes
		siglum = workparts(n.urn)[3]
		psg = string("1. **", siglum, "** ", n.text)
		push!(outputlines, psg)
	end
	
	output = join(outputlines, "\n")
	Markdown.parse("$output")
end

# ╔═╡ 1d5e2f8a-fa95-4adb-87e0-d22f95089689
# Find Iliad passages in corpus for book.line reference
function findiliad(psgstr)
	if isempty(psgstr)
		msg = "Enter a passage (<code>book.line</code>)"
		HTML(string("<span class=\"hint\">", msg, "</span>"))
	else
		urn = CtsUrn("urn:cts:greekLit:tlg0012.tlg001:$psgstr")
		matches = filter(cn -> urncontains(urn, cn.urn), c.corpus)
		if isempty(matches)
			msg = "No passages found for $psgstr.\n\n(We'll give a better error message here another day.)"
			HTML(string("<span class=\"hint\">", msg, "</span>"))
		else
			formatiliad(matches)
		end
	end
end

# ╔═╡ 58af5e1f-0e0c-4cc4-b4ec-f2b8aeaee78f
begin
	findiliad(psg)
end

# ╔═╡ c029d865-b83d-4985-b177-93c5ac73c8b2
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

# ╔═╡ Cell order:
# ╟─341e5820-5ad2-4b7d-8f2d-af5010e30c52
# ╟─418cd2a9-752d-4a4e-8be4-49d2f29c5bff
# ╟─cd866e42-ce94-11eb-36b9-793a7473fc0f
# ╟─a49511bc-7c6c-4195-b3ac-d804c821f723
# ╟─58af5e1f-0e0c-4cc4-b4ec-f2b8aeaee78f
# ╟─79807bcc-a844-4d5d-983f-6659b5f7f09e
# ╟─f245588b-ee3b-48a1-83a5-682100623b72
# ╟─3996a15e-8ebf-4b74-a75a-f2e2bac9ce82
# ╟─9d985a3b-182d-45f8-8cd2-33615971ce09
# ╟─0ee82e23-85e7-40e5-8a2a-27e7609d25aa
# ╟─548e5db0-25bf-4e0d-927a-71f3484f2a08
# ╟─3a71212c-d174-4f56-b998-58490c0fde1d
# ╟─4ef41735-2532-40a2-b1b1-21bdf9bf9765
# ╟─55ff794c-9159-4bde-8e1f-b7df001ca6d8
# ╟─1d5e2f8a-fa95-4adb-87e0-d22f95089689
# ╟─b23b45f7-1f82-4ad4-b2d6-4099588b7902
# ╟─c029d865-b83d-4985-b177-93c5ac73c8b2
