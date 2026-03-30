"""
Script used to graph the quantifiers data of the deterministic trajectories
"""

using DrWatson
@quickactivate "ChaosNoiseEGT"

using LaTeXStrings, PyPlot, DataFrames, DelimitedFiles, CSV
using Statistics: std, mean


#data = DataFrame(readdlm(datadir("gd/struct_stability.csv",",", Float64)), ["B"] )
#data = CSV.read(datadir("gd/struct_stability.csv"), DataFrame,header=["βs", "λ1", "fractal_dim_corr", "σ", "lempel_ziv"])
#data = CSV.read(datadir("gd/struct_stability_005.csv"), DataFrame,header=["βs", "λ1", "fractal_dim_corr", "σ", "lempel_ziv"])
#data = CSV.read(datadir("gd/struct_stability_001_LE.csv"), DataFrame,header=["βs", "λ1"])
data = CSV.read(datadir("gd/struct_stability_005_LE.csv"), DataFrame,header=["βs", "λ1"])
#data = CSV.read(datadir("gd/struct_stability_01_LE.csv"), DataFrame,header=["βs", "λ1"])
data_ori = CSV.read(datadir("gd/struct_stability_ori.csv"), DataFrame,header=["βs", "λ1", "fractal_dim_corr", "σ", "lempel_ziv"])

#display(data)
#display(filter(:βs => ==(0.01), data))
#display(data[!,:βs])

"""
B_list = [0.01,0.1,1,10,100]
lambda_mean = fill(0.0, length(B_list))
lambda_std = fill(0.0, length(B_list))
fracdim_mean = fill(0.0, length(B_list))
fracdim_std = fill(0.0, length(B_list))
σ_mean = fill(0.0, length(B_list))
σ_std = fill(0.0, length(B_list))
lempel_mean = fill(0.0, length(B_list))
lempel_std = fill(0.0, length(B_list))
"""

function calculate_mean_std()
    gdf = groupby(data, :βs)

    println(combine(gdf, :λ1 => mean,:λ1 => std))
    println(sort!(combine(gdf, :λ1 => mean,:λ1 => std)))
    #println(combine(gdf, :fractal_dim_corr => mean, :fractal_dim_corr => std))
    #println(combine(gdf, :σ => mean, :σ => std))
    #println(combine(gdf, :lempel_ziv => mean, :lempel_ziv => std))
end

gdf = groupby(data, :βs)

function graph_struct_stability()
    
    #Define subplots
    fig, axs = subplots(4, sharex=true, figsize= (10,10))

    #Common x axis
    xscale("log")
    xlabel("Selection intensity coefficient ("*L"\beta"*")")

    #---------------LYAPUNOV SPECTRUM--------------

    LE = sort!(combine(gdf, :λ1 => mean,:λ1 => std))
    #Maximum Lyapunov exponents
    cm = get_cmap(:viridis)
    axs[1].plot(data_ori[!,:βs], data_ori[!,:λ1], marker="o", markersize=3, c="black")
    axs[1].plot(LE[!,:βs], LE[!,:λ1_mean], marker="o", markersize=3, c=cm(0/4))
    axs[1].errorbar(LE[!,:βs],LE[!,:λ1_mean],yerr=LE[!,:λ1_std],color=cm(0/4))
    axs[1].fill_between(LE[!,:βs],LE[!,:λ1_mean]-LE[!,:λ1_std],LE[!,:λ1_mean]+LE[!,:λ1_std],color=cm(0/4),alpha=0.1)
    #axs[1].scatter(βs, λ1, marker="o", s=3, c="indigo")
    axs[1].locator_params(axis="y", nbins=3)
    axs[1].set_ylabel("Max. Lyapunov exponent (scaled)",fontsize="x-small")
    axs[1].set_ylim((0,0.0045))
    #axs[1].legend(loc=2)
    #axs[1].set_title("Quantifiers deterministic system")

    #---------------FRACTAL DIMENSION--------------
    FD = sort!(combine(gdf, :fractal_dim_corr => mean, :fractal_dim_corr => std))

    axs[2].plot(data_ori[!,:βs], data_ori[!,:fractal_dim_corr], marker="o", markersize=3, c="black")
    axs[2].plot(FD[!,:βs], FD[!,:fractal_dim_corr_mean], marker="o", c="turquoise", markersize=3 )
    axs[2].errorbar(FD[!,:βs], FD[!,:fractal_dim_corr_mean],yerr=FD[!,:fractal_dim_corr_std],color="turquoise")
    axs[2].fill_between(FD[!,:βs], FD[!,:fractal_dim_corr_mean]-FD[!,:fractal_dim_corr_std],FD[!,:fractal_dim_corr_mean]+FD[!,:fractal_dim_corr_std],color="turquoise",alpha=0.1)
    axs[2].locator_params(axis="y", nbins=3)
    axs[2].set_ylabel("Fractal dimension")
    axs[2].set_ylim((0.9,2.1))

    #---------------LEMPEL-ZIV--------------
    LZ = sort!(combine(gdf, :lempel_ziv => mean, :lempel_ziv => std))

    axs[3].plot(data_ori[!,:βs], data_ori[!,:lempel_ziv], marker="o", markersize=3, c="black")
    axs[3].plot(LZ[!,:βs], LZ[!,:lempel_ziv_mean], marker="o", c="yellowgreen", markersize=3 )
    axs[3].errorbar(LZ[!,:βs], LZ[!,:lempel_ziv_mean],yerr= LZ[!,:lempel_ziv_std],color="yellowgreen")
    axs[3].fill_between(LZ[!,:βs], LZ[!,:lempel_ziv_mean]-LZ[!,:lempel_ziv_std],LZ[!,:lempel_ziv_mean]+LZ[!,:lempel_ziv_std],color="yellowgreen",alpha=0.1)
    axs[3].locator_params(axis="y", nbins=3)
    axs[3].set_ylabel("Lempel-Ziv complexity")
    axs[3].set_ylim((0,0.025))

    #---------------STANDARD DEVIATION--------------
    SD = sort!(combine(gdf, :σ => mean, :σ => std))

    axs[4].plot(data_ori[!,:βs], data_ori[!,:σ], marker="o", markersize=3, c="black")
    axs[4].plot(SD[!,:βs], SD[!,:σ_mean], marker="o", c="deepskyblue", markersize=3 )
    axs[4].errorbar(SD[!,:βs], SD[!,:σ_mean],yerr=SD[!,:σ_std],color="deepskyblue")
    axs[4].fill_between(SD[!,:βs], SD[!,:σ_mean]-SD[!,:σ_std],SD[!,:σ_mean]+SD[!,:σ_std],color="deepskyblue",alpha=0.1)
    axs[4].locator_params(axis="y", nbins=3)
    axs[4].set_ylabel("Standard deviation")
    axs[4].set_ylim((0,0.13))

    #Output
    tight_layout()
    #savefig(plotsdir("GeneralQuantifiers/","Structural_Stability_GO.pdf"))
    savefig(plotsdir("GeneralQuantifiers/","Structural_Stability_NARROW.pdf"))
    clf()
