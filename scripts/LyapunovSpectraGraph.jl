"""
Script to produce Lyapunov spectra graph of the deterministic trajectories
    graphs plot Lyapunov exponents vs time steps required for the value of the exponents to converge
"""

using DrWatson
@quickactivate "ChaosNoiseEGT"

include(srcdir("DeterministicSRC.jl"))

using DynamicalSystems, DelimitedFiles, DataFrames, CSV
using PyPlot, LaTeXStrings

##################################################
#                    Parameters                  #
##################################################

ini_condition = [0.25,0.25,0.25,0.25]

#Selection intensity coefficient
B_array = [0.01,0.1,1.0]

#Evolution steps
T_array = [100,1_000,5_000,10_000,50_000,100_000,500_000,1_000_000]

######################################################
#                  COMPUTE EXPONENTS                 #
######################################################
"""
    compute_exponents(ini_con, beta, total_steps) → csv file
Computes the lyapunov exponents for the specified arguments
Outputs the results into csv files. Each `beta` value outputs a file.
"""
function compute_exponents(ini_con, beta, total_steps)
    ODE_sys = ContinuousDynamicalSystem(dynamic_rule_PCP!, ini_con, beta, diffeq=(abstol = 1.0e-9,reltol = 1.0e-9))
    LE_spectrum = lyapunovspectrum(ODE_sys, total_steps, 4)

    info_LE = adjoint([total_steps, LE_spectrum[1], LE_spectrum[2], LE_spectrum[3], LE_spectrum[4]])
    open(datadir("Quantifiers/QuantifiersDet/LyapunovExponents", "Plot_LE_"*string(beta)*".csv"), "a") do io
        writedlm(io, info_LE,",")
    end
end

#-------- RUN IT --------#
"""
for t in T_array
    for b in B_array
        compute_exponents(ini_condition, b, t)
    end
end
"""

##################################################
#                       PLOT                     #
##################################################

"""
    getdata(beta) → DataFrame
`beta`: selection intensity coefficient
Imports data from files and returns it as a Dataframe
"""
function getdata(beta)
        data = DataFrame(CSV.File(datadir("Quantifiers/QuantifiersDet/LyapunovExponents", "Plot_LE_"*string(beta)*".csv")))
    return data
end

"""
    plot_exponents(beta) → pdf file
`beta`: selection intensity coefficient
Plots the Lyapunov exponents vs evolution steps
    It plots the 4th exponent in a separate subplot due to magnitude differences
"""
function plot_exponents(beta)
    Data = getdata(beta)

    #Define subplots
    fig, axs = subplots(2, sharex=true, figsize= (7,5), height_ratios=[2,1])

    #Common x axis
    xlabel("Time steps ("*L"t"*")")
    xscale("log")

    #Colors
    cm = get_cmap(:viridis)

     #Plot first 3 exponents
     for i in 2:4
        axs[1].plot(Data[:,1],Data[:,i],label=string(i-1),marker="o", markersize=3,c=cm((i-2)/4))
    end
    axs[1].locator_params(axis="y", nbins=5)
    axs[1].set_ylabel("Lyapunov exponents ("*L"λ_i"*")", fontsize="x-small")

    #Plot 4th exponent
    axs[2].plot(Data[:,1],Data[:,5],label=string(5-1),marker="o", markersize=3,c=cm((5-2)/4))
    axs[2].locator_params(axis="y", nbins=3)
    axs[2].set_ylabel("Lyapunov exponent ("*L"λ_4"*")", fontsize="x-small")
    #axs[2].set_ylim((-0.0073,-0.0071))

    tight_layout()

    #Save figure
    savefig(plotsdir("Deterministic/LyapunovExponents","LyapunovSpectrum_"*string(beta)*".pdf"))
    clf()
end

#-------- PyPlot IT --------#
plot_exponents(0.01)
plot_exponents(0.1)
plot_exponents(1.0)