"""
Script used to determine the parameters for which the deterministic quantifiers will be measured
"""

using DelimitedFiles

for i in 0.01:0.01:0.1
    open("cluster_scripts/ParametersDet_Quant.txt", "a") do io
        writedlm(io, i, " ")
    end
end

for i in 0.2:0.1:1.0
    open("cluster_scripts/ParametersDet_Quant.txt", "a") do io
        writedlm(io, i, " ")
    end
end

for i in 2.0:1.0:10.0
    open("cluster_scripts/ParametersDet_Quant.txt", "a") do io
        writedlm(io, i, " ")
    end
end   

for i in 20.0:10.0:100.0
    open("cluster_scripts/ParametersDet_Quant.txt", "a") do io
        writedlm(io, i, " ")
    end
end   

for i in 200.0:100.0:1000.0
    open("cluster_scripts/ParametersDet_Quant.txt", "a") do io
        writedlm(io, i, " ")
    end
end 