"""
Script used to graph the quantifiers data of the deterministic trajectories
"""

using DrWatson
@quickactivate "ChaosNoiseEGT"

using LaTeXStrings, PyPlot

#Data = load(datadir("gd/deterministic_system.jld2"))
#Data = load(datadir("gd/deterministic_system_LEnotscaled.jld2"))
Data = load(datadir("gd/deterministic_system_testPE.jld2"))

#display(Data["βs"])

################################################################################
#                                  Graph functions                             #
################################################################################

"""
    graph_det_cluster_run() → pdf file
Generates pdf file for all measures
For each N value, it graphs the corresponding quantifier value in a unified plot (Quantifier vs B)
"""
function graph_det_cluster_run(βs, λs, fractal_dim_corr, lempel_ziv, σs)
    
    #Define subplots
    fig, axs = subplots(4, sharex=true, figsize= (10,10))

    #Common x axis
    xscale("log")
    xlabel("Selection intensity coefficient ("*L"\beta"*")")

    #---------------LYAPUNOV SPECTRUM--------------

    #Maximum Lyapunov exponents
    cm = get_cmap(:viridis)
    axs[1].plot(βs, getindex.(λs, 1), marker="o", markersize=3, c=cm(0/4))
    axs[1].locator_params(axis="y", nbins=3)
    axs[1].set_ylabel("Max. Lyapunov exponent (scaled)",fontsize="x-small")
    #axs[1].legend(loc=2)
    #axs[1].set_title("Quantifiers deterministic system")

    #---------------FRACTAL DIMENSION--------------
    axs[2].plot(βs, fractal_dim_corr, marker="o", c="turquoise", markersize=3 )
    axs[2].locator_params(axis="y", nbins=3)
    axs[2].set_ylabel("Fractal dimension")
    axs[2].set_ylim((0.9,2.1))

    #---------------LEMPEL-ZIV--------------
    axs[3].plot(βs, lempel_ziv, marker="o", c="yellowgreen", markersize=3 )
    axs[3].locator_params(axis="y", nbins=3)
    axs[3].set_ylabel("Lempel-Ziv complexity")
    axs[3].set_ylim((0,0.025))

    #---------------STANDARD DEVIATION--------------
    axs[4].plot(βs, σs, marker="o", c="deepskyblue", markersize=3 )
    axs[4].locator_params(axis="y", nbins=3)
    axs[4].set_ylabel("Standard deviation")
    axs[4].set_ylim((0,0.13))

    #Output
    tight_layout()
    savefig(plotsdir("GeneralQuantifiers/","General_Det_Unified_NEW.pdf"))
    clf()
end

function graph_det_cluster_run(βs, λs)

     #Define subplots
    fig, axs = subplots(2, sharex=true, figsize= (10,5))

    #Common x axis
    xscale("log")
    xlabel("Selection intensity coefficient ("*L"\beta"*")")

     #Maximum Lyapunov exponents
    cm = get_cmap(:viridis)
    axs[1].plot(βs, getindex.(λs, 1), marker="o", markersize=3, c=cm(0/4))
    axs[1].locator_params(axis="y", nbins=3)
    axs[1].set_ylabel("Max. Lyapunov exponent")
    #axs[1].legend(loc=2)
    #axs[1].set_title("Quantifiers deterministic system")

    #Lyapunov spectrum
    for i in 2:4
        axs[2].plot(βs, getindex.(λs, i),  marker="o", markersize=3, c=cm((i-1)/4))
    end
    axs[2].set_ylabel("Lyapunov exponents")
    axs[2].locator_params(axis="y", nbins=3)
    axs[2].set_ylim((-10,5))
    #axs[2].legend(loc=3, fontsize="small")
    #axs[2].set_yscale("symlog")

     #Output
    tight_layout()
    savefig(plotsdir("GeneralQuantifiers/","LE_spectrum.pdf"))
    clf()
end

#Double plot, double y-axis side by side
function graph_det_cluster_run2(βs, σs,permutation_entropy)

     #Define subplots
    fig, ax1 = subplots()

    #Common x axis
    xscale("log")
    xlabel("Selection intensity coefficient ("*L"\beta"*")")

     #---------------STANDARD DEVIATION--------------
    color = "deepskyblue"
    ax1.set_ylabel("Standard deviation", color=color)
    ax1.plot(βs, σs, marker="o", c="deepskyblue", markersize=3 )
    ax1.tick_params(axis="y", labelcolor=color)
    ax1.set_ylim((0,0.13))

    ax2 = ax1.twinx()

    #---------------PERMUTATION ENTROPY--------------
    color = "salmon"
    ax2.set_ylabel("Permutation entropy", color=color)  # we already handled the x-label with ax1
    ax2.plot(βs, permutation_entropy, marker="o", c="orange", markersize=3 )
    ax2.tick_params(axis="y", labelcolor=color)

     #Output
    tight_layout()
    savefig(plotsdir("GeneralQuantifiers/","test_PE_m4.pdf"))
    clf()
end

######################################
#               RUN IT               #
######################################

#graph_det_cluster_run(Data["βs"], Data["λs"], Data["fractal_dim_corr"], Data["lempel_ziv"], Data["σs"])
#graph_det_cluster_run(Data["βs"], Data["λs"])
graph_det_cluster_run2(Data["βs"], Data["σs"],Data["lempel_ziv"])