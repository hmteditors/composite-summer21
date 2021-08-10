using CitableText
using CitableCorpus
using Unicode
using Orthography
using PolytonicGreek
using CitableParserBuilder


f = "data/archive-normed.cex"
c = CitableCorpus.fromfile(CitableTextCorpus,f)

function tokenizednode(cn::CitableNode)
    tokennodes = []
    psgbase = passagecomponent(cn.urn)
    urnbase = droppassage(cn.urn)
    tokenlist = PolytonicGreek.tokenizeLiteraryGreek(cn.text)

    lexcount = 0
    nonlexcount = '@'
    for t in tokenlist
        if t.tokencategory == LexicalToken()
            lexcount = lexcount + 1
            nonlexcount = '@'
            psg = string(psgbase, ".", lexcount)
            urn = addpassage(urnbase, psg)
            push!(tokennodes, CitableNode(urn, t.text))

        else nonlexcount = nonlexcount + 1
            psg = string(psgbase, ".", lexcount, lowercase(nonlexcount))
            urn = addpassage(urnbase, psg)
            push!(tokennodes, CitableNode(urn, t.text))
        end
    end
    tokennodes
end

function tokenedition(c::CitableTextCorpus)
     tokenizednode.(c.corpus) |> Iterators.flatten |> collect |> CitableTextCorpus
end

tkned = tokenedition(c)

open("data/archive-tokenedition.cex","w") do io
    write(io, CitableCorpus.cex(tkned))
end