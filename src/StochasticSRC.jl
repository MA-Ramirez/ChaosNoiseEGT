"""
Functions used to define the stochastic pairwise comparison process
"""

using DrWatson

include(srcdir("PayoffMatrix.jl"))


################################################################################
#                      PAIRWISE COMPARISON PROCESS functions                   #
################################################################################

"""
    picktype_randomly(num_types) → Int64
Randomly picks a type among the different types present in the population
Generates and returns a random number from the indexable collection `1:num_types`
"""
function pick_type_randomly(num_types)
    random_type = rand(1:num_types)
    return random_type
end

"""
    fitness_values(amounts) → Vector{Float64}
`amounts`: Vector{Int64} contains the amount of individuals of each type in the population
Calculates the fitness values of each type present in the population
"""
function fitness_values(amounts)
    fitness_vals = payoff_matrix*amounts
    return fitness_vals
end

"""
    replacement_probability(fi,fj,B) → Float64
`fi`: fitness of player i
`fi`: fitness of player j
`B`: selection intensity coefficient
Calculates the probability for i to replace j
"""
function replacement_probability(fi,fj,B)
    exponent = -B*(fi-fj)
    deno = 1 + exp(exponent)
    probability = 1.0/deno
    return probability
end

"""
    replacement_decision_update(Player_i,Player_j,amounts,probability) → Vector{Float64}
`Player_i`: type of player i
`Player_i`: type of player j
`amounts`: Vector{Int64} contains the amount of individuals of each type in the population
`B`: selection intensity coefficient
`probability`: probability for i to replace j
Updates the `amounts` vector after one replacement decision
"""
function replacement_decision_update(Player_i,Player_j,amounts,probability)
    #Random number used to take the replacement decision
    randomnumber_decision = rand()

    if randomnumber_decision < probability
        #i replaces j
        amounts[Player_i] += 1
        amounts[Player_j] -= 1
    end
    return amounts
end

"""
    step(amounts,B) → Vector{Float64}
`amounts`: Vector{Int64} contains the amount of individuals of each type in the population
`B`: selection intensity coefficient
Generates a step in the process, returns the updated `amounts` vector
"""
function step(amounts,B)
    num_types = size(payoff_matrix)[1]

    Player_i = pick_type_randomly(num_types)
    Player_j = pick_type_randomly(num_types)

    #If the two randomly chosen individuals are of the same type,
    # there is no need for replacement
    #If A replaces A, the composition of the population doesn't change
    if Player_i != Player_j
        fit_vals = fitness_values(amounts)
        fi = fit_vals[Player_i]
        fj = fit_vals[Player_j]
        probability = replacement_probability(fi,fj,B)
        amounts_update = replacement_decision_update(Player_i,Player_j,amounts,probability)
    else
        amounts_update = amounts
    end

    return amounts_update
end

################################################################################
#                              RUN PROCESS functions                           #
################################################################################

"""
    reach_boundary(amounts) → Boolean
If any of the quantities in `amounts` reaches the boundary, it returns true.
i.e. when any quantity in `amounts` reaches zero (the process should be stopped)
"""
function reach_boundary(amounts)
    stop = false
    for i in amounts
        if i == 0.0
            stop = true
        end
    end
    return stop
end

"""
    run_process(initial_amounts, Beta, time_steps) → Vector{Any}
`Beta`: selection intensity coefficient
It runs the pairwise comparison process step for `time_steps` amount of times.
It returns an array of arrays with the data of the evolution of the process
"""
function run_process(initial_amounts, Beta, time_steps)
    data_process = []

    #Initialise first entry with initial conditions
    push!(data_process,initial_amounts)

    for i in 2:time_steps
        #Deep copy to copy by value not by reference
        prev_step_data = deepcopy(data_process[end])
        step_data = step(prev_step_data,Beta)

        #If any type reaches the boundary, stop the process
        if reach_boundary(step_data) == true
            push!(data_process,step_data)
            break
        end

        push!(data_process,step_data)
    end
    return data_process
end

"""
    normalise_data(data_trajectory, populationsize) → Vector{Vector{Float64}}
It normalises the data of the evolution of the process.
The quantities are now given in relative amounts
"""
function normalise_data(data_trajectory, populationsize)
    size_data_trajectory = size(data_trajectory)[1]
    #Initialise empty array
    normalised_data = fill(Float64[], size_data_trajectory)

    for i in 1:size_data_trajectory
        normalised_data[i] = data_trajectory[i]/populationsize
    end

    return normalised_data
end

"""
    run_full_simulation(initial_amounts, Beta, populationsize, time_steps) → Vector{Vector{Float64}}
`Beta`: selection intensity coefficient
It runs the pairwise comparison process step for `time_steps` amount of times.
It returns an array of arrays with the data of the evolution of the process.
The data is normalised, so the quantities are given in relative amounts.
"""
function run_full_simulation(initial_amounts, Beta, populationsize, time_steps)
    data_process = run_process(initial_amounts, Beta, time_steps)
    normalised_data = normalise_data(data_process, populationsize)

    return normalised_data
end

"""
    full_simulation(initial_amounts, Beta, populationsize, time_steps) → Matrix{Float64}
Returns the results of `run_full_simulation` for easier data handling in the notebook
"""
function full_simulation(initial_amounts, Beta, populationsize, time_steps)
    data_vectors = run_full_simulation(initial_amounts, Beta, populationsize, time_steps)
    data_matrix = reduce(vcat,transpose.(data_vectors))
    return data_matrix
end

################################################################################
#                          SET PARAMETERS functions                            #
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