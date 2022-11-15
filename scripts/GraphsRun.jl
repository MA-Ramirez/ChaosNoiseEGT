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


#Obtain arguments and define them as global variables
num_arguments = size(ARGS)[1]
APPROACH = ARGS[1]
B = ARGS[2]
if num_arguments == 3
    N = ARGS[3]
end

#The approach can only be "Deterministic" or "Stochastic"
if APPROACH != "Deterministic" && APPROACH != "Stochastic"
    throw(ArgumentError("The approach can only be Deterministic or Stochastic. It is case sensitive. Check spelling."))
end

#From arguments define the name of the file to read
if APPROACH == "Deterministic"
    NAMEFILE = "Det_B="*B*".txt"
elseif APPROACH == "Stochastic"
    NAMEFILE = "Sto_B="*B*"_N="*N*".txt"
end

"""
    getdata(namefile) → x1,x,2,x3,x4
`approach`: defines if Deterministic or Stochastic will be analysed.
This parameter is used also for folder organisation purposes
Imports data from files and returns each variables' info in a vector
"""
function getdata(approach,namefile)
    if approach == "Deterministic"
        data = readdlm(datadir("Deterministic", namefile))
    elseif approach == "Stochastic"
        data = readdlm(datadir("Stochastic", namefile))
    end

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
    ternary_plot(approach,namefile,x1,x2,x3) → pdf file
`approach`: defines if Deterministic or Stochastic will be analysed.
This parameter is used also for folder organisation purposes
`namefile`: name of the file with the data
`x1`,`x2`,`x3`: vectors with variables data

Generates simplex using mpltern package.
Mpltern is a Python plotting library based on Matplotlib specifically designed
for ternary plots.
A similar library with the quality of mpltern is not yet available in Julia.
"""
function ternary_plot(approach,namefile,x1,x2,x3)
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

    #Save settings
    if approach == "Deterministic"
        #CREATE FIRST THE SUBFOLDER "Deterministic/TernaryDet" IN THE "Plots" FOLDER
        plt.savefig(plotsdir("Deterministic/TernaryDet",namefile[1:end-3]*String("pdf")))
    elseif approach == "Stochastic"
        #CREATE FIRST THE SUBFOLDER "Stochastic/TernarySto" IN THE "Plots" FOLDER
        plt.savefig(plotsdir("Stochastic/TernarySto",namefile[1:end-3]*String("pdf")))
    end
    plt.clf()
end

"""
    timeseries(approach,namefile,x1,x2,x3,x4) → pdf file
`approach`: defines if Deterministic or Stochastic will be analysed.
This parameter is used also for folder organisation purposes
`namefile`: name of the file with the data
`x1`,`x2`,`x3`,`x4`: vectors with variables data

Generates timeseries graph with all the variables.
"""
function timeseries(approach,namefile,x1,x2,x3,x4)

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

    #Save settings
    if approach == "Deterministic"
        #CREATE FIRST THE SUBFOLDER "Deterministic/TernaryDet" IN THE "Plots" FOLDER
        plt.savefig(plotsdir("Deterministic/TimeseriesDet",namefile[1:end-3]*String("_TS.pdf")))
    elseif approach == "Stochastic"
        #CREATE FIRST THE SUBFOLDER "Stochastic/TernarySto" IN THE "Plots" FOLDER
        plt.savefig(plotsdir("Stochastic/TimeseriesSto",namefile[1:end-3]*String("_TS.pdf")))
    end
    plt.clf()
end

"""
    timeseries_zoom(approach,namefile,x1,x2,x3,x4) → pdf file
`approach`: defines if Deterministic or Stochastic will be analysed.
This parameter is used also for folder organisation purposes
`namefile`: name of the file with the data
`x1`,`x2`,`x3`,`x4`: vectors with variables data

Generates timeseries graph with all the variables.
It zooms over the first 100 time steps.
"""
function timeseries_zoom(approach,namefile,x1,x2,x3,x4)

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

    #Save settings
    if approach == "Deterministic"
        #CREATE FIRST THE SUBFOLDER "Deterministic/TernaryDet" IN THE "Plots" FOLDER
        plt.savefig(plotsdir("Deterministic/TimeseriesDet",namefile[1:end-3]*String("_TS_Zoom.pdf")))
    elseif approach == "Stochastic"
        #CREATE FIRST THE SUBFOLDER "Stochastic/TernarySto" IN THE "Plots" FOLDER
        plt.savefig(plotsdir("Stochastic/TimeseriesSto",namefile[1:end-3]*String("_TS_Zoom.pdf")))
    end
    plt.clf()
end

################################################################################
#                                  Graph plots                                 #
################################################################################


X1,X2,X3,X4 = getdata(APPROACH,NAMEFILE)
ternary_plot(APPROACH,NAMEFILE,X1,X2,X3)
timeseries(APPROACH,NAMEFILE,X1,X2,X3,X4)
timeseries_zoom(APPROACH,NAMEFILE,X1,X2,X3,X4)
