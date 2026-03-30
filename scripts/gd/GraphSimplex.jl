include("deterministic_system_definition.jl")
include(srcdir("Graphs.jl"))

using Random
using Distributions: Normal

ds = deterministic_pcp_system()
#βs = 10 .^ range(-2, 3; length = 51)
β = 0.01
τ = 2/β
#τ = 1.0

#Data, tvec = trajectory(ds, 25000.0*τ; Δt = τ)
#Data, tvec = trajectory(ds, 2500.0*τ; Δt = τ)
#ternary_plot(Data[:,1],Data[:,2],Data[:,3])
#plt.show()

#33 34 61 99
rng = Xoshiro(870)
std_param = 0.1

generated_payoff_matrix = [
    0.0 round(rand(rng, Normal(-0.6,std_param));digits=2) round(rand(rng, Normal(0.0,std_param));digits=2) round(rand(rng, Normal(1.0,std_param));digits=2)
    round(rand(rng, Normal(1.0,std_param));digits=2) 0.0 round(rand(rng, Normal(0.0,std_param));digits=2) round(rand(rng, Normal(-0.5,std_param));digits=2)
    round(rand(rng, Normal(-1.05,std_param));digits=2) round(rand(rng, Normal(-0.2,std_param));digits=2) 0.0 round(rand(rng, Normal(1.75,std_param));digits=2)
    round(rand(rng, Normal(0.5,std_param));digits=2) round(rand(rng, Normal(-0.1,std_param));digits=2) round(rand(rng, Normal(0.1,std_param));digits=2) 0.0
    ]

display(generated_payoff_matrix)

set_parameter!(ds, :β, β)
set_parameter!(ds, :payoff_matrix, generated_payoff_matrix)

Data, tvec = trajectory(ds, 25000.0*τ; Δt = τ)
println((2/β)*(lyapunovspectrum(ds, 20_000; Δt = 1.0)[1]))
ternary_plot(Data[:,1],Data[:,2],Data[:,3])
plt.show()