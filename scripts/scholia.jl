using CitableText
using CSV, DataFrames, HTTP



# Build a vector of tuples pairing CTS URNs for a scholion and an Iliad passage
function buildindex()
	idxurl = "https://raw.githubusercontent.com/hmteditors/composite-summer21/main/data/scholia-iliad-idx.cex"
	df = CSV.File(HTTP.get(idxurl).body) |> DataFrame
	scholia = map(u -> CtsUrn(u), df[:, 1])
	iliad = map(u -> CtsUrn(u), df[:, 2])
	zip(scholia, iliad) |> collect
end



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


# Compose HTML to display a list of CitableNodes
function formatscholia(nodes)
	outputlines = [string("**", length(nodes), "** scholia comment on the line.", "")]
	for n in nodes
		siglum = workparts(n)[2]
		ref = passagecomponent(n)
		matches = filter(cn -> urncontains(n, cn.urn), noreff)
		for sch in matches
			psg = string("1. **", siglum, ", ", ref, "** ", sch.text)
			push!(outputlines, psg)
		end

	end
	
	output = join(outputlines,"\n")

end



# Load current corpus 
c = begin 
	reporoot = pwd() |> dirname
	url = "https://raw.githubusercontent.com/hmteditors/composite-summer21/main/data/s21corpus-normed.cex"
	fromurl(CitableTextCorpus, url, "|")
end
# Corpus after dropping citable node with "ref" info in scholia.
noreff = filter(cn -> ! endswith(cn.urn.urn, "ref"),  c.corpus) 


idx = buildindex()

findscholia("8.1")