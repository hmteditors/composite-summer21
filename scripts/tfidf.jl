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

