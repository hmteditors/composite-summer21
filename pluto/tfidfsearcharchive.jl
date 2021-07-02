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

# ╔═╡ a492f62a-d420-11eb-04f5-29615000168a
begin
	using Pkg
	Pkg.add("TextAnalysis")
	Pkg.add("CitableCorpus")
	Pkg.add("CitableText")
	Pkg.add("PlutoUI")
	Pkg.add("Markdown")
	Pkg.add("CiteEXchange")
	Pkg.add("HTTP")
	Pkg.add("Unicode")	
	using TextAnalysis, CitableCorpus, CitableText, PlutoUI, Markdown, CiteEXchange, HTTP, Unicode
end

# ╔═╡ 3ced021a-5548-464c-8448-4cdbf62c2fb0
md""">## Explore salient terms in HMT archive of *scholia*
>
>Search the *scholia* in the HMT archive.
> See "documents" containing the term, and the TF-IDF score for the
> term in each document. (In this notebook, each *scholion*'s comment is treated as a *document*.)
>
> For each matching document, the results display both a full text of the scholion, and a version
> highlighting the term in a text without accents or breathings.
"""

# ╔═╡ 623b483f-1801-49c8-b0a6-bc4a994649fc
md"**Search criteria**"

# ╔═╡ c6405d2c-5c14-4ee1-bf6d-165f3e0d9ec3
md"""
Term: $(@bind rawterm TextField(;default=""))
"""

# ╔═╡ 99dab151-d9bb-43d0-b215-3c38482d3d50
md"""---

>(Peek at internals of how `TextAnalysis` module indexing works:)"""

# ╔═╡ f6d71fbd-cf3b-4ee3-a45a-4108f28a84d5
term = Unicode.normalize(rawterm; stripmark=true) |> lowercase

# ╔═╡ cf4f497b-0ef6-4e50-8aef-f0fe945222dc
md">Formatting"

# ╔═╡ 3ecf3e9f-328e-4265-b99c-ed5784be1301
# Highlight term in txt
function highlight(term, txt)
	wrapped = replace(txt, term => """<span class="hilite">$term</span>""")
	wrapped
end

# ╔═╡ 3d7bafa0-1819-4944-8648-fc26da7213b6
	hint(text, label) = Markdown.MD(Markdown.Admonition("warn", label, [text]))

# ╔═╡ fa925d14-98ee-46c0-8732-8e85b5a138c9

	hint(md"""
- remove punctuation from stripped corpus in order to get more relevant TF-IDF score.
- score average word length of scholia with this term

""", "Features to add")

# ╔═╡ 79dfe87b-fa5a-4e9a-8584-adc77a9ed10d

	hint(md"""When changing the manuscript selection, you will also need to empty/reenter the term selection to refresh the results.
""", "⚠️Note")

# ╔═╡ 91dee988-3378-47da-803f-4d839b828c4a
css = html"""
<style>
.hilite {
	background-color: yellow;
	font-weight: bold;
}
.scholion {
	background-color: white;
}
.hint {
	color: silver;
}
.error {
	color: red;
	font-weight: bold;
}

</style>
"""

# ╔═╡ d1531ae6-06a8-4723-88cc-c4fe00d8f8a6
md"> Citable text passages and corpora"

# ╔═╡ 5d904b6c-80c3-4a8a-ba11-82fba50be209
xlation = "https://raw.githubusercontent.com/homermultitext/hmt-archive/master/archive/translations/book_ten_due_ebbott.cex"

# ╔═╡ 42ea5cd8-e6a5-4214-b243-caad4f6299d9
# From a URL pointing to a CEX file, get the text content of 
# ctsdata blocks
function txtfromurl(url)
	str = HTTP.get(url).body |> String
	blks = blocks(str)
	txt = datafortype("ctsdata", blks)
	c = CitableCorpus.fromdelimited(CitableTextCorpus, join(txt, "\n"))
	txtcorp = map(cn -> cn.text, c.corpus)
	txtcorp
end

# ╔═╡ 1c938931-47bb-4042-a051-84b48c2eaecb
function txtforcomments(nodelist)
	txts = map(cn -> Unicode.normalize(cn.text; stripmark=true), nodelist)
	lc = map(t -> lowercase(t), txts)
	
	lc
end


# ╔═╡ 9fc91194-e193-4a82-8283-1a3e55dff4dc
md">Other"

# ╔═╡ 5b2cb068-2f9d-4877-8124-f8640c361543
url = "https://raw.githubusercontent.com/hmteditors/composite-summer21/main/data/archive-normed.cex" #"https://raw.githubusercontent.com/hmteditors/composite-summer21/main/data/s21corpus-normed.cex"

# ╔═╡ 09e0722b-9571-4c94-a6cc-b408fc3f13cc
c = CitableCorpus.fromurl(CitableTextCorpus, url, "|")

