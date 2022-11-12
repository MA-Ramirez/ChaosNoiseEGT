"""
Script used to run the quantifiers on a given dataset.
Each quantifier is saved on a different file.

*It is recommended that the amount of data points do not exceed the order of 10^{5},
since the computational time for the function `boxed_correlationsum` becomes excessively high.*
"""

using DrWatson
@quickactivate "ChaosNoiseEGT"

include(srcdir("Quantifiers.jl"))

using DelimitedFiles
using PyPlot

################################################################################
#                                   Import data                                #
################################################################################

#Dictionary of names of all the files in data/Deterministic
datafiles_names = readdir(datadir("Deterministic"))

"""
    getdata(namefile,approach::String) → Matrix{Float64}
`approach`: defines if Deterministic or Stochastic will be analysed.
This parameter is used also for folder organisation purposes
Imports data from files and returns it as a matrix
"""
function getdata(namefile,approach::String)
    #The approach can only be "Deterministic" or "Stochastic"
    if approach != "Deterministic" && approach != "Stochastic"
        throw(ArgumentError("The approach can only be Deterministic or Stochastic. It is case sensitive. Check spelling."))
    end

    data = readdlm(datadir(approach, namefile))

    return data
end

"""
    getparams(namefile,approach::String) → Float64 or Vector{Float64}
`approach`: defines if Deterministic or Stochastic will be analysed.
This parameter is used also for folder organisation purposes
Gets parameters information from `namefile`
"""
function getparams(namefile,approach::String)
    #The approach can only be "Deterministic" or "Stochastic"
    if approach != "Deterministic" && approach != "Stochastic"
        throw(ArgumentError("The approach can only be Deterministic or Stochastic. It is case sensitive. Check spelling."))
    end

    #Only B needs to be retrieved from namefile for the deterministic case
    if approach == "Deterministic"
        ini =findfirst("B=",namefile)[end]
        fin = findfirst(".txt",namefile)[1]
        B = namefile[ini+1:fin-1]
        ans = parse(Float64,B)
    end
    return ans
end

################################################################################
#                   Apply quantifiers to data and save results                 #
################################################################################

##################################################
#                 FRACTAL DIMENSION              #
##################################################
"""
    graph_fractaldimension(namefile,Les,Lcs,approach::String) → pdf file
Graph logarithmic correlation sum vs logarithmic radii for fractal dimension calculation
"""
function graph_fractaldimension(namefile,Les,Lcs,approach::String)
    #The approach can only be "Deterministic" or "Stochastic"
    if approach != "Deterministic" && approach != "Stochastic"
        throw(ArgumentError("The approach can only be Deterministic or Stochastic. It is case sensitive. Check spelling."))
    end

    #Command to turn off automatic figure output in screen
    ioff()
    scatter(Les,Lcs)
    xlabel(L"log_{10}(\varepsilon)")
    ylabel(L"log_{10}(C)")
    #CREATE FIRST THE SUBFOLDER "Deterministic/FractalDimDet" IN THE "Plots" FOLDER
    savefig(plotsdir(approach*"/FractalDimDet",namefile[1:end-4]*String("_FD.pdf")))
    clf()
end

"""
    run_fractaldimension(data,namefile,approach::String) → pdf file, txt file
Run and save the fractal dimension of the data. Also graph the fractal
dimension calculation plot.
"""
function run_fractaldimension(data,namefile,approach::String)
    FD_info = fractal_dimension(data)

    #Fractal Dimension (Float64)
    FD = [FD_info[1]]
    #Radii in logarithmic scale (Vector{Float64})
    Les = FD_info[2]
    #Correlation sum in logarithmic scale (Vector{Float64})
    Lcs = FD_info[3]

    #Graphs plot for fractal dimension calculation
    graph_fractaldimension(namefile,Les,Lcs,approach)

    #Full info to be saved
    info_FD = adjoint(prepend!(FD,getparams(namefile,approach)))
    #The solution is saved in data/Quantifiers_Deterministic
    open(datadir("Quantifiers_"*approach, "Det_FD.txt"), "a") do io
        writedlm(io, info_FD,",")
    end
end

##################################################
#                STANDARD DEVIATION              #
##################################################
"""
    run_standarddeviation(data,namefile,approach::String) → txt file
Run and save the standard deviation of the data
"""
function run_standarddeviation(data,namefile,approach::String)
    std = standard_deviation(data)

    #Full info to be saved
    info_std = adjoint(prepend!(std,getparams(namefile,approach)))
    #The solution is saved in data/Quantifiers_Deterministic
    open(datadir("Quantifiers_"*approach, "Det_Std.txt"), "a") do io
        writedlm(io, info_std,",")
    end
end

##################################################
#                  FIXATION TIME                 #
##################################################
"""
    run_fixationtime(data,namefile,approach::String) → txt file
Run and save the fixation time of the data
"""
function run_fixationtime(data,namefile,approach::String)
    fixT = [Float64(fixation_time(data))]

    #Full info to be saved
    info_fixT = adjoint(prepend!(fixT,getparams(namefile,approach)))
    #The solution is saved in data/Quantifiers_Deterministic
    open(datadir("Quantifiers_"*approach, "Det_FixT.txt"), "a") do io
        writedlm(io, info_fixT,",")
    end
end

##################################################
#                   LEMPEL-ZIV                   #
##################################################
"""
    run_lempelziv(data,namefile,approach::String) → txt file
Run and save the Lempel-Ziv complexity measure of the data
"""
function run_lempelziv(data,namefile,approach::String)
    LZ_data = lempelzivdata(data)


    #Full info to be saved
    info_LZ = adjoint(prepend!(LZ_data,getparams(namefile,approach)))
    #The solution is saved in data/Quantifiers_Deterministic
    open(datadir("Quantifiers_"*approach, "Det_LZ.txt"), "a") do io
        writedlm(io, info_LZ,",")
    end
end

"""
    run_quantifiers(namefile,approach::String)
`approach`: defines if Deterministic or Stochastic will be analysed.
This parameter is used also for folder organisation purposes
Run quantifiers and save info in corresponding file
"""
function run_quantifiers(namefile,approach::String)
    #The approach can only be "Deterministic" or "Stochastic"
    if approach != "Deterministic" && approach != "Stochastic"
        throw(ArgumentError("The approach can only be Deterministic or Stochastic. It is case sensitive. Check spelling."))
    end

    Data = getdata(namefile,approach)

    ##################################################
    #                 FRACTAL DIMENSION              #
    ##################################################
    run_fractaldimension(Data,namefile,approach)

    ##################################################
    #                STANDARD DEVIATION              #
    ##################################################
    run_standarddeviation(Data,namefile,approach)

    ##################################################
    #                  FIXATION TIME                 #
    ##################################################
    run_fixationtime(Data,namefile,approach)

    ##################################################
    #                   LEMPEL-ZIV                   #
    ##################################################
    run_lempelziv(Data,namefile,approach)

end

run_quantifiers(datafiles_names[1],"Deterministic")
