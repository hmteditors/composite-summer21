# Build an edition optimized for topic modelling,
# and write to disk in:
# - CEX format for a CitableTextCorpus
# - delimited text for use with jslda

using CitableCorpus
using CitableText
using CorpusConverters
using DelimitedFiles
using EditionBuilders
using HmtTopicModels
using TopicModelsVB
using TextAnalysis


stopsfile = string(pwd() |> dirname, "/scholia-transmission/data/stops.txt")
stops = readdlm(stopsfile)

tmbldr = HmtTopicModels.HmtTMBuilder("tm builder", "hmttm")
#xmlurl = "https://raw.githubusercontent.com/hmteditors/composite-summer21/main/data/archive-xml.cex"
#xmlcorpus = CitableCorpus.fromurl(CitableTextCorpus, xmlurl, "|")
infile = "data/archive-xml.cex"
xmlcorpus = CitableCorpus.fromfile(CitableTextCorpus, infile, "|")
scholia = filter(cn -> endswith(cn.urn.urn, "comment"), xmlcorpus.corpus) |> CitableTextCorpus

ed = edition(tmbldr,scholia)
tmed = tmclean(ed, stops)
nonempty = filter(cn -> ! isempty(strip(cn.text)), tmed.corpus) |> CitableTextCorpus


tmfile = "data/topicmodelingedition.cex"
open(tmfile, "w") do io
    write(io, string("urn|text\n", cex(nonempty) ,"\n"))
end


#= Debugging a TextAnalysis corpus

tascholia = tacorpus(scholia)
update_lexicon!(tascholia)
update_inverse_index!(tascholia)


lex = lexicon(tascholia)
tascholia["\""]


m = DocumentTermMatrix(tascholia)


println("Finish debugging")

=#


println("Wait right here.")
#=
function tidyurns(s)
    tkns = split(s)
    tidier = []
    for t in tkns
        if startswith(t, "urn:cite2:hmt:pers")
            u = Cite2Urn(t)
            rawnumeral = replace(objectcomponent(u), "pers" => "")
            #=
            shorter = string("pers_", objectcomponent(u))
            push!(tidier, shorter)
            =#
            push!(tidier, rawnumeral)
        else
            push!(tidier, t)
        end
    end
    join(tidier," ")
end

function writeeditions(bldr, corpus::CitableTextCorpus, outfile)
    tmeditionraw = edition(bldr, corpus)
    tmnodes = filter(cn -> ! isempty(cn.text), tmeditionraw.corpus) 
    tmedition = CitableTextCorpus(tmnodes)
    tmcex = cex(tmedition)

    open(outfile,"w") do io
        write(io, tmcex)
    end


    scholia = filter(cn -> contains(passagecomponent(cn.urn), "comment"), tmnodes)
    lines = []
    for sch in scholia
        wk = workcomponent(sch.urn)
        parts = split(wk,".")
        short = string(parts[2],":",passagecomponent(sch.urn))
        push!(lines, string(short,"\tscholion\t", tidyurns(sch.text)))
    end
    jslda = join(lines,"\n") * "\n"
    open("data/scholia-jslda.tsv", "w") do io
        write(io, jslda)
    end
end

writeeditions(tmbldr, xmlcorpus, tmfile)
=#