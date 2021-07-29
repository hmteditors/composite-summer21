# Compare contents of autobuilt editions.
#
# Use these lines if running from shell,
# or skip directly to julia code if 
# running in VS Code
import Pkg
@info("Activating project in ", pwd())
Pkg.activate(".")
Pkg.instantiate()

using CitableCorpus
using CitableText

# Compare contents of XML archive and normalized scholia.
archival = "data/archive-xml.cex"
normalized = "data/archive-normed.cex"

archivalcorp = CitableCorpus.fromfile(CitableTextCorpus, archival)
scholianodes = filter(cn -> contains(cn.urn.urn,"tlg5026"), archivalcorp.corpus)
archivalscholia = filter(cn -> ! endswith(cn.urn.urn, "ref"), scholianodes) |> CitableTextCorpus

normalizedcorp = CitableCorpus.fromfile(CitableTextCorpus, normalized)

if length(archivalscholia.corpus) != length(normalizedcorp.corpus)
    @error("Corpora of different lengths!")
    @info("Archival: $(length(archivalscholia.corpus)), normalized: $(length(normalizedcorp.corpus))")
    archivedurns = map(cn -> dropversion(cn.urn).urn, archivalscholia.corpus)
    normalizedurns = map(cn -> dropversion(cn.urn).urn, normalizedcorp.corpus)
    diffs = setdiff(Set(archivedurns), Set(normalizedurn))
    
    open("urndiffs.txt", "w") do io
        write(io, join(diffs,"\n"))
    end
    @info("$(length(diffs)) differences written to urndiffs.txt")
else
    @info("XML and archival corpus synced.")
    @info("$(length(normalizedcorp.corpus)) citable nodes.")
end


#archivalwks = map(cn -> workcomponent(cn.urn), archivalscholia.corpus) |> unique
#normalizedwks = map(cn -> workcomponent(cn.urn), normalizedcorp.corpus) |> unique


#archivedsorted = sort(archivedurn)
#normedsorted = sort(normalizedurn)





#tmedition = "data/topicmodelingedition.cex"
#tmsrcedition = "data/tompicmodelingsource.cex"
