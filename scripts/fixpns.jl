using CitableCorpus
using CitableObject
using CitableText
using EzXML


f = "data/archive-xml.cex"
archival = CitableCorpus.fromfile(CitableTextCorpus, f)


errors = []
for cn in archival.corpus
    root = parsexml(cn.text).root
    pns = findall("//persName", root)
    for pn in pns
        if haskey(pn, "n")
            try
                pnurn = Cite2Urn(pn["n"])
            catch e
                push!(errors, (cn.urn.urn, "Bad URN value " * pn["n"]))
            end
        else
            push!(errors, (cn.urn.urn, "No @n attribute"))
        end
    end
end

count = 0
for cn in archival.corpus
    root = parsexml(cn.text).root
    pns = findall("//persName", root)
    count = count + length(pns)
end
println("Total pns: ", count)



verifiable = Dict()
# Prepare data for verification
for cn in archival.corpus
    root = parsexml(cn.text).root
    pns = findall("//persName", root)
    for pn in pns
        if haskey(pn, "n")
            try
                pnurn = Cite2Urn(pn["n"])
                if haskey(verifiable, pnurn.urn)
                    prevv = verifiable[pnurn.urn]
                    push!(prevv, pn.content)
                    verifiable[pnurn.urn] = unique(prevv)
                else
                    verifiable[pnurn.urn] = [pn.content]
                end
            catch e
                @warn "Skipping $(pn.content) with bad URN value"
                #/ush!(errors, (cn.urn.urn, "Bad URN value " * pn["n"]))
            end
        else
            @warn "Skipping $(pn.content) with no @n attribute"
            #push!(errors, (cn.urn.urn, "No @n attribute"))
        end
    end    
end


mdentries = []
for k in keys(verifiable)
    mdentry = ["## $k",""]
    for s in verifiable[k]
        push!(mdentry, "- $s")
    end
    push!(mdentries, join(mdentry, "\n"))
end

open("pn-verification.md", "w") do io
write(io, join(mdentries, "\n\n"))
end