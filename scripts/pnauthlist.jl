using CSV
using DataFrames
using HTTP

authurl  = "https://raw.githubusercontent.com/homermultitext/hmt-authlists/master/data/hmtnames.cex"
authdf = CSV.File(HTTP.get(authurl).body; delim = "#", header = 2) |> DataFrame

u = "urn:cite2:hmt:pers.v1:pers1"
matched = filter( r -> r.urn == u, authdf)

matched[1,:label]
function labelforurn(u)
	
end