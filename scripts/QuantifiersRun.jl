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
using PyCall
using LaTeXStrings

@pyimport matplotlib.pyplot as plt

################################################################################
#                                   Import data                                #
################################################################################

#Check correct input of parameters
num_arguments = size(ARGS)[1]
if num_arguments == 1
    APPROACH = "Deterministic"
elseif num_arguments == 2
    APPROACH = "Stochastic"
else
    throw(ArgumentError("There should be 3 command line arguments, but there are "*string(num_arguments)))
end

#Obtain arguments and define them as global variables
B = ARGS[1]
if num_arguments == 2
    N = ARGS[2]
end

#From arguments define the name of the file to read
if APPROACH == "Deterministic"
    NAMEFILE = "Det_B="*B*".txt"
elseif APPROACH == "Stochastic"
    NAMEFILE = "Sto_B="*B*"_N="*N*".txt"
end

"""
    getdata(approach,namefile) → Matrix{Float64}
`approach`: defines if Deterministic or Stochastic will be analysed.
This parameter is used also for folder organisation purposes
Imports data from files and returns it as a matrix
"""
function getdata(approach,namefile)
    if approach == "Deterministic"
        data = readdlm(datadir("Deterministic", namefile))
    elseif approach == "Stochastic"
        data = readdlm(datadir("Stochastic", namefile))
    end

    return data
end

################################################################################
#                   Apply quantifiers to data and save results                 #
################################################################################

##################################################
#                 FRACTAL DIMENSION              #
##################################################
"""
    graph_fractaldimension(approach,namefile,Les,Lcs) → pdf file
Graph logarithmic correlation sum vs logarithmic radii for fractal dimension calculation
"""
function graph_fractaldimension(approach,namefile,Les,Lcs)

    #Command to turn off automatic figure output in screen
    #ioff()
    plt.scatter(Les,Lcs)
    plt.xlabel(L"log_{10}(\varepsilon)")
    plt.ylabel(L"log_{10}(C)")
    plt.locator_params(axis="x", nbins=6)
    plt.xlim((-5,0))
    #Save settings
    if approach == "Deterministic"
        #CREATE FIRST THE SUBFOLDER "Deterministic/FractalDimDet" IN THE "Plots" FOLDER
        plt.savefig(plotsdir(approach*"/FractalDimDet",namefile[1:end-4]*String("_FD.pdf")))
    elseif approach == "Stochastic"
        #CREATE FIRST THE SUBFOLDER "Stochastic/FractalDimSto" IN THE "Plots" FOLDER
        plt.savefig(plotsdir(approach*"/FractalDimSto",namefile[1:end-4]*String("_FD.pdf")))
    end
    plt.clf()
end

"""
    run_fractaldimension(approach,data) → pdf file, csv file
Run and save the fractal dimension of the data. Also graph the fractal
dimension calculation plot.
"""
function run_fractaldimension(approach,data)
    FD_info = fractal_dimension(data)

    #Fractal Dimension (Float64)
    FD = [FD_info[1]]
    #Radii in logarithmic scale (Vector{Float64})
    Les = FD_info[2]
    #Correlation sum in logarithmic scale (Vector{Float64})
    Lcs = FD_info[3]

    #Graphs plot for fractal dimension calculation
    #graph_fractaldimension(approach,namefile,Les,Lcs)

    if approach == "Deterministic"
        #Full info to be saved
        params = [parse(Float64,B)]
        info_FD = adjoint(prepend!(FD,params))
        #The solution is saved in data/Quantifiers/QuantifiersDet
        open(datadir("Quantifiers/QuantifiersDet", "Det_FD.csv"), "a") do io
            writedlm(io, info_FD,",")
        end
    elseif approach == "Stochastic"
        #Full info to be saved
        params = [parse(Float64,B),parse(Int64,N)]
        info_FD = adjoint(prepend!(FD,params))
        #The solution is saved in data/Quantifiers/QuantifiersSto
        open(datadir("Quantifiers/QuantifiersSto", "Sto_FD.csv"), "a") do io
            writedlm(io, info_FD,",")
        end
    end

    return Les, Lcs
end

##################################################
#                STANDARD DEVIATION              #
##################################################
"""
    run_standarddeviation(approach,data,namefile) → csv file
Run and save the standard deviation of the data
"""
function run_standarddeviation(approach,data)
    std = standard_deviation(data)

    if approach == "Deterministic"
        #Full info to be saved
        params = [parse(Float64,B)]
        info_std = adjoint(prepend!(std,params))
        #The solution is saved in data/Quantifiers/QuantifiersDet
        open(datadir("Quantifiers/QuantifiersDet", "Det_Std.csv"), "a") do io
            writedlm(io, info_std,",")
        end
    elseif approach == "Stochastic"
        #Full info to be saved
        params = [parse(Float64,B),parse(Int64,N)]
        info_std = adjoint(prepend!(std,params))
        #The solution is saved in data/Quantifiers/QuantifiersSto
        open(datadir("Quantifiers/QuantifiersSto", "Sto_Std.csv"), "a") do io
            writedlm(io, info_std,",")
        end
    end
