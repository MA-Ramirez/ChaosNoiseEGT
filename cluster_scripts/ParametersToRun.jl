"""
Script used to determine the parameters for which the stochastic simulations will be run
"""

using DelimitedFiles

#General quantifiers
N = [100, 500, 1000, 5000, 10000, 50000, 100000]
#Fractal dimension
#N = [100, 500, 1000, 1500, 2000, 2500, 3000]

for i in 0.7:0.1:2.9
    for j in N
        B = round(10^i)
        params = Any[B,j]
        #The parameters are saved in cluster_scripts
        open("cluster_scripts/Parameters_Blog.txt", "a") do io
        #open("cluster_scripts/Parameters_FD.txt", "a") do io
            writedlm(io, adjoint(params), " ")
        end
    end
end