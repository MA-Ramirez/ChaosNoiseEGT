"""
Script used to graph the quantifiers data of the deterministic trajectories
"""

using DrWatson
@quickactivate "ChaosNoiseEGT"

using CSV, DataFrames, LaTeXStrings, DelimitedFiles, PyPlot

################################################################################
#                                      Get data                                #
################################################################################

"""
    get_data(measure) → DataFrame
Sorts the data by beta value
Returns DataFrame with the quantifier data specified by `measure`
"""
function get_data(measure)
    data = CSV.read(datadir("Quantifiers/QuantifiersDet", "Det_"*measure*".csv"), DataFrame,header=false)
    data = sort!(data, [:Column1])
    println(measure)
    println(data)
    return data
end

################################################################################
#                                  Graph functions                             #
################################################################################

"""
    graph_det_cluster_run() → pdf file
Generates pdf file for all measures
For each N value, it graphs the corresponding quantifier value in a unified plot (Quantifier vs B)
"""
function graph_det_cluster_run()

    #General Aesthetics
    labels_1 = [L"\lambda_1", L"\lambda_2", L"\lambda_3", L"\lambda_4"]
    labels_2 = [L"x_1", L"x_2", L"x_3", L"x_4"]
    markers = ["o", "^", "s", "d"]
    
    #Define subplots
    fig, axs = subplots(5, sharex=true, figsize= (6,10))

    #Common x axis
    xscale("log")
    xlabel("Selection intensity coefficient ("*L"\beta"*")")

    #---------------LYAPUNOV SPECTRUM--------------
    Data = get_data("LE")
    B_values = Data[:,1]
    variable_values = Data[:,2]

    #Maximum Lyapunov exponents
    cm = get_cmap(:viridis)
    axs[1].plot(B_values, variable_values, marker="o", markersize=3, c=cm(0/4))
    axs[1].locator_params(axis="y", nbins=3)
    axs[1].set_ylabel("Max. Lyapunov exponent")
    #axs[1].legend(loc=2)
    #axs[1].set_title("Quantifiers deterministic system")

    #Lyapunov spectrum
    for i in 2:5
        axs[2].plot(B_values, Data[:,i], marker=markers[i-1], markersize=3, c=cm((i-2)/4))
    end
    axs[2].set_ylabel("Lyapunov exponents")
    axs[2].set_ylim((-10,5))
    #axs[2].legend(loc=3, fontsize="small")
    #axs[2].set_yscale("symlog")

    #---------------LEMPELZ-ZIV--------------
    Data = get_data("LZ")
    B_values = Data[:,1]
    variable_values = Data[:,end]
    axs[3].plot(B_values, variable_values, marker="o", c="yellowgreen", markersize=3 )
    axs[3].locator_params(axis="y", nbins=3)
    axs[3].set_ylabel("Lempel-Ziv complexity")
    axs[3].set_ylim((630,720))

    #---------------FRACTAL DIMENSION--------------
    Data = get_data("FD")
    B_values = Data[:,1]
    variable_values = Data[:,end]
    axs[4].plot(B_values, variable_values, marker="o", c="turquoise", markersize=3 )
    axs[4].locator_params(axis="y", nbins=3)
    axs[4].set_ylabel("Fractal dimension")
    axs[4].set_ylim((0.9,2.1))

    #---------------STANDARD DEVIATION--------------
    Data = get_data("Std")
    B_values = Data[:,1]
    variable_values = Data[:,end]
    axs[5].plot(B_values, variable_values, marker="o", c="deepskyblue", markersize=3 )
    axs[5].locator_params(axis="y", nbins=3)
    axs[5].set_ylabel("Standard deviation")
    axs[5].set_ylim((0,0.15))

    #Output
    tight_layout()
    savefig(plotsdir("GeneralQuantifiers/","General_Det_Unified.pdf"))
    clf()
end

######################################
#               RUN IT               #
######################################

graph_det_cluster_run()
