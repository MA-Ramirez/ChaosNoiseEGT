"""
Functions used to define the ODEs of the deterministic system.
"""

using DrWatson

include(srcdir("PayoffMatrix.jl"))

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
