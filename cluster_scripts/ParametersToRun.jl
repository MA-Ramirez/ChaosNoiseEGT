"""
Script used to determine the parameters for which the stochastic simulations will be run
"""

using DelimitedFiles

BN = [0,50.0,75.0,100.0,250.0,500.0,750.0,1000.0]
N = [100,250,500,1000,2500,5000,10000,25000,50000]

for i in BN
    for j in N
        beta = i/j
        params = Any[beta,j]
        #The parameters are saved in cluster_scripts
        open("cluster_scripts/Parameters.txt", "a") do io
            writedlm(io, adjoint(params), " ")
        end
    end
end
