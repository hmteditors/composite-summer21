using CitableCorpus
using CitableText
urn = CtsUrn("urn:cts:greekLit:tlg0012.tlg001.msA:8.1")

workparts(urn)[3]

using PolytonicGreek
pwd()
c = begin 
	reporoot = pwd() 
	f = string(reporoot, "/data/s21corpus-normed.cex")
	fromfile(CitableTextCorpus, f)	
end
noaccs = begin
	stripped = []
	for cn in c.corpus
		push!(stripped, CitableNode(cn.urn, rmaccents(cn.text)))
	end
	stripped
end
scholia = filter(cn -> endswith(cn.urn.urn, "comment"), noaccs)


function searchpsgs(str)
	matches = filter(cn -> occursin(str, cn.text), scholia)
end


function searchresults(s)
	#dosearch
	
	if isempty(s)
		HTML("""<span class="hint">Enter a Greek string without accents</span>""")
	else
		psgs = searchpsgs(s)
		generic = map(cn -> dropversion(cn.urn), psgs)
		accentedmatches = []
		for urn in generic
			accented = filter(cn -> dropversion(cn.urn) == urn, c.corpus)
			push!(accentedmatches, accented)
		end
		accentedmatches |> Iterators.flatten |> collect

		formatPassages(accentedmatches)
		#accentedmatches
	end
end

function matchindices(cn, s)
	wrds = split(cn.text)
	findall(wd -> contains(wd, s) , wrds)
end
str = "ἠθικ"
psgs = searchpsgs(str)
generic = map(cn -> dropversion(cn.urn), psgs)

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
        push!(formatted, string(urn, " ", join(words, " ")))
    end
	push!(formatted, "</ol>")
    HTML(join(formatted, "\n"))
end

formatPassages(rslts, str)


