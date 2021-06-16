
using CitableText
using CitableCorpus
using EditorsRepo

using Orthography
using PolytonicGreek
using ManuscriptOrthography


repodirs = [
    "burney86-book8",
    "omega1.12-book8-2021",
    "upsilon1.1-2021",
    "va-2021",
    "vb-2021"
]

function repolist(dirlist)
    container = pwd() |> dirname
    map(dir -> repository(string(container, "/", dir)), dirlist)
end



function compositenormed(repolist)
    nodelist = []
    for r in repolist
        texts = texturns(r)
        nds = normalizednodes(r, texts[1])
        push!(nodelist, nds)        
    end
    nodelist |> Iterators.flatten |> collect
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
allnodes = repodirs |> repolist |> compositenormed
iliadlines = filter(cn -> contains(cn.urn.urn, "tlg0012"),  allnodes)
schnodes = filter(cn -> contains(cn.urn.urn, "tlg5026"),  allnodes)
schcomments = filter(cn -> endswith(passagecomponent(cn.urn),"comment"), schnodes)
citation = citeconfs(repos)
urns = citation[:, :urn]
####


#=
r = repos[1]
u = urns[1]
lextokens(r, urns[6])
=#

tokens = []
for r in repos
    for u in urns    
        @warn("Token index: checking $u in repo $r")
        println("Token index: checking $u in repo $r")
        push!(tokens,  lextokens(r, u))
        #push!(tokens, (r, u))
    end
end
tokenlists  = []
for t in tokens
    if isempty(t)
    else
        push!(tokenlists, t)
    end
end

hascontent = filter(!isnothing, tokens)

tkncorpus = hascontent |> Iterators.flatten |> collect |> CitableTextCorpus


tknresults = "data/scholia-tokens.cex"
open(tknresults, "w") do io
    write(io, cex(tkncorpus))
end

tkncorpus.corpus |> length