# Create a delimited text file with analyses for tokens identifed by CTS URN.
using CitableText
using CitableCorpus
using Unicode
using Orthography
using PolytonicGreek
using CitableParserBuilder
using HTTP

analysisdata = "https://raw.githubusercontent.com/neelsmith/Kanones.jl/main/scratch/scholia-analyses.cex"
#analysisfile = "data/analyses.cex"
lines = split(String(HTTP.get(analysisdata).body) , "\n")

parsedict = Dict()
for l in lines
    halves = split(String(l), "|")
    if haskey(parsedict,halves[1])
        parses = parsedict[halves[1]]
        push!(parses, halves[2])
        parsedict[halves[1]] = parses
    elseif isempty(halves[2])
        parsedict[halves[1]] = []
    else
        parsedict[halves[1]] = [halves[2]]
    end
end

tknfile = "data/archive-tokenedition.cex"
tkncorpus = CitableCorpus.fromfile(CitableTextCorpus, tknfile)

scholiaurn = CtsUrn("urn:cts:greekLit:tlg5026:")
scholia = filter(cn -> urncontains(scholiaurn, cn.urn) ,tkncorpus.corpus) |> CitableTextCorpus

function normalizetxt(s)
    rmaccents(s) |> lowercase
end

function stringforcat(tokencat) 
    if tokencat == LexicalToken()
        "lexical"
    elseif tokencat == PunctuationToken()
        "punctuation"
    else
        "other"
    end
end


analyzedcorpus = ["urn|token|analysiscex|tokencategory"]
for cn in scholia.corpus
    tkn = PolytonicGreek.tokenizeLiteraryGreek(cn.text)[1]
    normed = normalizetxt(cn.text)
    if haskey(parsedict, normed)
        if isempty(parsedict[normed])
            push!(analyzedcorpus, string(cn.urn.urn, "|", cn.text,"|missing|", stringforcat(tkn.tokencategory)))

        else
            for a in parsedict[normed]
                push!(analyzedcorpus, string(cn.urn.urn, "|", cn.text,"|", a, "|", stringforcat(tkn.tokencategory)))
            end
        end


    else
        push!(analyzedcorpus, string(cn.urn.urn, "|", cn.text,"|missing|", stringforcat(tkn.tokencategory)))
    end
end

open("data/analyzededition-scholia.cex","w") do io
    write(io, join(analyzedcorpus, "\n"))
end
