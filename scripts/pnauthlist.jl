# Create DataFrame for persname authlist, lookup
# labels by URN value
using CSV
using DataFrames
using HTTP

authurl  = "https://raw.githubusercontent.com/homermultitext/hmt-authlists/master/data/hmtnames.cex"
authdf = CSV.File(HTTP.get(authurl).body; delim = "#", header = 2) |> DataFrame



function labelforurn(u, authdf)
    matched = filter( r -> r.urn == u, authdf)
    if nrow(matched) > 1
        @warn "Multiple results for $u !"
        nothing
    elseif nrow(matched) == 0
        @warn "No matches for $u"
    else
        matched[1,:label]
	end
end

labelforurn("urn:cite2:hmt:pers.v1:pers1002", authdf)