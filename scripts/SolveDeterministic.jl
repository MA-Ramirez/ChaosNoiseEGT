"""
Script used to solve ODEs and save the solution in data folder.
"""

using DrWatson
@quickactivate "ChaosNoiseEGT"

include(srcdir("PayoffMatrix.jl"))
include(srcdir("DeterministicSRC.jl"))

using DynamicalSystems
using DelimitedFiles

################################################################################
#                               Set parameters                                 #
################################################################################

#Initial conditions
#The initial conditions are fixed, because these ones work very well to view the
# Skyrms' attractor
ini_con = initial_conditions(0.25,0.25,0.25,0.25)

#Selection intensity coefficient
B = 0.01

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
ds = ContinuousDynamicalSystem(dynamic_rule_PCP, ini_con, B)


"""
    trajectory(ds::GeneralizedDynamicalSystem, T [, u]; kwargs...) → dataset
Return a dataset that will contain the trajectory of the system `ds`,
after evolving it for total time `T`, optionally starting from state `u`.

`Δt`: Time step of value output. For discrete systems it must be an integer. Defaults to 0.01

Lower B requires a longer time interval to view the attractor. Therefore, use upper options
for low B values, to keep time steps constant.

`data = trajectory(ds,10000000; Δt = 100.0)`    --> B=0.001
`data = trajectory(ds,1000000; Δt = 10.0)`      --> B=0.01
`data = trajectory(ds,100000; Δt = 1.0)`        --> B=0.1
`data = trajectory(ds,10000;Δt = 0.1)`          --> B=1.0 B=10.0
`data = trajectory(ds,1000;Δt = 0.01)`          --> B=100.0

"""
data = trajectory(ds,1000000; Δt = 10.0)


#Save solution of the ODEs system
#The solution is saved in data/Deterministic
writedlm(datadir("Deterministic", savename("Det", params, "txt")), data)
