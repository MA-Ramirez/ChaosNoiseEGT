"""
Script used to determine the parameters for which the stochastic simulations will be run
"""

using DelimitedFiles

B = [0.0,5.0,7.0,10.0,15.0,25.0,35.0,50.0,100.0,1000.0]
N = [100,500,1000,1500,2000,2500,3000]

for i in B
    for j in N
        params = Any[i,j]
        #The parameters are saved in cluster_scripts
        open("cluster_scripts/Parameters.txt", "a") do io
            writedlm(io, adjoint(params), " ")
        end
    end
end
