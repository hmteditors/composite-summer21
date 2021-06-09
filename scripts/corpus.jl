using CitableText
using CitableCorpus
using EditorsRepo

repodirs = [
    "burney86-book8",
    "omega1.12-book8-2021",
    "upsilon1.1-2021",
    "va-2021",
    "vb-2021"
]


function repolist(dirlist)
    container = pwd() |> dirname
    map(dir -> repository(string(container, "/", dir)) dirlist)
end


repos = repolist(repodirs)

function compositenormed(repolist)
    nodelist = []
    for r in repolist
        texts = texturns(r)
        nds = normalizednodes(r, texts[1])
        push!(nodelist, nds)        
    end
    nodelist |> Iterators.flatten |> collect
end

allnodes = repodirs |> repolist |> compositenormed



reff = filter(cn -> endswith(passagecomponent(cn.urn), "ref"), allnodes)


badreff = []
goodpairs = []

for ref in reff
    try
      iliad = ref.text |> CtsUrn
      push!(goodpairs, (ref.urn, iliad))
      
    catch err
        push!(badreff, ref)
        #println("BAD $ref")
       
    end
end
badreff |> length
goodpairs |> length
