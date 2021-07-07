# Build a citable corpus of all archival XML in the HMT archive
# and write it to a CEX file.
#
using CitableText
using CitableCorpus
using EditorsRepo


archiveroot = string(pwd() |> dirname, "/hmt-archive/archive")
repo = repository(archiveroot; dse="dse-data", config="textconfigs", editions="tei-editions")


#= Create a citable corpus of archival text in a repo
function archivalcorpus(r::EditingRepository)
    citesdf = citation_df(repo)
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
=#
archivaltexts = archivalcorpus(repo)
function writearchivalcex(c::CitableTextCorpus, f = "data/archive-xml.cex")
    nonempty = filter(cn -> ! isempty(cn.text), c.corpus) |> CitableTextCorpus
    rawcex = cex(nonempty)
    lines = split(rawcex,"\n")
    tidierlines = ["urn|text"]
    for ln in lines
        push!(tidierlines, replace(ln, r"[\s]+" => " " ))
    end
    tidier = join(tidierlines, "\n")
    open(f, "w") do io
        write(io, tidier)
    end
end

writearchivalcex(archivaltexts)
