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


# Create a single archival corpus for all repos in repolist
function fullarchive(repolist)
    corpora = []
    for r in repolist
        push!(corpora, archivalcorpus(r))
    end
    CitableCorpus.composite_array(corpora)
end
repos = repolist(repodirs)

c = fullarchive(repos)



# Get personal names
using EzXML
pnvals = []
errors = []
count = 0
for cn in c.corpus
    root = parsexml(cn.text).root
    pns = findall("//persName", root)
    #println("Found ", length(pns), " persNames")
    for pn in pns
        count = count + 1
        if haskey(pn, "n")
            uvalue = pn["n"]
            println("Look at ", uvalue, " of type ", typeof(uvalue))
            push!(pnvals, pn["n"])
            println("pnvals now has ", length(pnvals), " entries.")
        else
            push!(errors, (cn.urn.urn, "No @n attribute"))
        end
    end
end
println("Looked at ",count, " pns, found ", length(errors), " erros, ", length(pnvals), " good entries.")



errfile = "pnerrors.txt"
open(errfile,"w") do io
    write(io, join(errors, "\n") * "\n")
end