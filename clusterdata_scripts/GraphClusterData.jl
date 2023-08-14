"""
Script used to graph the quantifiers data of many stochastic runs
"""

using DrWatson
@quickactivate "ChaosNoiseEGT"

using CSV
using DataFrames
using PyCall
using LaTeXStrings
using DelimitedFiles

@pyimport matplotlib.pyplot as plt
@pyimport matplotlib.cm as cm

################################################################################
#                                      Get data                                #
################################################################################

"""
    get_avg_data(measure) → DataFrame
Returns DataFrame with the mean data of the quantifier specified by `measure`
"""
function get_avg_data(measure)
    data = CSV.read(datadir("Quantifiers/ClusterQuantifiers", "Sto_Avg_"*measure*".csv"), DataFrame,header=false)
    return data
end

"""
    get_errbar_data(measure) → DataFrame
Returns DataFrame with the error bar data of the quantifier specified by `measure`
"""
function get_errbar_data(measure)
    data = CSV.read(datadir("Quantifiers/ClusterQuantifiers", "Sto_ErrBar_"*measure*".csv"), DataFrame,header=false)
    return data
end

"""
    get_deterministic_data(measure) → DataFrame
Returns DataFrame with the deterministic data of the quantifier specified by `measure`
"""
function get_deterministic_data(measure)
    data = CSV.read(datadir("Quantifiers/QuantifiersDet", "Det_"*measure*".csv"), DataFrame,header=false)
    return data
end

################################################################################
#                                    Process data                              #
################################################################################

"""
    find_unique_values(array) → Vector{Float64}
Returns unique values of an array in another array
"""
function find_unique_values(array)
    arr = copy(array)
    array_unique_vals = unique!(arr)
    return array_unique_vals
end

################################################################################
#                                  Graph functions                             #
################################################################################

"""
    get_colors(betas) → Vector{NTuple{4, Float64}}
Given n number of different unique beta values in data, returns an array of n colors
in (red,blue,green,alpha) format using the color map "inferno"
"""
function get_colors(betas)
    n = size(betas)[1]
    cmap = cm.get_cmap("inferno")
    colors = []
    for i in 0:(1/n):1
        push!(colors,cmap(i))
    end
    return colors
end

"""
    graph_cluster_run(measure) → pdf file
Generates pdf file for specified `measure`
For each unique BN value in the stochatic simulation runs, it graphs the
average of the quantifier for all the runs, along with the errorbar
It also graphs the deterministic quantifier for each B value
"""
function graph_cluster_run(measure)

    #Get and define data avg runs
    Data = get_avg_data(measure)
    BN_values = Data[:,1]
    N_values = Data[:,2]
    variable_values = Data[:,end]

    #Get and define data errobars
    Data_errbar = get_errbar_data(measure)
    err_values = Data_errbar[:,end]

    #Get and define data deterministic
    Det_data = get_deterministic_data(measure)
    det_beta_values = Det_data[:,1]
    det_vals = Det_data[:,end]

    #Get unique values of data run
    BN = sort(find_unique_values(Data[:,1]))

    #Get colors for each plot
    colors = get_colors(BN)

    #--------PLOT STOCHASTIC------
    #Label BN
    plt.plot([],[],color="white", label=L"\beta N")
    #Generate plots for each unique BN
    sizeB = size(BN)[1]
    for i in 1:sizeB
        BNs = reverse(BN)
        indexarray = findall( b -> b == BNs[i], BN_values)

        plt.scatter(N_values[indexarray],variable_values[indexarray],label=string(BNs[i]),color=colors[i])
        plt.plot(N_values[indexarray],variable_values[indexarray],color=colors[i])
        plt.errorbar(N_values[indexarray],variable_values[indexarray],yerr=err_values[indexarray],color=colors[i])
        plt.fill_between(N_values[indexarray],variable_values[indexarray]-err_values[indexarray],variable_values[indexarray]+err_values[indexarray],color=colors[i],alpha=0.1)
    end

    #--------PLOT DETERMINISTIC------
    #Label B
    plt.plot([],[],color="white", label=L"\beta")
    #Generate plots for each unique beta
    for i in 1:sizeB-1
        indexarrayDET = findall( b -> b == reverse(det_beta_values)[i], det_beta_values)
        plt.scatter(10^7,det_vals[indexarrayDET],label=string(reverse(det_beta_values)[i]),color=colors[i],marker="^")
    end 

    #General Aesthetics
    plt.xscale("log")
    plt.xlabel("Population size (N)")
    plt.legend(loc="center left", bbox_to_anchor=(1, 0.5), ncol=2)
    plt.xticks([10^2,10^3,10^4,10^5,10^7],[L"10^2",L"10^3",L"10^4",L"10^5","Deterministic"])

    #ylabel
    if measure == "FD"
        plt.ylabel("Fractal dimension ("*L"\Delta^{C}"*")")
    elseif measure == "FixT"
        plt.ylabel("Fixation time ("*L"\tau"*")")
    elseif measure == "LZ"
        plt.ylabel("Lempel-Ziv complexity ("*L"C_{LZ}"*")")
    elseif measure == "Std"
        plt.ylabel("Standard deviation ("*L"\sigma"*")")
    elseif measure == "PE"
        plt.ylabel("Permutation entropy ("*L"PE"*")")
    end

    #Output
    plt.tight_layout()
    plt.savefig(plotsdir("GeneralQuantifiers/","General_"*measure*".pdf"))
    plt.clf()
end

################################################################################

Measures = ["FD","Std","PE"]

for i in Measures
    graph_cluster_run(i)
end