end

##################################################
#              PERMUTATION ENTROPY               #
##################################################
"""
    run_permutationentropy(approach,data) → csv file
Run and save the permutation entropy of the data
"""
function run_permutationentropy(approach,data)
    PE = [permutation_entropy(data)]

    if approach == "Deterministic"
        #Full info to be saved
        params = [parse(Float64,B)]
        info_PE = adjoint(prepend!(PE,params))
        #The solution is saved in data/Quantifiers/QuantifiersDet
        open(datadir("Quantifiers/QuantifiersDet", "Det_PE.csv"), "a") do io
            writedlm(io, info_PE,",")
        end
    elseif approach == "Stochastic"
        #Full info to be saved
        params = [parse(Float64,B),parse(Int64,N)]
        info_PE = adjoint(prepend!(PE,params))
        #The solution is saved in data/Quantifiers/QuantifiersSto
        open(datadir("Quantifiers/QuantifiersSto", "Sto_PE.csv"), "a") do io
            writedlm(io, info_PE,",")
        end
    end
end

##################################################
#                  FIXATION TIME                 #
##################################################
"""
    run_fixationtime(approach,data) → csv file
Run and save the fixation time of the data
"""
function run_fixationtime(approach,data)
    fixT = [Float64(fixation_time(data, N, B))]

    if approach == "Deterministic"
        #Full info to be saved
        params = [parse(Float64,B)]
        info_fixT = adjoint(prepend!(fixT,params))
        #The solution is saved in data/Quantifiers/QuantifiersDet
        open(datadir("Quantifiers/QuantifiersDet", "Det_FixT.csv"), "a") do io
            writedlm(io, info_fixT,",")
        end
    elseif approach == "Stochastic"
        #Full info to be saved
        params = [parse(Float64,B),parse(Int64,N)]
        info_fixT = adjoint(prepend!(fixT,params))
        #The solution is saved in data/Quantifiers/QuantifiersSto
        open(datadir("Quantifiers/QuantifiersSto", "Sto_FixT.csv"), "a") do io
            writedlm(io, info_fixT,",")
        end
    end
end

##################################################
#                   LEMPEL-ZIV                   #
##################################################
"""
    run_lempelziv(approach,data) → csv file
Run and save the Lempel-Ziv complexity measure of the data
"""
function run_lempelziv(approach,data)
    if approach == "Deterministic"
        LZ = lempelzivdata(data)

        #Full info to be saved
        params = [parse(Float64,B)]
        info_LZ = adjoint(prepend!(LZ,params))
        #The solution is saved in data/Quantifiers/QuantifiersDet
        open(datadir("Quantifiers/QuantifiersDet", "Det_LZ.csv"), "a") do io
            writedlm(io, info_LZ,",")
        end
    elseif approach == "Stochastic"
        LZ = lempelzivdata_stochastic(data)

        #Full info to be saved
        params = [parse(Float64,B),parse(Int64,N)]
        info_LZ = adjoint(prepend!(LZ,params))
        #The solution is saved in data/Quantifiers/QuantifiersSto
        open(datadir("Quantifiers/QuantifiersSto", "Sto_LZ.csv"), "a") do io
            writedlm(io, info_LZ,",")
        end
    end
end

"""
    run_quantifiers(approach,namefile)
`approach`: defines if Deterministic or Stochastic will be analysed.
This parameter is used also for folder organisation purposes
Run quantifiers and save info in corresponding file
"""
function run_quantifiers(approach,namefile)

    Data = getdata(approach,namefile)

    ##################################################
    #                 FRACTAL DIMENSION              #
    ##################################################
    Les,Lcs = run_fractaldimension(approach,Data)
    graph_fractaldimension(approach,namefile,Les,Lcs)

    ##################################################
    #                STANDARD DEVIATION              #
    ##################################################
    run_standarddeviation(approach,Data)

     ##################################################
    #                   PERMUTATION ENTROPY           #
    ##################################################
    run_permutationentropy(approach,Data)

    ##################################################
    #                  FIXATION TIME                 #
    ##################################################
    run_fixationtime(approach,Data)

    ##################################################
    #                   LEMPEL-ZIV                   #
    ##################################################
    run_lempelziv(approach,Data)

end

t1 = time()
run_quantifiers(APPROACH,NAMEFILE)
running_time = time() - t1
println("Running time quantifiers: ", running_time, " seconds")