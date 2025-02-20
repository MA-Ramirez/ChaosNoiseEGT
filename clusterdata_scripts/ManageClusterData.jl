"""
Script used to manage the quantifiers data of many stochastic runs
"""

using DrWatson
@quickactivate "ChaosNoiseEGT"

using CSV
using DataFrames
using Statistics
using DelimitedFiles

################################################################################
#                                      Get data                                #
################################################################################

"""
    getdata(measure) → DataFrame
Returns DataFrame with the data of the quantifier specified by `measure`
"""
function getdata(measure)
    data = CSV.read(datadir("Quantifiers/ClusterQuantifiers", "unified_"*measure*".csv"), DataFrame,header=false)
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

"""
    findTuple_getQuantifierValues(data,tuple) → Vector{Float64}
Finds tuple (B,N) in data and returns the quantifier value(s) in data
that correspond to the tuple
"""
function findTuple_getQuantifierValues(data,tuple)
    num_rows = size(data)[1]
    beta_values_data = data[:,1]
    N_values_data = data[:,2]
    quantifier_values_data = data[:,end]
    B_toFind = tuple[1]
    N_toFind = tuple[2]
    quantifier_values_found = []

    for i in 1:num_rows
        if B_toFind == beta_values_data[i] && N_toFind == N_values_data[i]
            push!(quantifier_values_found,quantifier_values_data[i])
        end
    end
    return quantifier_values_found
end

"""
    fill_avg_file(quantifier_vals_tuple, tuple, measure) → txt file
`quantifier_vals_tuple`: vector with values of quantifier corresponding to the tuple (B,N)
`tuple`: (B,N)
`measure`: defines the quantifier to be calculated
Fills the file containing the mean values of the quantifiers for each tuple (B,N)
It obtains the average of the quantifier for each tuple for all the stochastic runs
"""
function fill_avg_file(quantifier_vals_tuple, tuple, measure)
    Btemp = tuple[1]
    Ntemp = tuple[2]
    mean_val = mean(quantifier_vals_tuple)
    #Full info to be saved
    info_mean = adjoint([Btemp,Ntemp,mean_val])
    #The solution is saved in data/Quantifiers/ClusterQuantifiers
    open(datadir("Quantifiers/ClusterQuantifiers", "Sto_Avg_"*string(measure)*".csv"), "a") do io
        writedlm(io, info_mean,",")
    end
end

"""
    fill_errorbar_file(quantifier_vals_tuple, tuple, measure) → txt file
`quantifier_vals_tuple`: vector with values of quantifier corresponding to the tuple (B,N)
`tuple`: (B,N)
`measure`: defines the quantifier to be calculated
Fills the file containing the errorbar values of the quantifiers for each tuple (B,N)
It obtains the standard deviation of the quantifier for each tuple for all the stochastic runs
"""
function fill_errorbar_file(quantifier_vals_tuple, tuple, measure)
    Btemp = tuple[1]
    Ntemp = tuple[2]
    #if std of only 1 value is calculated, it returns NaN
    errbar_val = std(quantifier_vals_tuple)
    #Full info to be saved
    info_errbar = adjoint([Btemp,Ntemp,errbar_val])
    #The solution is saved in data/Quantifiers/ClusterQuantifiers
    open(datadir("Quantifiers/ClusterQuantifiers", "Sto_ErrBar_"*string(measure)*".csv"), "a") do io
        writedlm(io, info_errbar,",")
    end
end

################################################################################
#                                    Run Process                               #
################################################################################

"""
    run_managedata(measure)
`measure`: string that specifies the quantifer measure to be calculated
Executes the whole process for a given quantifier measure
"""
function run_managedata(measure)
    Data = getdata(measure)
    Data = dropmissing(Data)

    B = find_unique_values(Data[:,1])
    N = find_unique_values(Data[:,2])

    for i in B
        for j in N
            array_quantifier_vals = findTuple_getQuantifierValues(Data,(i,j))
            fill_avg_file(array_quantifier_vals, (i,j), measure)
            fill_errorbar_file(array_quantifier_vals, (i,j), measure)
        end
    end
end

################################################################################

Measures = ["FD","Std","PE","FixT","LZ"]

for i in Measures
    run_managedata(i)
end
