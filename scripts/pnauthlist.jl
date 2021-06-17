using CSV
using DataFrames
using HTTP

authurl  = "https://raw.githubusercontent.com/homermultitext/hmt-authlists/master/data/hmtnames.cex"
authdf = CSV.File(HTTP.get(authurl).body) |> DataFrame
nrow(authdf)