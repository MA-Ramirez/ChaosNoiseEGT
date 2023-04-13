"""
Script used to determine the parameters for which the stochastic simulations will be run
"""

using DelimitedFiles

B = [0,0.005,0.01,0.05,0.1,0.5,1.0,10.0]
N = [100,250,500,750,1000,2500,5000,7500,10000,25000,50000]

for i in B
    for j in N
        params = Any[i,j]
        #The parameters are saved in cluster_scripts
        open("cluster_scripts/Parameters.txt", "a") do io
            writedlm(io, adjoint(params), " ")
        end
    end
end
