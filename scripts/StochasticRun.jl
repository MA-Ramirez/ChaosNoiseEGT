"""
Script used to run the stochastic process and save the data in data folder.
"""

using DrWatson
@quickactivate "ChaosNoiseEGT"

include(srcdir("StochasticSRC.jl"))

using DelimitedFiles

################################################################################
#                                Set parameters                                #
################################################################################

#Check correct input of parameters
num_arguments = size(ARGS)[1]
if num_arguments == 1
    APPROACH = "Deterministic"
elseif num_arguments == 2
    APPROACH = "Stochastic"
else
    throw(ArgumentError("There should be 2 command line arguments, but there are "*string(num_arguments)))
end

#Obtain arguments and define them as global variables
#Selection intensity coefficient
B = parse(Float64,ARGS[1])
#Population size
N = parse(Int64,ARGS[2])

#Time steps
#T = set_timesteps(N)
T = set_timesteps_FD(N)

#Initial conditions
#ini_con = set_initial_conditions(N)
ini_con = [0.25,0.25,0.25,0.25]

#Dictionary of parameters
params = @strdict B N

################################################################################
#                                   Run process                                #
################################################################################

data = run_full_simulation(ini_con, B, N, T)

################################################################################
#                                   Save data                                  #
################################################################################

#The solution is saved in data/Stochastic
writedlm(datadir("Stochastic", savename("Sto", params, "txt")), data)