# ╔═╡ 9d0c3590-293b-427c-82bd-9e9f1c67b73e
reff = filter(cn -> endswith(cn.urn.urn, "ref"), c.corpus)

# ╔═╡ f60970e8-ca28-458a-b23d-a581c960e3f1
comments = begin
	filter(cn -> endswith(cn.urn.urn, "comment"), c.corpus)
end

# ╔═╡ 33a8a1e4-e56e-4b32-b517-430b6ab40cb9
comments |> length

# ╔═╡ e5f0d885-6082-4a1f-a3a6-051c36498197
menu = ["all" => "all material in hmt-archive",
"msA" => "Main scholia of Venetus A",
"msAim" => "Intermarginal scholia of Venetus A",
"msAint" => "Interior scholia of Venetus A",
"msAil" => "Interlinear scholia of Venetus A",
"msB" => "Scholia of Venetus B",
"e3" => "Scholia of Escorial, Upsilon 1.1",
]

# ╔═╡ 45b4e2e3-ba3a-49c0-87b8-5ebd8d3d2788
md"""Manuscript $(@bind ms Select(menu))
"""

# ╔═╡ d4019870-2a30-4c6b-962e-deb3618abd4c
# filter nodes according to user's selected MS
msnodes = begin
	commentnodes = filter(cn -> ! isempty(cn.text), comments)
	ms == "all" ? commentnodes : filter(cn -> occursin(string(ms, "."), cn.urn.urn), commentnodes) 
end

# ╔═╡ 13092236-e810-4ace-aa40-8250edbad095
function formatscholion(i)

	scholurn = msnodes[i].urn
	docid = workparts(scholurn)[2]
	scholpsg = collapsePassageBy(scholurn, 1) |>  passagecomponent
	ref = replace(passagecomponent(scholurn), "comment" => "ref")
	refurn = addpassage(scholurn, ref)
	iliad = filter(cn -> cn.urn == refurn, c.corpus)
	if isempty(iliad)
		string("<b>", docid, "</b> ", scholpsg, " <span class=\"error\">", "Could not find <i>Iliad</i> reference for scholion ", "<code>", refurn.urn,"</code></span>")
		
		
	else
		iliadurn = CtsUrn(iliad[1].text)
		ilmatches = length(iliad)
	
		string("<b>", docid, "</b> ", scholpsg,  ", commenting on <b><i>Iliad</i> ", passagecomponent(iliadurn), "</b> <blockquote class=\"scholion\">", comments[i].text,"</blockquote>" )
	end
	
end

# ╔═╡ bba171b2-f0a9-4172-a7e9-5d365a1b4f22
srcdocs = txtforcomments(msnodes)

# ╔═╡ 06cb6c91-2436-4937-9dc6-a49263413350
srcdocs |> length

# ╔═╡ 2151f76f-03fd-49bd-b15a-e275a169213e
mslabel = begin
	pairing = filter(pr -> pr[1] == ms, menu)
	pairing[1][2]
end

# ╔═╡ de8b11d3-0ef8-4015-94f0-9f4b7dc139a4
md"**Results** for $(length(srcdocs)) scholia in $(mslabel)"

# ╔═╡ 6b3bc116-d544-4470-8b44-64ab0db15739
md">julia `TextAnalysis` structures"

# ╔═╡ 8dffd39f-f4a4-45d9-96d5-1f05084a1e96
docs = map(s -> StringDocument(s), srcdocs)

# ╔═╡ 4f5c8bae-81d5-4475-9936-9e4e4aacaadb
corp = Corpus(docs)

# ╔═╡ 025d05cc-7f2f-4dfd-a7bf-51fa78c849ed
function indexdocs(mschoice)
	corp[term]
end

# ╔═╡ 7bccf880-ae21-40ac-ac99-7e1bf59f683b
# Index value of documents in corpus where `term` appears.
# The document is accessible as corp.documents[INDEXVALUE]
documentindices = indexdocs(ms)

# ╔═╡ f274badc-adb1-4136-ab45-e614c08618a1
matchcount = length(documentindices)

# ╔═╡ 1487ef86-c352-454f-89c7-b5d9b3144ea8
indexdocs(ms) |> length

# ╔═╡ 2699073c-dd9d-4dae-af37-077e85fad819
lex = begin
	update_inverse_index!(corp)
	update_lexicon!(corp)
	lexicon(corp)
end

# ╔═╡ 93533849-f297-4479-9b63-d4f6754e4e08
m = DocumentTermMatrix(corp)

# ╔═╡ 0526b4e1-cd16-4fab-8951-1c1bfac4d465
# Find index of term within document matrix
termidx = findfirst(t -> t == term, m.terms)

