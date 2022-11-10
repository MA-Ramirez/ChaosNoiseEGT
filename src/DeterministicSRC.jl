"""
Functions used to define the ODEs of the deterministic system.
"""

using DrWatson

include(srcdir("PayoffMatrix.jl"))

@inline @inbounds function dynamic_rule_PCP(u, p, t)
    """
        DynamicRulePCP(u, p, t) → SVector{4}

    Dynamic rule of the deterministic system
    General deterministic description of the Pairwise Comparison Process
    It consists of a set of 4 ordinary differential equations, because the payoff
    matrix proposed by Skyrms defines 4 different strategies.
    """

    #Input parameters - Selection intensity coefficient
    B = p[1];

    #Variables
    x1=u[1]; x2=u[2]; x3=u[3]; x4=u[4]

    #Vector of variables
    X = [x1,x2,x3,x4]

    #Fitness values
    f1 = (A*X)[1]
    f2 = (A*X)[2]
    f3 = (A*X)[3]
    f4 = (A*X)[4]

    #Equations of motion
    du1 = x1*(x2*tanh((B/2.0)*(f1-f2)) + x3*tanh((B/2.0)*(f1-f3)) + x4*tanh((B/2.0)*(f1-f4)))
    du2 = x2*(x1*tanh((B/2.0)*(f2-f1)) + x3*tanh((B/2.0)*(f2-f3)) + x4*tanh((B/2.0)*(f2-f4)))
    du3 = x3*(x1*tanh((B/2.0)*(f3-f1)) + x2*tanh((B/2.0)*(f3-f2)) + x4*tanh((B/2.0)*(f3-f4)))
    du4 = x4*(x1*tanh((B/2.0)*(f4-f1)) + x2*tanh((B/2.0)*(f4-f2)) + x3*tanh((B/2.0)*(f4-f3)))

    #Output
    return SVector{4}(du1, du2, du3, du4)
end

"""
    initial_conditions(ini_x1,ini_x2,ini_x3,ini_x4) → Vector{Float64}
Define initial conditions. (4 variables to define)
"""
function initial_conditions(ini_x1,ini_x2,ini_x3,ini_x4)

    ini_con = [ini_x1,ini_x2,ini_x3,ini_x4]

    #Initial conditions should fulfil normalisation condition
    if sum(ini_con) != 1
        msg = "ERROR: Sum of all initial conditions should be equal to 1"
        return msg
    else
        return ini_con
    end
end
