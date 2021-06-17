using CSV
using DataFrames
using CitableText
using Plots


# Read data in a DataFrame, and group
f = string(pwd(), "/data/scholia-tokens.cex")
df = CSV.File(f; delim = "|") |> DataFrame
#urns = map(u -> CtsUrn(u), df[:, :urn])
tkns = map(s -> lowercase(s), df[:, :token])
tkndf = DataFrame(token = tkns)
tkncounts = groupby(tkndf, :token)

prs = []
for k in keys(tkncounts)
    push!(prs, (nrow(tkncounts[k]), k.token, ))
end

histdata = sort(prs; rev=true)


labels = map(pr -> pr[2], histdata)
counts = map(pr -> pr[1], histdata)


lmt = 20
xtix = (1:lmt, labels[1:lmt])

#bar(1:12, orientation=:h, yticks=(1:12, ticklabel), yflip=true)
bar(counts[1:lmt], xticks=xtix, xrotation=45, xlabel="Term", label="Number of occurrences", bar_width=0.7)