end


"""
    graph_det_cluster_run() → pdf file
Generates pdf file for all measures
For each N value, it graphs the corresponding quantifier value in a unified plot (Quantifier vs B)
"""
function graph_det_cluster_run(βs, λ1, fractal_dim_corr, lempel_ziv, σ)
    
    #Define subplots
    fig, axs = subplots(4, sharex=true, figsize= (10,10))

    #Common x axis
    xscale("log")
    xlabel("Selection intensity coefficient ("*L"\beta"*")")

    #---------------LYAPUNOV SPECTRUM--------------

    #Maximum Lyapunov exponents
    #cm = get_cmap(:viridis)
    #axs[1].scatter(βs, λ1, marker="o", markersize=3, c=cm(0/4))
    axs[1].scatter(βs, λ1, marker="o", s=3, c="indigo")
    axs[1].locator_params(axis="y", nbins=3)
    axs[1].set_ylabel("Max. Lyapunov exponent (scaled)",fontsize="x-small")
    #axs[1].legend(loc=2)
    #axs[1].set_title("Quantifiers deterministic system")

    #---------------FRACTAL DIMENSION--------------
    axs[2].scatter(βs, fractal_dim_corr, marker="o", c="turquoise", s=3 )
    axs[2].locator_params(axis="y", nbins=3)
    axs[2].set_ylabel("Fractal dimension")
    axs[2].set_ylim((0.9,2.1))

    #---------------LEMPEL-ZIV--------------
    axs[3].scatter(βs, lempel_ziv, marker="o", c="yellowgreen", s=3 )
    axs[3].locator_params(axis="y", nbins=3)
    axs[3].set_ylabel("Lempel-Ziv complexity")
    axs[3].set_ylim((0,0.025))

    #---------------STANDARD DEVIATION--------------
    axs[4].scatter(βs, σ, marker="o", c="deepskyblue", s=3 )
    axs[4].locator_params(axis="y", nbins=3)
    axs[4].set_ylabel("Standard deviation")
    axs[4].set_ylim((0,0.13))

    #Output
    tight_layout()
    savefig(plotsdir("GeneralQuantifiers/","Structural_Stability_NARROW_SCATTER.pdf"))
    clf()
end

function graph_LE(βs, λ1)
    
    #Define subplots
    #fig, axs = subplots(4, sharex=true, figsize= (10,10))

    #Common x axis
    xscale("log")
    xlabel("Selection intensity coefficient ("*L"\beta"*")")

    #---------------LYAPUNOV SPECTRUM--------------

    #Maximum Lyapunov exponents
    #cm = get_cmap(:viridis)
    #axs[1].scatter(βs, λ1, marker="o", markersize=3, c=cm(0/4))
    plot(data_ori[!,:βs], data_ori[!,:λ1], marker="o", markersize=3, c="indigo", label= "Original payoffs")

    scatter(βs, λ1, marker="o", s=3, c="mediumpurple",alpha=0.3, label="Perturbations")
    locator_params(axis="y", nbins=3)
    ylabel("Max. Lyapunov exponent (scaled)",fontsize="x-small")
    ylim((0,0.009))
    #axs[1].legend(loc=2)
    #axs[1].set_title("Quantifiers deterministic system")

    legend(loc=1, fontsize="x-small")

    #Output
    tight_layout()
    savefig(plotsdir("GeneralQuantifiers/","Structural_Stability_LE_01_Zoom.pdf"))
    clf()
end


function count_positive_chaos(λ1)
    posi = 0
    tot = length(λ1)
    for i in λ1
        if i > 0.0001
            posi += 1
        end
    end
    println("Total")
    println(tot)
    println("Positive")
    println(posi)
    println((posi/tot)*100)
end
#graph_det_cluster_run(data[!,:βs], data[!,:λ1], data[!,:fractal_dim_corr], data[!,:lempel_ziv], data[!,:σ])
#calculate_mean_std()
#graph_struct_stability()
#graph_LE(data[!,:βs], data[!,:λ1])
count_positive_chaos(data[!,:λ1])