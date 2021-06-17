using CitableText
using CitableCorpus
using EditorsRepo
using EzXML

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
# Create composite citation dataframe for all repos
function citeconfs(repos)
    composite = citation_df(repos[1])
    for i in 2:length(repos)
        composite = vcat(composite,citation_df(repos[i]) )
    end
    composite
end

repos = repolist(repodirs)
citation = citeconfs(repos)



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


allarchival = fullarchive(repos, citation)


badurns = []
function indexnode(cn::CitableNode)
    root = parsexml(cn.text)
    dudematches = findall("//persName", root)
    matchlist = []
    for dude in dudematches
        if haskey(dude, "n")
            push!(matchlist, (dude["n"], dude.content))
        else
            push!(badurns, cn.urn)
        end
    end
    (cn.urn, matchlist)
end


dudepairs = map(cn -> indexnode(cn), allarchival.corpus)
nonempty = filter(pr -> ! isempty(pr[2]), dudepairs)
badurns |> length
nonempty |> length

println(join(badurns, "\n"))


idxpairs = ["passage|person"]
for psg in nonempty
    for pers in psg[2]
        push!(idxpairs, string(psg[1].urn,"|", pers[1]))
    end
end
idxpairs


nonempty[1][2]

outfile = "data/persnameidx.cex"
open(outfile, "w") do io
    write(io, join(idxpairs, "\n"))
end
