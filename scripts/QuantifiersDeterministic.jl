"""
Script used to run the quantifiers on a given dataset.
Each quantifier is saved on a different file.
"""

using DrWatson
@quickactivate "ChaosNoiseEGT"

include(srcdir("Quantifiers.jl"))

using DelimitedFiles

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

    #FRACTAL DIMENSION
    FD = [fractal_dimension(Data)]

    #Full info to be saved
    info_FD = adjoint(prepend!(FD,getparams(namefile,approach)))
    #The solution is saved in data/Quantifiers_Deterministic
    open(datadir("Quantifiers_"*approach, "Det_FD.txt"), "a") do io
        writedlm(io, info_FD,",")
    end

    #STANDARD DEVIATION
    std = standard_deviation(Data)

    #Full info to be saved
    info_std = adjoint(prepend!(std,getparams(namefile,approach)))
    #The solution is saved in data/Quantifiers_Deterministic
    open(datadir("Quantifiers_"*approach, "Det_Std.txt"), "a") do io
        writedlm(io, info_std,",")
    end

end

run_quantifiers(datafiles_names[1],"Deterministic")
