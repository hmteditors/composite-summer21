println("Executing in ", pwd())
outfile = "docs/coverage.md"

# Page content as individual lines of markdown:
mdlines = ["---","layout: page",
"title: \"Current coverage of editing\"",
"nav_order: 1", "---","","","# Current coverage of editing",""]

using Dates
datestamp = "Last modified: $(now())"
push!(mdlines, datestamp)

open(outfile,"w") do io
    write(io, join(mdlines,"\n"))
end

