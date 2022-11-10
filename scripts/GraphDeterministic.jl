"""
Script used to graph the solution of the ODEs that is saved in the data folder.
A ternary plot and a timeseries plot (general and with zoom) is generated.
"""

using DrWatson
@quickactivate "ChaosNoiseEGT"

using DelimitedFiles
using PyCall
using LaTeXStrings

@pyimport matplotlib.pyplot as plt
@pyimport mpltern

################################################################################
#                                   Import data                                #
################################################################################

#Dictionary of names of all the files in data/Deterministic
datafiles_names = readdir(datadir("Deterministic"))

"""
    getdata(namefile) → x1,x,2,x3,x4
Imports data from files and returns each variables' info in a vector
"""
function getdata(namefile)
    data = readdlm(datadir("Deterministic", namefile))

    #Each variable of the system
    x1 = data[:,1]
    x2 = data[:,2]
    x3 = data[:,3]
    x4 = data[:,4]

    return x1,x2,x3,x4
end

################################################################################
#                         Graph generation functions                           #
################################################################################

"""
    ternary_plot(namefile,x1,x2,x3) → pdf file
`namefile`: name of the file with the data
`x1`,`x2`,`x3`: vectors with variables data

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

    plt.tight_layout()
    #CREATE FIRST THE SUBFOLDER "Deterministic/TernaryDet" IN THE "Plots" FOLDER
    plt.savefig(plotsdir("Deterministic/TernaryDet",namefile[1:end-3]*String("pdf")))
    plt.clf()
end

"""
    timeseries(namefile,x1,x2,x3,x4) → pdf file
`namefile`: name of the file with the data
`x1`,`x2`,`x3`,`x4`: vectors with variables data

Generates timeseries graph with all the variables.
"""
function timeseries(namefile,x1,x2,x3,x4)

    #Time vector
    t = Vector(1:length(x1))

    #Original time interval
    plt.plot(t,x1, c="darkgoldenrod", label = L"x_1")
    plt.plot(t,x2, c="b", label = L"x_2")
    plt.plot(t,x3, c="r", label = L"x_3")
    plt.plot(t,x4, c="purple", label = L"x_4")
    plt.title(L"x_k"*"vs t")
    plt.xlabel("Time steps (t)")
    plt.ylabel(L"x_k")
    plt.legend(loc="center left", bbox_to_anchor=(1, 0.5))
    plt.tight_layout()
    #CREATE FIRST THE SUBFOLDER "Deterministic/TimeseriesDet" IN THE "Plots" FOLDER
    plt.savefig(plotsdir("Deterministic/TimeseriesDet",namefile[1:end-4]*String("_TS.pdf")))
    plt.clf()
end

"""
    timeseries_zoom(namefile,x1,x2,x3,x4) → pdf file
`namefile`: name of the file with the data
`x1`,`x2`,`x3`,`x4`: vectors with variables data

Generates timeseries graph with all the variables.
It zooms over the first 100 time steps.
"""
function timeseries_zoom(namefile,x1,x2,x3,x4)

    #Time vector
    t = Vector(1:length(x1))

    #Original time interval
    plt.plot(t,x1, c="darkgoldenrod", label = L"x_1")
    plt.plot(t,x2, c="b", label = L"x_2")
    plt.plot(t,x3, c="r", label = L"x_3")
    plt.plot(t,x4, c="purple", label = L"x_4")
    plt.title(L"x_k"*"vs t")
    plt.xlabel("Time steps (t)")
    plt.ylabel(L"x_k")
    plt.legend(loc="center left", bbox_to_anchor=(1, 0.5))
    plt.xlim((0,100))
    plt.tight_layout()
    #CREATE FIRST THE SUBFOLDER "Deterministic/TimeseriesDet" IN THE "Plots" FOLDER
    plt.savefig(plotsdir("Deterministic/TimeseriesDet",namefile[1:end-4]*String("_TS_Zoom.pdf")))
    plt.clf()
end

################################################################################
#                Graph plots for all deterministic trajectories                #
################################################################################

for i in datafiles_names
    X1,X2,X3,X4 = getdata(i)
    ternary_plot(i,X1,X2,X3)
    timeseries(i,X1,X2,X3,X4)
    timeseries_zoom(i,X1,X2,X3,X4)
end
