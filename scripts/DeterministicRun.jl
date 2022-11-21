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
ds = ContinuousDynamicalSystem(dynamic_rule_PCP!, ini_con, B)


"""
    adaptive_timestep(Beta) → dataset
Calculates the trajectory for a given Beta adjusting the time interval and the
time step value, such that the number of time steps is fixed

It uses the method
    trajectory(ds::GeneralizedDynamicalSystem, T [, u]; kwargs...) → dataset
Return a dataset that will contain the trajectory of the system `ds`,
after evolving it for total time `T`, optionally starting from state `u`.

`Δt`: Time step of value output. For discrete systems it must be an integer. Defaults to 0.01

Values to keep number of time steps constant, to be able to see the attractor for all beta values.

Values to keep number of times step = 1x10^5 constant
(Visual approx.)
T = 10000000; Δt = 100.0     --> B=0.001
T = 1000000; Δt = 10.0       --> B=0.005 B=0.01
T = 100000; Δt = 1.0         --> B=0.05 B=0.1
T = 10000; Δt = 0.1          --> B=0.5 B=1.0 B=10.0
T = 1000; Δt = 0.01          --> B=100.0
"""
function adaptive_timestep(Beta)
    T = 0
    dt = 0
    if Beta < 0.005
        T = 10000000
        dt = 100.0
    elseif Beta < 0.05
        T = 1000000
        dt = 10.0
    elseif Beta < 0.5
        T = 100000
        dt = 1.0
    elseif Beta < 100.0
        T = 10000
        dt = 0.1
    else
        T = 1000
        dt = 0.01
    end
    data = trajectory(ds,T; Δt = dt)
    return data
end

################################################################################
#                                   Save data                                 #
################################################################################

Data = adaptive_timestep(B)

#Save solution of the ODEs system
#The solution is saved in data/Deterministic
writedlm(datadir("Deterministic", savename("Det", params, "txt")), Data)
