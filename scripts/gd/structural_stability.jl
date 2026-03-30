include("deterministic_system_definition.jl")

using Statistics: std, mean
using Distributions: Normal
using Random, DelimitedFiles

std_param = 0.1 # chosen standard deviation for normal distribution perturbing non-zero parameters.

# re-do fig 2
βs = [0.01, 0.1, 1, 10, 100]

"""
original_payoff_matrix = [
    0.0 -0.6 0.0 1.0
    1.0 0.0 0.0 -0.5
    -1.05 -0.2 0.0 1.75
    0.5 -0.1 0.1 0.0
]
"""

N = 10 # random samples for each β value

function obtain_quantifiers(ds)
    β = current_parameter(ds, :β)
    τ = 2/β # use system timescale. Should it be at most some value for large beta?
    λ1 = (2/β)*(lyapunovspectrum(ds, 20_000; Δt = 1.0)[1])
    #X, tvec = trajectory(ds, 25000.0*τ; Δt = τ)
    #fractal_dim_corr = grassberger_proccacia_dim(X; show_progress = false)
    #σ = std(X[:, 1])
    #X, tvec = trajectory(ds, 2500.0*τ; Δt = 0.1τ)
    #x = X[:, 1]
    #lempel_ziv = lempel_ziv_complexity(x)
    #return [β, λ1, fractal_dim_corr, σ, lempel_ziv]
    return [β, λ1]
end

# now run the above function for the original pay off matrix,
# and then repeat for each beta values `N` times

for i in 801:1000
    rng = Xoshiro(i)

    generated_payoff_matrix = [
    0.0 round(rand(rng, Normal(-0.6,std_param));digits=2) round(rand(rng, Normal(0.0,std_param));digits=2) round(rand(rng, Normal(1.0,std_param));digits=2)
    round(rand(rng, Normal(1.0,std_param));digits=2) 0.0 round(rand(rng, Normal(0.0,std_param));digits=2) round(rand(rng, Normal(-0.5,std_param));digits=2)
    round(rand(rng, Normal(-1.05,std_param));digits=2) round(rand(rng, Normal(-0.2,std_param));digits=2) 0.0 round(rand(rng, Normal(1.75,std_param));digits=2)
    round(rand(rng, Normal(0.5,std_param));digits=2) round(rand(rng, Normal(-0.1,std_param));digits=2) round(rand(rng, Normal(0.1,std_param));digits=2) 0.0
    ]

    pcpds = deterministic_pcp_system()
    original_quantities = map(βs) do β
        set_parameter!(pcpds, :β, β)
        set_parameter!(pcpds, :payoff_matrix, generated_payoff_matrix)

        Data = adjoint(obtain_quantifiers(pcpds))
        open(datadir("gd", "struct_stability_01_LE.csv"), "a") do io
            writedlm(io, Data,",")
        end
    end
end
"""

pcpds = deterministic_pcp_system()
original_quantities = map(βs) do β
    set_parameter!(pcpds, :β, β)

    Data = adjoint(obtain_quantifiers(pcpds))
    open(datadir("gd", "struct_stability_ori.csv"), "a") do io
        writedlm(io, Data,",")
    end
end
"""


# todo...
#writedlm(datadir("Deterministic", savename("Det", params, "txt")), Data)