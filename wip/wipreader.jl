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
md"""> ### WIP: multitextual source comparison
>
> See versions of *Iliad* lines and *scholia* commenting on them.
>
> Includes texts in the HMT archive, and repositories cataloged as "currently in progress."


"""

# ╔═╡ a49511bc-7c6c-4195-b3ac-d804c821f723
md"""Enter an *Iliad* passage (`book.line`) $(@bind psg TextField((6,1); default="8.1"))"""	

# ╔═╡ f245588b-ee3b-48a1-83a5-682100623b72
md"> Datasets"

# ╔═╡ b4f2795c-bf4f-4679-a0e9-f5cd9dd0f606
function loadcorpora()
	reporoot = pwd() |> dirname
	url = "https://raw.githubusercontent.com/hmteditors/composite-summer21/main/data/archive-normed.cex"
	archivecorpus = fromurl(CitableTextCorpus, url, "|")
	archivecorpus
end

# ╔═╡ 3996a15e-8ebf-4b74-a75a-f2e2bac9ce82
# Load current corpus 
c = loadcorpora()

# ╔═╡ 9d985a3b-182d-45f8-8cd2-33615971ce09
# Corpus after dropping citable node with "ref" info in scholia.
noreff = filter(cn -> ! endswith(cn.urn.urn, "ref"),  c.corpus) 

# ╔═╡ 6213874b-7425-4081-aadc-5b894c593822
# Corpus after dropping citable node with "ref" info in scholia.
archivalreff = filter(cn -> endswith(cn.urn.urn, "ref"),  c.corpus) 

# ╔═╡ f5ed604b-e469-4b02-9604-c9b80ad5908c
# Convert "ref" element of scholion to a tuple of scholion/iliad URNs
function indexref(cn)
	scholion = collapsePassageBy(cn.urn, 1)
	iliad = CtsUrn(cn.text)
	(scholion, iliad)
	
end

# ╔═╡ 0ee82e23-85e7-40e5-8a2a-27e7609d25aa
# Load current index of scholia to Iliad
idx = map(cn  -> indexref(cn), archivalreff)

#buildindex()

# ╔═╡ 548e5db0-25bf-4e0d-927a-71f3484f2a08
# Build a vector of tuples pairing CTS URNs for a scholion and an Iliad passage
#=
function buildindex()
	idxurl = "https://raw.githubusercontent.com/hmteditors/composite-summer21/main/data/scholia-iliad-idx.cex"
	df = CSV.File(HTTP.get(idxurl).body) |> DataFrame
	scholia = map(u -> CtsUrn(u), df[:, 1])
	iliad = map(u -> CtsUrn(u), df[:, 2])
	zip(scholia, iliad) |> collect
end
=#

# ╔═╡ d9baf44d-835e-4855-b9a3-291895ce670e
md"> Local repositories with work in progress"

# ╔═╡ da888f98-0095-4a8a-a16c-598b50c0a509
# Create a single composite Vector of all citable nodes,
# in normalized text edition
function compositenormed(repolist)
    nodelist = []
    for r in repolist
        texts = texturns(r)
        for t in texts
            nds = normalizednodes(r, t)
            push!(nodelist, nds)        
        end
    end
    allnodes = nodelist |> Iterators.flatten |> collect
	nonempty = filter(cn -> ! isempty(cn.text), allnodes)
	nonempty
end

# ╔═╡ 52f03907-261d-4d26-b5e0-5477bc3b5990
repodirs = [
	"vb-2021",
    "burney86-book8",
    "omega1.12-book8-2021",
	"se2021-1",
	"se2021-2",
	"se2021-3",
	"se2021-4",
	"se2021-5"
]

# ╔═╡ 1d873fa9-5759-409f-ad7d-233ee6a29be9
function repolist(dirlist)
    container = pwd() |> dirname |> dirname
    map(dir -> repository(string(container, "/", dir)), dirlist)
end

# ╔═╡ 7a2aa0f6-cbdd-4099-b1d0-f304efe55a1a
repos = repolist(repodirs)

# ╔═╡ 46b2f8ce-da23-476d-8a8a-c0cedc2839ef
wipcorpus = compositenormed(repos)

# ╔═╡ e9533da4-7f77-4f21-9429-6d9496f8a67a
localreff = filter(cn -> endswith(cn.urn.urn, "ref"), wipcorpus)

# ╔═╡ cca0551e-9f26-42b2-9db0-ada954adeff7
localindex = map(cn -> indexref(cn)  , localreff)

# ╔═╡ 3a71212c-d174-4f56-b998-58490c0fde1d
md"> Functions and formatting"

# ╔═╡ 55ff794c-9159-4bde-8e1f-b7df001ca6d8
# Compose HTML to display a list of CitableNodes
function formatscholia(nodes)
	label = length(nodes) > 1 ? "scholia comment" : "scholion comments"
	outputlines = [string("**", length(nodes), "** ", label, " on the line.", "")]
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
	if isempty(psgstr) || length(psgstr) < 3
		msg = "Enter a passage (<code>book.line</code>)"
		HTML(string("<span class=\"hint\">", msg, "</span>"))
	else
		urn = CtsUrn("urn:cts:greekLit:tlg0012.tlg001:$psgstr")
		matches = filter(pr -> urncontains(urn, pr[2]), idx)
		if isempty(matches)
			msg = "No scholia found for $psgstr"
			HTML(string("<span class=\"hint\">", msg, "</span>"))
		else
			scholia = map(pr -> pr[1], matches)
			formatscholia(scholia)
		end
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
	if isempty(psgstr) || length(psgstr) < 3
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
# ╟─b4f2795c-bf4f-4679-a0e9-f5cd9dd0f606
# ╟─9d985a3b-182d-45f8-8cd2-33615971ce09
# ╠═6213874b-7425-4081-aadc-5b894c593822
# ╠═0ee82e23-85e7-40e5-8a2a-27e7609d25aa
# ╟─f5ed604b-e469-4b02-9604-c9b80ad5908c
# ╠═548e5db0-25bf-4e0d-927a-71f3484f2a08
# ╟─d9baf44d-835e-4855-b9a3-291895ce670e
# ╠═46b2f8ce-da23-476d-8a8a-c0cedc2839ef
# ╟─da888f98-0095-4a8a-a16c-598b50c0a509
# ╠═e9533da4-7f77-4f21-9429-6d9496f8a67a
# ╠═cca0551e-9f26-42b2-9db0-ada954adeff7
# ╟─7a2aa0f6-cbdd-4099-b1d0-f304efe55a1a
# ╟─52f03907-261d-4d26-b5e0-5477bc3b5990
# ╟─1d873fa9-5759-409f-ad7d-233ee6a29be9
# ╟─3a71212c-d174-4f56-b998-58490c0fde1d
# ╟─4ef41735-2532-40a2-b1b1-21bdf9bf9765
# ╟─55ff794c-9159-4bde-8e1f-b7df001ca6d8
# ╟─1d5e2f8a-fa95-4adb-87e0-d22f95089689
# ╟─b23b45f7-1f82-4ad4-b2d6-4099588b7902
# ╟─c029d865-b83d-4985-b177-93c5ac73c8b2
