# Make a smart word list for morphological parsing:
# ie, a unique set of lexical tokens only that are 
# normalized to:
#
# - lower case
# - no breathings
#
using CitableText
using CitableCorpus
using Unicode
using Orthography
using PolytonicGreek

url = "https://raw.githubusercontent.com/hmteditors/composite-summer21/main/data/archive-normed.cex"
c = CitableCorpus.fromurl(CitableTextCorpus, url, "|")




# Extract normalized set of strings for all lexical items
# in a citable node.
function stringsfornode(cn)
    tokenlist = PolytonicGreek.tokenizeLiteraryGreek(cn.text)
    lex = filter(t -> t.tokencategory == LexicalToken(), tokenlist)
    rawtext =  map(t -> t.text, lex) 
    PolytonicGreek.rmaccents.(lowercase.(rawtext)) |> unique
end


# Compose wordlist for a corpus.
function wordlist(corp::CitableTextCorpus)
    words = []
    for cn in corp.corpus
        push!(words, stringsfornode(cn))
    end
    Iterators.flatten(words) |> collect |> unique |> sort
end

# List scholia and Iliad separately
iliadurn = CtsUrn("urn:cts:greekLit:tlg0012.tlg001:")
scholiaurn = CtsUrn("urn:cts:greekLit:tlg5026:")
iliad = filter(cn -> urncontains(iliadurn, cn.urn), c)|> CitableTextCorpus
scholia = filter(cn -> urncontains(scholiaurn, cn.urn), c)|> CitableTextCorpus

iliadwords = wordlist(iliad)
open("data/wordlist-iliadl.txt", "w") do io
    write(io, join(words,"\n"))
end

scholiawords = wordlist(scholia)
open("data/wordlist-scholial.txt", "w") do io
    write(io, join(words,"\n"))
end
