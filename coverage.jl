import Pkg
println("Activating project in ", pwd())
Pkg.activate(".")
Pkg.instantiate()

# Page content as individual lines of markdown:
mdlines = ["---","layout: page",
"title: \"Current coverage of editing\"",
"nav_order: 1", "---","","","# Current coverage of editing",""]

using Dates
t = Dates.format(now(),"U d, Y, HH:MM")

datestamp = "Last modified: $t"
push!(mdlines, datestamp)


using CitableText
using CitableCorpus
using EditorsRepo
using StatsPlots

# Instantiate EditorialRepository's:
function repolist(dirlist)
    container = pwd() |> dirname
    map(dir -> repository(string(container, "/", dir)), dirlist)
end

# Create a single composite Vector of all citable nodes,
# in normalized text edition
function compositenormed(repolist)
    nodelist = []
    for r in repolist
        texts = texturns(r)
        for t in texts
            nds = normalizednodes(r, t)
            push!(nodelist, nds)        
        end
    end
    nodelist |> Iterators.flatten |> collect
end


# GH repos with current editing work:
repodirs = [
    "burney86-book8",
    "omega1.12-book8-2021",
    "upsilon1.1-2021",
    "va-2021",
    "vb-2021"
]
repos = repolist(repodirs)
allnodes = repodirs |> repolist |> compositenormed
iliadlines = filter(cn -> contains(cn.urn.urn, "tlg0012"),  allnodes)
schnodes = filter(cn -> contains(cn.urn.urn, "tlg5026"),  allnodes)
schcomments = filter(cn -> endswith(passagecomponent(cn.urn),"comment"), schnodes)

push!(mdlines,"")
push!(mdlines,"Total citable nodes: $(length(allnodes))")
push!(mdlines,"")
push!(mdlines,"Iliad lines: $(length(iliadlines))")
push!(mdlines,"")
push!(mdlines,"Scholia: $(length(schcomments))")
push!(mdlines,"")
push!(mdlines, "![Summary of coverage](./coverage.png)")


#graph coverage for a single MS for books 8 - 10.
function coverageplot(alliliad, allschol, title)
    il8 = filter(cn -> startswith(passagecomponent(cn.urn), "8"), alliliad) |> length
    il9 = filter(cn -> startswith(passagecomponent(cn.urn), "9"), alliliad) |> length
    il10 = filter(cn -> startswith(passagecomponent(cn.urn), "10"), alliliad) |> length
    iliadlines = [il8,il9,il10]

    sch8 = filter(cn -> startswith(passagecomponent(cn.urn), "8"), allschol) |> length
    sch9 = filter(cn -> startswith(passagecomponent(cn.urn), "9"), allschol) |> length
    sch10 = filter(cn -> startswith(passagecomponent(cn.urn), "10"), allschol) |> length
    scholia = [sch8, sch9, sch10]

    plotted = groupedbar([scholia iliadlines],
        bar_position = :stack,

        xticks=(1:3, ["Book 8", "Book 9", "Book 10"]),
        labels =  ["Scholia" "Iliad lines" ],
        ylabel = "Number of lines", xlabel = "Book of Iliad",
        title = title
    )
    plotted
end


# Plot coverage for all 5 MSS in books 8 - 10
function plotall(iliad,scholia)

    vbiliad = filter(cn -> contains(workcomponent(cn.urn), "msB"),  iliad)
    vbscholia = filter(cn -> contains(workcomponent(cn.urn), "msB"),  scholia)
    vbplot = coverageplot(vbiliad, vbscholia, "Venetus B")

    vailiad = filter(cn -> contains(workcomponent(cn.urn), "msA"),  iliad)
    vascholia = filter(cn -> contains(workcomponent(cn.urn), "msA"),  scholia)
    vaplot = coverageplot(vailiad, vascholia, "Venetus A")


    e3iliad = filter(cn -> contains(workcomponent(cn.urn), "e3"),  iliad)
    e3scholia = filter(cn -> contains(workcomponent(cn.urn), "e3"),  scholia)
    e3plot = coverageplot(e3iliad, e3scholia, "Upsilon 1.1")


    tiliad = filter(cn -> contains(workcomponent(cn.urn), "burney86"),  iliad)
    tscholia = filter(cn -> contains(workcomponent(cn.urn), "burney86"),  scholia)
    tplot = coverageplot(tiliad, tscholia, "Burney 86")


    l = @layout [a b; c d]

    plot(vaplot, e3plot, vbplot, tplot,  layout = l)
end

coverplot = plotall(iliadlines, schcomments)
savefig(coverplot, "docs/coverage/coverage.png")

delimited = cex(CitableTextCorpus(allnodes))
cexfile = "data/s21corpus.cex"
println("Writing CEX corpus to ", cexfile)
open(cexfile,"w") do io
    write(io, delimited)
end


# Report to web site
outfile = "docs/coverage/index.md"
open(outfile,"w") do io
    write(io, join(mdlines,"\n"))
end