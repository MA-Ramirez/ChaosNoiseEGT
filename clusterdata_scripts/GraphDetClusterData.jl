"""
Script used to graph the quantifiers data of the deterministic trajectories
"""

using DrWatson
@quickactivate "ChaosNoiseEGT"

using CSV, DataFrames, LaTeXStrings, DelimitedFiles, PyPlot

"""
    get_data(measure) → DataFrame
Returns DataFrame with the mean data of the quantifier specified by `measure`
"""
function get_data(measure)
    data = CSV.read(datadir("Quantifiers/QuantifiersDet", "Det_"*measure*".csv"), DataFrame,header=false)
    return data
end

"""
    graph_cluster_run(measure) → pdf file
Generates pdf file for specified `measure`
For each B value, it graphs the corresponding quantifier value
"""
function graph_det_cluster_run(measure)

    #Get and define data avg runs
    Data = get_data(measure)


    #General Aesthetics
    xscale("log")
    xlabel("Selection intensity coefficient ("*L"\beta"*")")
    #plt.xticks([10^2,10^3,10^4,10^5,10^7],[L"10^2",L"10^3",L"10^4",L"10^5","Deterministic"])

    #ylabel
    if measure == "FD"
        Data = sort!(Data, [:Column1])
        println(measure)
        println(Data)
        B_values = Data[:,1]
        variable_values = Data[:,end]
        scatter(B_values, variable_values)
        plot(B_values, variable_values)
        ylabel("Fractal dimension ("*L"\Delta^{C}"*")")
    elseif measure == "FixT"
        sort!(Data, [:Column1])
        println(measure)
        println(Data)
        B_values = Data[:,1]
        variable_values = Data[:,end]
        scatter(B_values, variable_values)
        plot(B_values, variable_values)
        ylabel("Fixation time ("*L"\tau"*")")
    elseif measure == "LZ"
        sort!(Data, [:Column1])
        println(measure)
        println(Data)
        B_values = Data[:,1]
        variable_values = Data[:,end]
        scatter(B_values, variable_values)
        plot(B_values, variable_values)
        ylabel("Lempel-Ziv complexity ("*L"C_{LZ}"*")")
    elseif measure == "PE"
        sort!(Data, [:Column1])
        println(measure)
        println(Data)
        B_values = Data[:,1]
        variable_values = Data[:,end]
        scatter(B_values, variable_values)
        plot(B_values, variable_values)
        ylabel("Permutation entropy ("*L"H"*")")
    elseif measure == "Std"
        sort!(Data, [:Column1])
        println(measure)
        println(Data)
        B_values = Data[:,1]
        for i in 2:5
            scatter(B_values, Data[:,i], label = string(i))
            plot(B_values, Data[:,i], label = string(i))
        end
        legend(loc=4)
        ylabel("Standard deviation ("*L"\sigma"*")")
    elseif measure == "LE"
        Data = sort!(Data, [:Column1])
        println(measure)
        println(Data)
        yscale("symlog")
        B_values = Data[:,1]
        for i in 2:5
            scatter(B_values, Data[:,i], label = string(i))
            plot(B_values, Data[:,i], label = string(i))
        end
        legend(loc=4)
        ylabel("Lyapunov exponents ("*L"\lambda)")
        #ylim((-0.1,0.025))
        #hline()
    end

    #Output
    tight_layout()
    savefig(plotsdir("GeneralQuantifiers/","General_Det_"*measure*".png"))
    clf()
end

#Measures = ["FD", "FixT", "LE", "LZ", "PE", "Std"]
Measures = ["LE"]

for i in Measures
    graph_det_cluster_run(i)
end
