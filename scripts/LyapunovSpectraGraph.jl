"""
Script to produce Lyapunov spectra graph of the deterministic trajectories
"""

using DrWatson
@quickactivate "ChaosNoiseEGT"

include(srcdir("PayoffMatrix.jl"))
include(srcdir("DeterministicSRC.jl"))
include(srcdir("Quantifiers.jl"))

using DynamicalSystems
using PyCall
using LaTeXStrings
using DelimitedFiles
using OrdinaryDiffEq

@pyimport matplotlib.pyplot as plt
@pyimport matplotlib.cm as cm

##################################################
#                    Parameters                  #
##################################################

ini_condition = [0.25,0.25,0.25,0.25]

#Selection intensity coefficient
#B = [0.001,0.01,0.1,1.0,10.0]
#B = [100.0,1000.0]
B = [0.01,0.1,1.0]

#Evolution steps
T = [10,100,1000,1000,5000,10000,50000,100000]

##################################################
#                 GENERATE DATA                 #
##################################################
"""
    generate_data(ini_condition, beta) → StateSpaceSet{Float64}
Generates trajectory for the specified `ini_condition` and `beta`
"""
function generate_data(ini_condition, beta)
    ODE_sys = ContinuousDynamicalSystem(dynamic_rule_PCP!, ini_condition, beta, diffeq=(abstol = 1.0e-9,reltol = 1.0e-9, alg=Vern9()))
    Data, t = generate_trajectory(ODE_sys, beta)
    return Data
end

##################################################
#                       PLOT                     #
##################################################
#LE = Vector{Float64}(undef,size(T)[1])
exponent1 = Vector{Float64}(undef,size(T)[1])
exponent2 = Vector{Float64}(undef,size(T)[1])
exponent3 = Vector{Float64}(undef,size(T)[1])
largest_exponent = Vector{Float64}(undef,size(T)[1])

for beta in B

    for i in 1:size(T)[1]
        ODE_sys = ContinuousDynamicalSystem(dynamic_rule_PCP!, ini_condition, beta, diffeq=(abstol = 1.0e-9,reltol = 1.0e-9, alg=Vern9()))
        lyapunov_spectrum = lyapunovspectrum(ODE_sys, i, 3; Ttr = 40000)
        exponent1[i] = lyapunov_spectrum[1]
        exponent2[i] = lyapunov_spectrum[2]
        exponent3[i] = lyapunov_spectrum[3]
        #push!(exponent1,lyapunov_spectrum[2])
    
        largest_lyapunov = lyapunov(ODE_sys, i)
        largest_exponent[i] = largest_lyapunov
        #push!(LLE, largest_lyapunov)
    end

    #-----------------LYAPUNOV SPECTRUM----------------#
    plt.plot(T,exponent1, color="red", label="k=1")
    plt.plot(T,exponent2, color="gray", label="k=2")
    plt.plot(T,exponent3, color="blue", label="k=3")
    println("Exponent 1 : "* string(exponent1[end]))
    #println(exponent1)
    println("Exponent 2 : "* string(exponent2[end]))
    #println(exponent2)
    println("Exponent 3 : "* string(exponent3[end]))
    #println(exponent3)

    #Aesthetics
    plt.xlabel("Time steps (t)")
    plt.ylabel("Lyapunov exponent")
    plt.title("Largest Lyapunov exponent vs time steps")
    plt.legend(loc="upper right",title="Lyapunov exponent")
    plt.tight_layout()
    #plt.ylim(0,0.001)
    #plt.yscale("log")

    #Save figure
    plt.savefig(plotsdir("Deterministic/LyapunovExponents","LyapunovSpectrum_"*string(beta)*".png"))
    plt.clf()

    #-----------------LARGEST EXPONENT----------------#
    plt.plot(T, largest_exponent)
    println("Largest exponent : "* string(largest_exponent[end]))
    #println(largest_exponent)
    #Aesthetics
    plt.xlabel("Time steps (t)")
    plt.ylabel("Lyapunov exponent")
    plt.title("Largest Lyapunov exponent vs time steps")
    #plt.yscale("log")

    info_LE = adjoint([beta,exponent1[end], exponent2[end], exponent3[end], largest_exponent[end]])
    open(datadir("Quantifiers/QuantifiersDet", "Det_LE.csv"), "a") do io
        writedlm(io, info_LE,",")
    end

    #Save figure
    plt.savefig(plotsdir("Deterministic/LyapunovExponents","LargestExponent_"*string(beta)*".png"))
end