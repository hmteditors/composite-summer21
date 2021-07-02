using TextAnalysis
using CitableText
using CitableCorpus
using Markdown
using CiteEXchange
using HTTP
using Unicode

ms = "msB"

url = "https://raw.githubusercontent.com/hmteditors/composite-summer21/main/data/archive-normed.cex" 
c = CitableCorpus.fromurl(CitableTextCorpus, url, "|")
comments = filter(cn -> endswith(cn.urn.urn, "comment"), c.corpus)
nonempty = filter(cn -> ! isempty(cn.text), comments)

function mscomments(ms)
        msnodes = ms == "all" ? nonempty : filter(cn -> occursin(string(ms,"."), cn.urn.urn), nonempty) 
        msnodes
end

ms = "msA"
msnodes = mscomments(ms)
println("For ", ms, ", ", length(msnodes), " out of ", length(nonempty), " scholia.")

msAnodes = mscomments("msA")
msAurns = map(cn -> workcomponent(cn.urn), msAnodes) |> unique