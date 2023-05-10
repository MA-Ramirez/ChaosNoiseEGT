"""
Functions used to graph the solution of the ODEs that is saved in the data folder.
A ternary plot and a timeseries plot (general and with zoom) is generated.
"""

using DrWatson

using DelimitedFiles
using PyCall
using LaTeXStrings

@pyimport matplotlib.pyplot as plt
@pyimport mpltern

################################################################################
#                                   Import data                                #
################################################################################

"""
    getdata(approach,namefile) → x1,x,2,x3,x4
`approach`: defines if Deterministic or Stochastic will be analysed.
This parameter is used also for folder organisation purposes
Imports data from files and returns each variables' info in a vector
"""
function getdata(approach::String,namefile)
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

##################################################
#                    Ternary plot                #
##################################################

"""
    ternary_plot(approach,namefile,x1,x2,x3) → plot
`x1`,`x2`,`x3`: vectors with variables data

Generates simplex using mpltern package.
Mpltern is a Python plotting library based on Matplotlib specifically designed
for ternary plots.
A similar library with the quality of mpltern is not yet available in Julia.
"""
function ternary_plot(x1,x2,x3)
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
end

#------ Save data ------

"""
    ternary_plot_save(approach,namefile,x1,x2,x3) → pdf file

`approach`: defines if Deterministic or Stochastic will be analysed.
This parameter is used also for folder organisation purposes
`namefile`: name of the file with the data
`x1`,`x2`,`x3`: vectors with variables data

It saves the generated ternary plot as a pdf file.
"""
function ternary_plot_save(approach::String,namefile,x1,x2,x3)

    ternary_plot(x1,x2,x3)

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

##################################################
#                    Time series                 #
##################################################

"""
    timeseries(x1,x2,x3,x4) → plot
`x1`,`x2`,`x3`,`x4`: vectors with variables data
`xlim`: determines the x-axis limit

Generates timeseries plot with all the variables.
"""
function timeseries(x1,x2,x3,x4; xmin::Int64 = 0, xmax::Int64 = length(x1))

    #Time vector
    t = Vector(1:length(x1))

    #Plot
    plt.plot(t,x1, c="darkgoldenrod", label = L"x_1")
    plt.plot(t,x2, c="b", label = L"x_2")
    plt.plot(t,x3, c="r", label = L"x_3")
    plt.plot(t,x4, c="deepskyblue", label = L"x_4")
    #Aesthetics
    plt.xlabel("Time steps (t)")
    plt.ylabel(L"x_k")
    plt.legend(loc="center left", bbox_to_anchor=(1, 0.5))
    #keyword argument modifies
    plt.xlim((xmin,xmax))

    plt.tight_layout()
end

#------ Save data ------

"""
    timeseries_save(approach::String,namefile,x1,x2,x3,x4) → pdf file
`approach`: defines if Deterministic or Stochastic will be analysed.
This parameter is used also for folder organisation purposes
`namefile`: name of the file with the data
`x1`,`x2`,`x3`,`x4`: vectors with variables data

Generates timeseries plot with all the variables.
"""
function timeseries_save(approach::String,namefile,x1,x2,x3,x4)
    timeseries(x1,x2,x3,x4)

     #Save settings
     if approach == "Deterministic"
        #CREATE FIRST THE SUBFOLDER "Deterministic/TernaryDet" IN THE "Plots" FOLDER
        plt.savefig(plotsdir("Deterministic/TimeseriesDet",namefile[1:end-4]*String("_TS.pdf")))
    elseif approach == "Stochastic"
        #CREATE FIRST THE SUBFOLDER "Stochastic/TernarySto" IN THE "Plots" FOLDER
        plt.savefig(plotsdir("Stochastic/TimeseriesSto",namefile[1:end-4]*String("_TS.pdf")))
    end
    plt.clf()
end

##################################################
#                  Time series zoom              #
##################################################

"""
    timeseries_zoom_save(approach::String,namefile,x1,x2,x3,x4; kwargs...) → pdf file
`approach`: defines if Deterministic or Stochastic will be analysed.
This parameter is used also for folder organisation purposes
`namefile`: name of the file with the data
`x1`,`x2`,`x3`,`x4`: vectors with variables data

Generates timeseries plot with all the variables.
It zooms over the first 100 time steps.
"""
function timeseries_zoom_save(approach::String,namefile,x1,x2,x3,x4; xmin = 0, xmax=100)
    timeseries(x1,x2,x3,x4;xmin, xmax)

     #Save settings
     if approach == "Deterministic"
        #CREATE FIRST THE SUBFOLDER "Deterministic/TernaryDet" IN THE "Plots" FOLDER
        plt.savefig(plotsdir("Deterministic/TimeseriesDet",namefile[1:end-4]*String("_TS_Zoom.pdf")))
    elseif approach == "Stochastic"
        #CREATE FIRST THE SUBFOLDER "Stochastic/TernarySto" IN THE "Plots" FOLDER
        plt.savefig(plotsdir("Stochastic/TimeseriesSto",namefile[1:end-4]*String("_TS_Zoom.pdf")))
    end
    plt.clf()
end