"""
Script used to graph the solution of the ODEs that is saved in the data folder.
"""

using DrWatson
@quickactivate "ChaosNoiseEGT"

using DelimitedFiles
using PyCall
using LaTeXStrings

@pyimport matplotlib.pyplot as plt
@pyimport mpltern

################################################################################
#                            Import trajectory data                          #
################################################################################

#Dictionary of names of all the files in data/Deterministic
dataFiles_Names = readdir(datadir("Deterministic"))

firstsim = dataFiles_Names[1]

data = readdlm(datadir("Deterministic", firstsim))

#Each variable of the system
x1 = data[:,1]
x2 = data[:,2]
x3 = data[:,3]
x4 = data[:,4]


################################################################################
#                            Generate ternary plot                             #
################################################################################

"""
Generates simplex using mpltern package.
Mpltern is a Python plotting library based on Matplotlib specifically designed
for ternary plots.
A similar library with the quality of mpltern is not yet available in Julia.
"""
function ternary_plot(namefile,x1,x2,x3)
    ax = plt.subplot(projection="ternary")

    #Generate plot
    ax.plot(x1,x2,x3,c="g",linewidth=1.0)

    #Initialize grid
    ax.grid(linestyle="--",linewidth=0.5,alpha=0.5)

    #Set labels
    ax.set_tlabel(L"x_1")
    ax.set_llabel(L"x_2")
    ax.set_rlabel(L"x_3")

    # Color ticks, grids, tick-labels
    ax.taxis.set_tick_params(tick2On=true, colors="darkgoldenrod", grid_color="darkgoldenrod")
    ax.laxis.set_tick_params(tick2On=true, colors="b", grid_color="b")
    ax.raxis.set_tick_params(tick2On=true, colors="r", grid_color="r")

    # Color labels
    ax.taxis.label.set_color("darkgoldenrod")
    ax.laxis.label.set_color("b")
    ax.raxis.label.set_color("r")

    #CREATE FIRST THE SUBFOLDER "Deterministic" IN THE "Plots" FOLDER
    plt.savefig(plotsdir("Deterministic",namefile[1:end-3]*String("pdf")))
