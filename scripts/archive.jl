# Build a citable corpus of all archival XML in the HMT archive
# and write it to a CEX file.
#
using CitableText
using CitableCorpus
using EditorsRepo

# Write CEX version of all texts in corpus c
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

archiveroot = string(pwd() |> dirname, "/hmt-archive/archive")
repo = repository(archiveroot; dse="dse-data", config="textconfigs", editions="tei-editions")


# Rerun these two lines to update:
archivaltexts = archivalcorpus(repo)
writearchivalcex(archivaltexts)

