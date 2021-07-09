# Build a single corpus of normalized editions of all texts in the HMT archive
# and in the in-progress repositories listed here, and write it to a CEX file.
#

using CitableText
using CitableCorpus
using EditorsRepo

# Names of repositories with work in progress.
# They should be cloned in a directory parallel to this repository.
repodirs = [
    "burney86-book8",
    "vb-2021",
    "se2021-1",
    "se2021-2",
    "se2021-3",
    "se2021-4",
    "se2021-5"
]
archiveroot = string(pwd() |> dirname, "/hmt-archive/archive")
archive = repository(archiveroot; dse="dse-data", config="textconfigs", editions="tei-editions")

# Instantiate EditorialRepository's:
function repolist(dirlist)
    container = pwd() |> dirname
    map(dir -> repository(string(container, "/", dir)), dirlist)
end
repos = repolist(repodirs)
push!(repos, archive)


normednodes = []

for r in repos
    texts = texturns(r)
    for t in texts
        nds = normalizednodes(r, t)
        push!(normednodes, nds)        
    end
end
normed = filter(nodelist -> ! isnothing(nodelist), normednodes) |> Iterators.flatten |> collect 
normcorpus = filter(cn -> ! isempty(cn.text), normed) |> CitableTextCorpus

outfile = string(pwd(), "/data/archive-normed.cex")
open(outfile,"w") do io
    write(io, cex(normcorpus))
end