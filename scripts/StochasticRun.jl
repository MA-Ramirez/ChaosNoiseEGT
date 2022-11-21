"""
Script used to run the stochastic process and save the data in data folder.
"""

using DrWatson
@quickactivate "ChaosNoiseEGT"

include(srcdir("StochasticSRC.jl"))

using DelimitedFiles

################################################################################
#                          Set parameters functions                            #
################################################################################

"""
    set_initial_conditions(populationsize) → Vector{Float64}
The Skyrms' attractor can be properly seen starting with initial conditions
close to the center of the simplex
"""
function set_initial_conditions(populationsize)
    scaling_factor = 0.25
    #Amount of individuals is an integer
    A_ini = round(populationsize*scaling_factor)
    B_ini = A_ini
    C_ini = A_ini
    D_ini = A_ini
    return [A_ini,B_ini,C_ini,D_ini]
end

"""
    set_timesteps(populationsize) → Int64
It sets the amount of time steps, such that the number of generations is fixed for
all population sizes
The constant factor is approximated visually, such that the time steps are enough to visualise
the attractor and for the running time of the quantifiers doesn't explode
"""
function set_timesteps(populationsize)
    constant_factor = 0.1
    tau = Int(populationsize/constant_factor)
    return tau
end

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
    throw(ArgumentError("There should be 3 command line arguments, but there are "*string(num_arguments)))
end

#Obtain arguments and define them as global variables
#Selection intensity coefficient
B = parse(Float64,ARGS[1])
#Population size
N = parse(Int64,ARGS[2])

#Time steps
T = set_timesteps(N)

println(T)

#Initial conditions
ini_con = set_initial_conditions(N)

#Dictionary of parameters
params = @strdict B N

################################################################################
#                                   Run process                                #
################################################################################

data_full_process = run_process(ini_con, N, B, T)

data = normalise_data(data_full_process, N)

################################################################################
#                                   Save data                                  #
################################################################################

#The solution is saved in data/Stochastic
writedlm(datadir("Stochastic", savename("Sto", params, "txt")), data)
