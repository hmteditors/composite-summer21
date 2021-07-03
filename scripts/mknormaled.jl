using CitableText
using CitableCorpus
using EditorsRepo

parent = pwd() |> dirname
archiveroot = string(parent, "/hmt-archive/archive")
repo = repository(archiveroot; dse="dse-data", config="textconfigs", editions="tei-editions")

texts = texturns(repo)
normednodes = []
for t in texts
    nds = normalizednodes(repo, t)
    push!(normednodes, nds)        
end
normed = filter(nodelist -> ! isnothing(nodelist), normednodes) |> Iterators.flatten |> collect 
normcorpus = filter(cn -> ! isempty(cn.text), normed) |> CitableTextCorpus

outfile = string(pwd(), "/data/archive-normed.cex")
open(outfile,"w") do io
    write(io, cex(normcorpus))
end