"""
Script to produce Fourier spectra graph of the deterministic trajectories
"""

using DrWatson
@quickactivate "ChaosNoiseEGT"

include(srcdir("PayoffMatrix.jl"))
include(srcdir("DeterministicSRC.jl"))
include(srcdir("Quantifiers.jl"))

using DynamicalSystems
using PyCall
using LaTeXStrings

@pyimport matplotlib.pyplot as plt
@pyimport matplotlib.cm as cm

##################################################
#                    Parameters                  #
##################################################

ini_con = [0.25,0.25,0.25,0.25]

#There is a "dummy" value, such that colors are in agreement with other graphs of ms
B = [1000.0,100.0,10.0,1.0,0.1,0.01,0.001,"dummy"]
labels=["1000.0","100.0","10.0","1.0","0.1","0.01","0.001"]
sizeB = size(B)[1]-1
xlim_vals = [0.000,0.2]

##################################################
#                 GENERATE DATA                 #
##################################################
"""
    generate_data(ini_condition, beta) → StateSpaceSet{Float64}
Generates trajectory for the specified `ini_condition` and `beta`
"""
function generate_data(ini_condition, beta)
    ODE_sys = ContinuousDynamicalSystem(dynamic_rule_PCP!, ini_condition, beta)
    Data, t = generate_trajectory(ODE_sys, beta)
    return Data
end

##################################################
#                       PLOT                     #
##################################################

# Get colormap for the beta values
colors = get_colors(B)

#Initialise figure
fig,axs = plt.subplots(sizeB,1,sharex=true,figsize=(6,6))
fig.suptitle("Fourier spectra")
label_container = []

#Generates plot with subplots for all beta values
for i in 1:sizeB
    Data = generate_data(ini_con, B[i])
    #Generate fourier spectrum
    freq, amp = fourier_spectrum(Data)

    #Plot
    l,=axs[i].plot(freq,amp,color = colors[i])
    #label related code
    push!(label_container,l)

    #Aesthetics
    plt.xlim((xlim_vals[1],xlim_vals[2]))

    if i < 3
        axs[i].set_ylim(top=2000.0)
    else
        axs[i].set_ylim(top=6000.0)
    end

    if i == 4
        axs[i].set(ylabel="Amplitude")
    end
end

#Aesthetics
plt.xlabel("Frequency")
fig.legend(label_container, labels=labels,bbox_to_anchor=(0.95, 0.92),title=L"\beta",fontsize="small", framealpha = 1.0)
plt.tight_layout()

#Save figure
plt.savefig(plotsdir("Deterministic/","Fourier_Spectra_Det.pdf"))