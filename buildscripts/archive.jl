# Build a citable corpus of all archival XML in the HMT archive
# and in the in-progress repositories listed here, and write it to a CEX file.
#
# Use these lines if running from shell
import Pkg
@info("Activating project in ", pwd())
Pkg.activate(".")
Pkg.instantiate()

# Names of repositories with work in progress.
# They should be cloned in a directory parallel to this repository.
repodirs = [
    "burney86-book8",
    "burney86-book4",
    "vb-2021",
    "se2021-1",
    "se2021-2",
    "se2021-3",
    "se2021-4",
    "se2021-5"
]
archiveroot = string(pwd() |> dirname, "/hmt-archive/archive")


using CitableText
using CitableCorpus
using EditorsRepo
using TextAnalysis

# Instantiate EditorialRepository's:
function repolist(dirlist)
    container = pwd() |> dirname
    map(dir -> repository(string(container, "/", dir)), dirlist)
end
repos = repolist(repodirs)


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

archive = repository(archiveroot; dse="dse-data", config="textconfigs", editions="tei-editions")
push!(repos, archive)

corpora = []
for r in repos
    push!(corpora, archivalcorpus(r))
end

corpus = composite_array(corpora)

realcorpus = filter(cn -> ! isempty(cn.text), corpus.corpus) |> CitableTextCorpus
@info("Size of corpus: $(length(realcorpus.corpus))")
writearchivalcex(realcorpus)
@info("Corpus written to data/archive-xml.cex")