# ╔═╡ e2e87b56-8003-41f8-8660-55e557665276
begin
	if isempty(term)
		HTML("<span class=\"hint\">Please enter a term</span>")
	else
	label = matchcount == 1 ? "- **1** occurrence" : "- **$matchcount** occurrences"
	display = """$label of `term $termidx` *$term* in **$(length(msnodes))** scholia in *$(mslabel)*
- Term frequency in corpus: **$(round(lexical_frequency(corp, term); digits=5))**
		
**Matches**
"""
	Markdown.parse(display)
	end
end

# ╔═╡ 0caceb74-ece3-41b6-aae5-b55f34b88cd1
tfidf = tf_idf(m)

# ╔═╡ 2f5200bc-03c7-4423-b23b-6e0fdf9e9ade
begin
	psgs = ["<ol>"]

	for idx in documentindices
		score  = tfidf[idx,termidx]
		hilited = highlight(term, corp.documents[idx].text)
		formatted = formatscholion(idx)	
		
		push!(psgs, string("<li>",    "<code>doc. $(idx): tf-idf score ", round(score; digits = 3), "</code> ",formatted, " <blockquote>", hilited, "</blockquote>"))
		
		push!(psgs, "</li>")
	
	end
	push!(psgs, "</ol>")
	HTML(join(psgs, "\n"))

end


# ╔═╡ dabf76d8-faea-43a3-9589-9521af253f32
m.terms |> length

# ╔═╡ Cell order:
# ╟─a492f62a-d420-11eb-04f5-29615000168a
# ╟─fa925d14-98ee-46c0-8732-8e85b5a138c9
# ╟─3ced021a-5548-464c-8448-4cdbf62c2fb0
# ╟─79dfe87b-fa5a-4e9a-8584-adc77a9ed10d
# ╟─623b483f-1801-49c8-b0a6-bc4a994649fc
# ╟─c6405d2c-5c14-4ee1-bf6d-165f3e0d9ec3
# ╟─45b4e2e3-ba3a-49c0-87b8-5ebd8d3d2788
# ╟─de8b11d3-0ef8-4015-94f0-9f4b7dc139a4
# ╟─e2e87b56-8003-41f8-8660-55e557665276
# ╟─2f5200bc-03c7-4423-b23b-6e0fdf9e9ade
# ╟─99dab151-d9bb-43d0-b215-3c38482d3d50
# ╟─0526b4e1-cd16-4fab-8951-1c1bfac4d465
# ╟─7bccf880-ae21-40ac-ac99-7e1bf59f683b
# ╟─025d05cc-7f2f-4dfd-a7bf-51fa78c849ed
# ╟─1487ef86-c352-454f-89c7-b5d9b3144ea8
# ╟─f274badc-adb1-4136-ab45-e614c08618a1
# ╟─f6d71fbd-cf3b-4ee3-a45a-4108f28a84d5
# ╟─2151f76f-03fd-49bd-b15a-e275a169213e
# ╟─cf4f497b-0ef6-4e50-8aef-f0fe945222dc
# ╟─13092236-e810-4ace-aa40-8250edbad095
# ╟─3ecf3e9f-328e-4265-b99c-ed5784be1301
# ╟─3d7bafa0-1819-4944-8648-fc26da7213b6
# ╟─91dee988-3378-47da-803f-4d839b828c4a
# ╟─d1531ae6-06a8-4723-88cc-c4fe00d8f8a6
# ╟─d4019870-2a30-4c6b-962e-deb3618abd4c
# ╟─bba171b2-f0a9-4172-a7e9-5d365a1b4f22
# ╟─06cb6c91-2436-4937-9dc6-a49263413350
# ╟─5d904b6c-80c3-4a8a-ba11-82fba50be209
# ╟─42ea5cd8-e6a5-4214-b243-caad4f6299d9
# ╟─1c938931-47bb-4042-a051-84b48c2eaecb
# ╟─9fc91194-e193-4a82-8283-1a3e55dff4dc
# ╟─5b2cb068-2f9d-4877-8124-f8640c361543
# ╟─09e0722b-9571-4c94-a6cc-b408fc3f13cc
# ╟─9d0c3590-293b-427c-82bd-9e9f1c67b73e
# ╟─f60970e8-ca28-458a-b23d-a581c960e3f1
# ╟─33a8a1e4-e56e-4b32-b517-430b6ab40cb9
# ╟─e5f0d885-6082-4a1f-a3a6-051c36498197
# ╟─6b3bc116-d544-4470-8b44-64ab0db15739
# ╟─8dffd39f-f4a4-45d9-96d5-1f05084a1e96
# ╟─4f5c8bae-81d5-4475-9936-9e4e4aacaadb
# ╟─2699073c-dd9d-4dae-af37-077e85fad819
# ╟─93533849-f297-4479-9b63-d4f6754e4e08
# ╟─0caceb74-ece3-41b6-aae5-b55f34b88cd1
# ╟─dabf76d8-faea-43a3-9589-9521af253f32
