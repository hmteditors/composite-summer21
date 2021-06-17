using CitableText
using CitableCorpus
using CitableObject
using EditorsRepo
using CitablePhysicalText
using DataFrames


## THESE ARE REPLICATED FROM coverage.jl
# GH repos with current editing work:
repodirs = [
    "burney86-book8",
    "omega1.12-book8-2021",
    "upsilon1.1-2021",
    "va-2021",
    "vb-2021"
]
# Instantiate EditorialRepository's:
function repolist(dirlist)
    container = pwd() |> dirname
    map(dir -> repository(string(container, "/", dir)), dirlist)
end
function citeconfs(repos)
    composite = citation_df(repos[1])
    for i in 2:length(repos)
        composite = vcat(composite,citation_df(repos[i]) )
    end
    composite
end


# Create a citable corpus of archival text in a repo
function archivalcorpus(r::EditingRepository, citesdf)
    urns = citesdf[:, :urn]

    corpora = []
    for u in urns
        # 1. Read the source text (here, XML)
        src = textsourceforurn(r, u)
        if isnothing(src)
            # skip it
        else
            # 2. get the EditionBuilder for the urn
            reader = ohco2forurn(citesdf, u)
            # 3. create citable corpus of the archival version
            push!(corpora, reader(src, u))
        end
    end
    CitableCorpus.composite_array(corpora)
end


# Create a single archival corpus for all repos in repolist
function fullarchive(repolist, citedf)
    corpora = []
    for r in repolist
        push!(corpora, archivalcorpus(r, citedf))
    end
    CitableCorpus.composite_array(corpora)
end

repos = repolist(repodirs)
citation = citeconfs(repos)

allarchival = fullarchive(repos, citation)
scholiacomms = filter(cn -> endswith(cn.urn.urn, "comment"), allarchival.corpus)
scholiaurnstrs = map(cn -> collapsePassageBy(cn.urn,1).urn, scholiacomms)
others = filter(cn -> ! contains(cn.urn.urn, "tlg5026"), allarchival.corpus)
otherurnstrs = map(cn -> cn.urn.urn, others )


allurnstrs = vcat(scholiaurnstrs, otherurnstrs)
allurns =  map(s -> CtsUrn(s), allurnstrs)
###

repodses = []
for r in repos
    push!(repodses,EditorsRepo.dse_df(r))
end
dses = vcat(repodses[1], repodses[2], repodses[3], repodses[4], repodses[5])
surfs = dses[:, :surface] |> unique


notfoundincorpus = []
for surf in surfs
    txts = filter( r -> r.surface == surf,  dses)
    for t in txts[:, :passage]
        if t.urn in allurnstrs
        else
            push!(notfoundincorpus, (surf, t))
        end
    end
end


noomega = filter(pr -> ! contains(pr[1].urn, "e4"),  notfoundincorpus)
println(join(notfoundincorpus, "\n"))

badsurfs = map(pr -> pr[1], notfoundincorpus) |> unique
dses |> nrow


notfoundindse = []
for u in allurns
    matchcount = filter(r -> u == r.passage, dses)  |> nrow
     if matchcount == 0
        push!(notfoundindse, u)
     end
end
println(join(notfoundindse,"\n"))
