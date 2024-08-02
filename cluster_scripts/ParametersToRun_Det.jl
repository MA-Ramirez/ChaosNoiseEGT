"""
Script used to determine the parameters for which the deterministic quantifiers will be measured
"""

using DelimitedFiles

for i in -2:0.1:3
    ans = round(10^i,digits=3)
    open("cluster_scripts/ParametersDet_Quant.txt", "a") do io
        writedlm(io, ans, " ")
    end
end