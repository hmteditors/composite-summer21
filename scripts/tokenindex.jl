
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
    map(dir -> repository(string(container, "/", dir)), dirlist)
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
iliadlines = filter(cn -> contains(cn.urn.urn, "tlg0012"),  allnodes)
schnodes = filter(cn -> contains(cn.urn.urn, "tlg5026"),  allnodes)
schcomments = filter(cn -> endswith(passagecomponent(cn.urn),"comment"), schnodes)

# Create composite citation dataframe for all repos
function citeconfs(repos)
    composite = citation_df(repos[1])
    for i in 2:length(repos)
        composite = vcat(composite,citation_df(repos[i]) )
    end
    composite
end

using Orthography
using PolytonicGreek
using ManuscriptOrthography


citation = citeconfs(repos)
u = citation[1,:urn]


# This the right approach:
# 1. Read the source text (here, XML)
src = textsourceforurn(repos[1], u)
# 2. get the EditionBuilder for the urn
reader = ohco2forurn(citation, u)
# 3. get a citable corpus of the archival version
o2corpus = reader(src, u)
ortho = orthographyforurn(citation, dropversion(u))
ntext = normednodetext(repos[1], u)

tokenize(ortho, ntext)


# For one repo:
#catalog = textcatalog_df(editorsrepo())