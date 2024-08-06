"""
Functions used to define the ODEs of the deterministic system.
"""

using DrWatson

include(srcdir("PayoffMatrix.jl"))

#-----------------------------------------
#------Pairwise Comparison Process--------
#-----------------------------------------

@inline @inbounds function dynamic_rule_PCP!(du, u, p, t)
    """
        dynamic_rule_PCP!(du, u, p, t)

    Dynamic rule of the deterministic system
    General deterministic description of the Pairwise Comparison Process
    It consists of a set of n ordinary differential equations.
    n is defined by the dimension of the nxn payoff matrix
    The dynamic rule is defined in-place (eom!(du, u, p, t)), for it to be easily
    extendable.
    """

    #Input parameter - Selection intensity coefficient
    B = p[1];

    #Number of equations = dimension payoff matrix
    n = size(payoff_matrix)[1]

    #Define vector of variables
    X = []
    for i in 1:n
        push!(X,u[i])
    end

    #Define fitness values
    f = []
    for i in 1:n
        push!(f,(payoff_matrix*X)[i])
    end

    #Equations of motion
    for i in 1:n
        inner_term = 0
        for j in 1:n
            if i != j
                element_term = X[j]*tanh((B/2.0)*(f[i]-f[j]))
                inner_term += element_term
            end
            du[i] = X[i]*(inner_term)
        end
    end

    #Output
    return
end

"""
    generate_trajectory(Beta) → StateSpaceSet, StepRangeLen
Calculates the trajectory for a given Beta adjusting the time interval and the
time step value, such that the number of time steps is fixed

Output:
* StateSpaceSet: d-dimensional StateSpaceSet
* StepRangeLen: range of the stepping time

It uses the method
    trajectory(ds::GeneralizedDynamicalSystem, T [, u]; kwargs...) → StateSpaceSet
Return a `StateSpaceSet` that contains the trajectory of the system `ds`,
after evolving it for total time `T`, optionally starting from state `u`.

`Δt`: Time step of value output. For discrete systems it must be an integer. Defaults to 0.01

Values to keep number of time steps constant, to be able to see the attractor for all beta values.

Values to keep number of times step = 1x10^5 constant
(General approximation)
T = 10000000; Δt = 100.0     --> B=0.001
T = 1000000; Δt = 10.0       --> B=0.005 B=0.01
T = 100000; Δt = 1.0         --> B=0.05 B=0.1
T = 10000; Δt = 0.1          --> B=0.5 B=1.0 B=10.0
T = 1000; Δt = 0.01          --> B=100.0

From this aprox we get the relations
T = 10^4/Beta
dt = 0.1/Beta
"""

function generate_trajectory(ds, Beta)
    total_time = 10^4/Beta
    dt = 0.1/Beta
    data, t = trajectory(ds, total_time; Δt = dt)
    return data, t
end

#-----------------------------------------
#----------Replicator equation------------
#-----------------------------------------

@inline @inbounds function replicator_equation!(du, u, p, t)
    #Input parameter - Selection intensity coefficient
    #B = p[1];

    #Number of equations = dimension payoff matrix
    n = size(payoff_matrix)[1]

    #Define vector of variables
    X = []
    for i in 1:n
        push!(X,u[i])
    end

    #Define fitness values
    f = []
    for i in 1:n
        push!(f,(payoff_matrix*X)[i])
    end

    #Average fitness
    avg_fitness = transpose(X)*payoff_matrix*X

    #ODE system
    for i in 1:n
        du[i] = X[i]*(f[i] - avg_fitness)
    end

    #Output
    return
end