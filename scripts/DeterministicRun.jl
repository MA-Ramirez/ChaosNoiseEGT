"""
Script used to solve ODEs and save the solution in data folder.
"""

using DrWatson
@quickactivate "ChaosNoiseEGT"

include(srcdir("DeterministicSRC.jl"))

using DynamicalSystems
using DelimitedFiles

################################################################################
#                               Set parameters                                 #
################################################################################

"""
The initial conditions should fulfil the normalisation condition
i.e. sum(x_i) = 1
The Skyrms' attractor can be properly seen starting with initial conditions
close to the center of the simplex
"""
#Initial conditions
ini_con = [0.25,0.25,0.25,0.25]

#Check correct input of parameters
num_arguments = size(ARGS)[1]
if num_arguments != 1
    throw(ArgumentError("There should be 1 command line argument B, but there are "*string(num_arguments)))
end

#Selection intensity coefficient
B = parse(Float64,ARGS[1])

#Dictionary of parameters
params = @strdict B

################################################################################
#                     Generate and evolve dynamical system                     #
################################################################################

"""
    ContinuousDynamicalSystem(f, state, p [, jacobian [, J0]]; t0 = 0.0)
-`f`: dynamic rule (ODEs definition)
-`state`: initial conditions
-`p`: parameters

Generate dynamical system using DynamicalSystems package
"""
ds = ContinuousDynamicalSystem(dynamic_rule_PCP!, ini_con, B)

Data, t = generate_trajectory(ds, B)

################################################################################
#                                   Save data                                 #
################################################################################

#Save solution of the ODEs system
#The solution is saved in data/Deterministic
writedlm(datadir("Deterministic", savename("Det", params, "txt")), Data)
