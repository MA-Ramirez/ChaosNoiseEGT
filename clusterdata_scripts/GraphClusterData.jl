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
#                                    Aesthetics                                #
################################################################################

"""
    get_colors(betas) → Vector{NTuple{4, Float64}}
Given n number of unique values in data, returns an array of n colors
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

################################################################################
#                                  Graph functions                             #
################################################################################

"""
    graph_individual(measure, axs, loc) → pdf file
Plots graph for the specified `measure`
    `axs`: axis for subplots
    `loc`: location in the axis
For each unique N value in the stochatic simulation runs, it graphs the
average of the quantifier for all the runs (along with the errorbar)
"""
function graph_individual(measure, axs, loc)
    #Get and define data avg runs
    Data = get_avg_data(measure)
    B_values = Data[:,1]
    N_values = Data[:,2]
    variable_values = Data[:,end]

    #Get and define data errobars
    Data_errbar = get_errbar_data(measure)
    err_values = Data_errbar[:,end]

    #Get unique values of data run
    N = sort(find_unique_values(Data[:,2]))

    #Get colors for each plot
    colors = get_colors(N)

    #--------PLOT STOCHASTIC------
    #Generate plots for each unique B
    sizeN = size(N)[1]
    for i in 1:sizeN
        Ns = reverse(N)
        indexarray = findall( b -> b == Ns[i], N_values)

        axs[loc].plot(B_values[indexarray],variable_values[indexarray],label=string(Ns[i]),color=colors[i], marker="o")
        #plt.errorbar(B_values[indexarray],variable_values[indexarray],yerr=err_values[indexarray],color=colors[i])
        #plt.fill_between(B_values[indexarray],variable_values[indexarray]-err_values[indexarray],variable_values[indexarray]+err_values[indexarray],color=colors[i],alpha=0.1)
    end
end



"""
    graph_cluster_run(measure) → pdf file
Generates pdf file for specified `measure`
It specifies the aesthetics of the plot and saves it
TODO: improve code if individual plots of quantifiers are needed
"""
function graph_cluster_run(measure)

    #Define (sub)plots
    fig, axs = plt.subplots(2, sharex=true, figsize= (6,10))

    #Plot it
    graph_individual(measure, axs, 1)

    #Common x axis
    plt.xscale("log")
    plt.xlabel("Selection intensity coefficient ("*L"\beta"*")")
    plt.legend(loc="center left", bbox_to_anchor=(1, 0.5))

    #ylabel
    if measure == "FD"
        plt.ylabel("Fractal dimension ("*L"\Delta^{C}"*")")
    elseif measure == "FixT"
        plt.ylabel("Normalised fixation time ("*L"\tau"*")")
        plt.locator_params(axis="y", nbins=3)
    elseif measure == "LZ"
        plt.ylabel("Lempel-Ziv complexity ("*L"C_{LZ}"*")")
    elseif measure == "Std"
        plt.ylabel("Standard deviation ("*L"\sigma"*")")
        plt.locator_params(axis="y", nbins=4)
        plt.ylim((0,0.15))
    elseif measure == "PE"
        plt.ylabel("Permutation entropy ("*L"H"*")")
    end

    #Output
    plt.tight_layout()
    plt.savefig(plotsdir("GeneralQuantifiers/","General_"*measure*".pdf"))
    plt.clf()
end

######################################
#               RUN IT               #
######################################

Measures = ["Std","PE","LZ","FixT"]


for i in Measures
    graph_cluster_run(i)
end


################################################################################


"""
    graph_full_cluster() → pdf file
Generates pdf file for all measures
For each N value, it graphs the corresponding quantifier value in a unified plot (Quantifier vs B)
    It graphs the average of the quantifier for all the runs (along with the errorbar)
It specifies the aesthetics of the plot and saves it
"""
function graph_full_cluster()

    #Define subplots
    fig, axs = plt.subplots(3, sharex=true, figsize= (6,10))

    #Common x axis
    plt.xscale("log")
    plt.xlabel("Selection intensity coefficient ("*L"\beta"*")")
    plt.xlim((2, 1100))

    #---------------FIXATION TIME--------------
    graph_individual("FixT", axs, 1)
    axs[1].set_ylabel("Normalised fixation time ("*L"\tau"*")")
    axs[1].locator_params(axis="y", nbins=3)
    axs[1].set_ylim((-0.1, 1.2))
    axs[1].set_yticks([0,0.5,1.0],["0.0", "0.5", "1.0"])

    #---------------STANDARD DEVIATION--------------
    graph_individual("Std", axs, 2)
    axs[2].set_ylabel("Standard deviation ("*L"\sigma"*")")
    axs[2].locator_params(axis="y", nbins=4)
    axs[2].set_ylim((0,0.15))

    #---------------FRACTAL DIMENSION--------------
    graph_individual("FD", axs, 3)
    axs[3].set_ylabel("Fractal dimension ("*L"\Delta^{C}"*")")
    axs[3].locator_params(axis="y", nbins=3)
    axs[3].set_ylim((0.9, 3.1))
    axs[3].set_yticks([1,2,3],["1.0", "2.0", "3.0"])

    #Output
    plt.tight_layout()
    plt.savefig(plotsdir("GeneralQuantifiers/","General_Sto_Unified.pdf"))
    plt.clf()
end

######################################
#               RUN IT               #
######################################

graph_full_cluster()