# 1. Create a single archival corpus of work-in-progress repos
# 2. Analyze persName tagging
#
using EditorsRepo
using CitableCorpus
using CitableText


repodirs = [
    "burney86-book8",
    "upsilon1.1-2021",
    "vb-2021"
]
function repolist(dirlist)
    container = pwd() |> dirname
    map(dir -> repository(string(container, "/", dir)), dirlist)
end

#
## 1. CREATE a single archival corpus for all repos in repolist
#
function fullarchive(repolist)
    corpora = []
    for r in repolist
        push!(corpora, archivalcorpus(r))
    end
    CitableCorpus.composite_array(corpora)
end
repos = repolist(repodirs)

c = fullarchive(repos)

#
## 2. ANALYZE persName taggging
using EzXML
using CitableObject
# Support labelling persNames from authlist
using CSV
using DataFrames
using HTTP
authurl  = "https://raw.githubusercontent.com/homermultitext/hmt-authlists/master/data/hmtnames.cex"
authdf = CSV.File(HTTP.get(authurl).body; delim = "#", header = 2) |> DataFrame

# Lookup up label for urn in dataframe
function labelforurn(u, authdf)
    matched = filter( r -> r.urn == u, authdf)
    if nrow(matched) > 1
        @warn "Multiple results for $u !"
        nothing
    elseif nrow(matched) == 0
    else
        @warn "No matches for $u"
        matched[1,:label]
	end
end

# 
pnvals = []
errors = []
count = 0
for cn in c.corpus
    root = parsexml(cn.text).root
    pns = findall("//persName", root)
    #println("Found ", length(pns), " persNames")
    for pn in pns
        count = count + 1
        #@warn "Looking at $pn"
        if haskey(pn, "n")
            uvalue = pn["n"]
            label = labelforurn(uvalue, authdf)
            if isnothing(label) # Value not in authlist
                label = string(" No entry in authlist matching |",uvalue,"|")
                push!(errors, string(cn.urn.urn,label))

            else
                try
                    urn = Cite2Urn(uvalue)
                    if collectioncomponent(urn) != "pers.v1"
                        push!(errors, string(cn.urn.urn, " URN has wrong collection for a personal name ($(pn.content))"))
                    else
                        push!(pnvals, string(pn["n"]," ", label))
                    end
                catch e

                    @error "Invalid URN $(uvalue)"
                    push!(errors, string(cn.urn.urn, " Invalid URN syntax (persName $(pn.content))"))
                end
            end


        else # No @n attribute
            push!(errors, string(cn.urn.urn, " No @n attribute on $(pn.content)"))
        end
    end    
end
println("Looked at ",count, " pns, found ", length(errors), " errors, ", length(pnvals), " good entries.")
errfile = "pnerrors.txt"
open(errfile,"w") do io
    write(io, join(errors, "\n") * "\n")
end

pnvallist = unique(pnvals) |> unique |> sort

pnlist = "pnvalues.txt"
open(pnlist, "w") do io
    write(io, join(pnvallist,"\n") * "\n")
end
# done.