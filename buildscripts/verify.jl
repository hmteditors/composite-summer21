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
#scholianodes = filter(cn -> contains(cn.urn.urn,"tlg5026"), archivalcorp.corpus)
#archivalscholia = filter(cn -> ! endswith(cn.urn.urn, "ref"), scholianodes) |> CitableTextCorpus

normalizedcorp = CitableCorpus.fromfile(CitableTextCorpus, normalized)


if length(archivalcorp.corpus) != length(normalizedcorp.corpus)
    @error("Corpora of different lengths!")
    @info("Archival: $(length(archivalcorp.corpus)) ")
    @info("Normalized: $(length(normalizedcorp.corpus))")
    archivedurns = map(cn -> dropversion(cn.urn).urn, archivalcorp.corpus)
    normalizedurns = map(cn -> dropversion(cn.urn).urn, normalizedcorp.corpus)
    setA = Set(archivedurns)
    setN = Set(normalizedurns)
    diffs = setdiff(setA, setN )
    
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

#=
archivedurns = map(cn -> dropversion(cn.urn).urn, archivalcorp.corpus)
normalizedurns = map(cn -> dropversion(cn.urn).urn, normalizedcorp.corpus)

archivedsorted = sort(archivedurns)
normedsorted = sort(normalizedurns)

println(join(archivedsorted,"\n")) 
println(join(normedsorted,"\n")) 
=#

#tmedition = "data/topicmodelingedition.cex"
#tmsrcedition = "data/tompicmodelingsource.cex"