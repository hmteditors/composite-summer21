import Pkg
println("Activating project in ", pwd())
Pkg.activate(".")
Pkg.instantiate()

# Page content as individual lines of markdown:
mdlines = ["---","layout: page",
"title: \"Current coverage of editing\"",
"nav_order: 1", "---","","","# Current coverage of editing",""]

using Dates
datestamp = "Last modified: $(now())"
push!(mdlines, datestamp)


using CitableText
using CitableCorpus
using EditorsRepo

# Instantiate EditorialRepository's:
function repolist(dirlist)
    container = pwd() |> dirname
    map(dir -> repository(string(container, "/", dir)), dirlist)
end

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
    nodelist |> Iterators.flatten |> collect
end


# GH repos with current editing work:
repodirs = [
    "burney86-book8",
    "omega1.12-book8-2021",
    "upsilon1.1-2021",
    "va-2021",
    "vb-2021"
]
repos = repolist(repodirs)
allnodes = repodirs |> repolist |> compositenormed
iliadlines = filter(cn -> contains(cn.urn.urn, "tlg0012"),  allnodes)
schnodes = filter(cn -> contains(cn.urn.urn, "tlg5026"),  allnodes)
schcomments = filter(cn -> endswith(passagecomponent(cn.urn),"comment"), schnodes)

push!(mdlines,"")
push!(mdlines,"Total citable nodes: $(length(allnodes))")
push!(mdlines,"")
push!(mdlines,"Iliad lines: $(length(iliadlines))")
push!(mdlines,"")
push!(mdlines,"Scholia: $(length(schcomments))")

delimited = cex(CitableTextCorpus(allnodes))
cexfile = "data/s21corpus.cex"
println("Writing CEX corpus to ", cexfile)
open(cexfile,"w") do io
    write(io, delimited)
end


# Report to web site
outfile = "docs/coverage/index.md"
open(outfile,"w") do io
    write(io, join(mdlines,"\n"))
end