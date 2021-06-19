using CitableText
using CitableCorpus
using EditorsRepo


archiveroot = string(pwd() |> dirname, "/archive")
repo = repository(archiveroot; dse="dse-data", config="textconfigs")
citation = citation_df(repo)


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

archivaltexts = archivalcorpus(repo, citation)

texts = texturns(repo)
normednodes = []
for t in texts
    nds = normalizednodes(repo, t)
    push!(normednodes, nds)        
end
normed = filter(nodelist -> ! isnothing(nodelist), normednodes) |> Iterators.flatten |> collect |> CitableTextCorpus
normed.corpus |> length