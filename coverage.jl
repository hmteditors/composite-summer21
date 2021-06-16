import Pkg
println("Activating project in ", pwd())
Pkg.activate(".")
Pkg.instantiate()

using CitableText
using CitableCorpus
using EditorsRepo
using StatsPlots

# GH repos with current editing work:
repodirs = [
    "burney86-book8",
    "omega1.12-book8-2021",
    "upsilon1.1-2021",
    "va-2021",
    "vb-2021"
]
# Instantiate EditorialRepository's:
function repolist(dirlist)
    container = pwd() |> dirname
    map(dir -> repository(string(container, "/", dir)), dirlist)
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
citation = citeconfs(repos)


# Content of coverage page as individual lines of markdown:
mdlines = ["---","layout: page",
"title: \"Current coverage of editing\"",
"nav_order: 1", "---","","","# Current coverage of editing",""]

using Dates
calday = Dates.format(now(),"U d, Y")
t = Dates.format(now(),"HH:MM")
datestamp = "This page was automatically composed at $t on $calday."
push!(mdlines, datestamp)



# Create a citable corpus of archival text in a repo
function archivalcorpus(r::EditingRepository, citesdf)
    urns = citesdf[:, :urn]

    corpora = []
    for u in urns
        # 1. Read the source text (here, XML)
        src = textsourceforurn(r, u)
        if isnothing(src)
            # skip it
        else
            # 2. get the EditionBuilder for the urn
            reader = ohco2forurn(citesdf, u)
            # 3. create citable corpus of the archival version
            push!(corpora, reader(src, u))
        end
    end
    CitableCorpus.composite_array(corpora)
end


# Create a single archival corpus for all repos in repolist
function fullarchive(repolist, citedf)
    corpora = []
    for r in repolist
        push!(corpora, archivalcorpus(r, citedf))
    end
    CitableCorpus.composite_array(corpora)
end


allarchival = fullarchive(repos, citation)
archivefile = "data/s21corpus-src.cex"
println("Writing CEX corpus for archival source to ", archivefile)
open(archivefile,"w") do io
    write(io, cex(allarchival))
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


allnodes = repodirs |> repolist |> compositenormed
nonempty = filter(cn -> ! isempty(cn.text), allnodes)
iliadlines = filter(cn -> contains(cn.urn.urn, "tlg0012"),  nonempty)
schnodes = filter(cn -> contains(cn.urn.urn, "tlg5026"),  nonempty)
schcomments = filter(cn -> endswith(passagecomponent(cn.urn),"comment"), schnodes)

push!(mdlines,"")
push!(mdlines,"Total citable nodes: $(length(nonempty))")
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
        ylabel = "Number of passages", xlabel = "Book of Iliad",
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

delimited = cex(CitableTextCorpus(nonempty))
cexfile = "data/s21corpus-normed.cex"
println("Writing CEX for normalized corpus to ", cexfile)
open(cexfile,"w") do io
    write(io, delimited)
end


# Report to web site
outfile = "docs/coverage/index.md"
open(outfile,"w") do io
    write(io, join(mdlines,"\n"))
end