# Build an edition optimized for topic modelling,
# and write to disk in:
# - CEX format for a CitableTextCorpus
# - delimited text for use with jslda

using CitableCorpus
using CitableText
using CorpusConverters
using EditionBuilders
using HmtTopicModels
using TopicModelsVB
using TextAnalysis
using CSV
using HTTP
using DataFrames

tmbldr = HmtTopicModels.HmtTMBuilder("tm builder", "hmttm")

stopsurl = "https://raw.githubusercontent.com/HCMID/scholia-transmission/main/data/stops.txt"
stopsdf = CSV.File(HTTP.get(stopsurl).body, delim="|") |> DataFrame
stops = stopsdf[:,1]

infile = "data/archive-xml.cex"
xmlcorpus = CitableCorpus.fromfile(CitableTextCorpus, infile, "|")
scholia = filter(cn -> endswith(cn.urn.urn, "comment"), xmlcorpus.corpus) |> CitableTextCorpus
@info("Processing $(scholia.corpus |> length) scholia in archival XML corpus")

ed = edition(tmbldr,scholia)
tmed = tmclean(ed, stops)
nonempty = filter(cn -> ! isempty(strip(cn.text)), tmed.corpus) |> CitableTextCorpus
@info("Total scholia in TM editoin: $(nonempty.corpus |> length)")

tmfile = "data/topicmodelingedition.cex"
open(tmfile, "w") do io
    write(io, string("urn|text\n", cex(nonempty) ,"\n"))
end

# Build source corpus:
#
# THIS IS VERY SLOW: ONLY REBUILD WHEN UPDATES TO CONTENT OF ARCHIVE REQUIRES
# RESULTS IN NEW NUMBER OF INCLUDED NODES.
#

diplinfile = "data/archive-normed.cex"
diplcorpus = CitableCorpus.fromfile(CitableTextCorpus, diplinfile, "|")
diplscholia = filter(cn -> endswith(cn.urn.urn, "comment"), diplcorpus.corpus) |> CitableTextCorpus
@info("Scholia in parallel diplomatic edition: $(diplscholia.corpus |> length)" )

missingurn = CtsUrn("urn:cts:hmt:errors.missing:notfound")
missingnode = CitableNode(missingurn, "NA")

srcnodes = []
for n in 1:length(nonempty.corpus)
    if mod(n, 200) == 0
        @info("Checking node $n ...")
    end
    broad = dropversion(nonempty.corpus[n].urn)

    srcmatches = filter(cn -> urncontains(broad, cn.urn), diplscholia.corpus)
    if length(srcmatches) == 1
        push!(srcnodes, srcmatches[1])
    else
        @warn("Failed to find match for $broad")
        push!(srcnodes, missingnode)
    end
end
@info("Scholia after processing to align with tm editoin: $(srcnodes |> length)")
srccorp = CitableTextCorpus(srcnodes)

tmsrcfile = "data/topicmodelingsource.cex"
open(tmsrcfile, "w") do io
    write(io, string("urn|text\n", cex(srccorp),"\n"))
end


