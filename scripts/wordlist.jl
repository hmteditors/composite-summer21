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

words = wordlist(c)
open("wordlist.txt", "w") do io
    write(io, join(words,"\n"))
end
