"""
Functions used to quantify relevant features of the dynamics.
-Fractal dimension
-Standard deviation
-Fixation time
-LempelZiv complexity measure
"""

using DrWatson
using DynamicalSystems
using Statistics

##################################################
#                 FRACTAL DIMENSION              #
##################################################
"""
    fractal_dimension(data) → Tuple{Float64, Vector{Float64}, Vector{Float64}}
    The output is: Fractal Dimension (Float64)
    Radii in logarithmic scale (Vector{Float64})
    Correlation sum in logarithmic scale (Vector{Float64})
The fractal dimension of the attractor is calculated using the correlation dimension.
It is based on the correlation sum, which measures how tightly clustered the points
are in a set. i.e. the amount of neighbours within a radius.
It makes use of the function `boxed_correlationsum` of the DynamicalSystems package.
https://juliadynamics.github.io/DynamicalSystems.jl/latest/chaos/fractaldim/
"""
function fractal_dimension(data)
    #Turn Matrix{Float64} into Dataset, if needed
    if typeof(data) == Matrix{Float64}
        data =Dataset(data)
    end

    #The range of radii are defined
    εs = 10.0 .^ range(-5,-0.1;length=50)

    #The correlation sum for all radii are calculated
    cs = boxed_correlationsum(data::Dataset, εs)

    #Radii and correlation sum in logarithmic scale
    Lεs = log10.(εs)
    Lcs = log10.(cs)

    #Calculates the slope of the linear region
    slope_info = linear_region(log10.(εs),log10.(cs))

    frac_dim = round(slope_info[2], digits= 5)
    return frac_dim, Lεs, Lcs
end

##################################################
#                STANDARD DEVIATION              #
##################################################
"""
    standard_deviation(data) → Vector{Float64}
Calculates the standard deviation for all variables in data.
"""
function standard_deviation(data)
    std_all = Vector{Float64}(undef,size(data)[2])

    for i in 1:size(data)[2]
        std_xi = round(std(data[:,i]),digits=3)
        std_all[i] = std_xi
    end

    return std_all
end

##################################################
#                  FIXATION TIME                 #
##################################################
"""
    fixation_time(data) → Int64
Returns the amount of time steps for of the evolution of the trajectory.
i.e. length of the vector corresponding to each variable
"""
function fixation_time(data)
    fix_time = size(data)[1]
    return fix_time
end

##################################################
#                   LEMPEL-ZIV                   #
##################################################
"""
    lempel_ziv_complexity(sequence) → Int64
Lempel-Ziv complexity measure for a binary sequence, in naive Julia code.
  https://GitHub.com/Naereen/Lempel-Ziv_Complexity
"""
function lempel_ziv_complexity(sequence)
    sub_strings = Set()
    n = length(sequence)

    ind = 1
    inc = 0
    while true
        if ind + inc > n
            break
        end
        sub_str = sequence[ind : ind + inc]
        if sub_str in sub_strings
            inc += 1
        else
            push!(sub_strings, sub_str)
            ind += (inc+1)
            inc = 0
        end
    end
    return length(sub_strings)
end

"""
    binarise_vector(vecData) → String
Turns vector into a binary sequence of type `String`.
The binarisation works as follows:
if element is below the vector mean is equal to 0, otherwise it is equal to 1.
"""
function binarise_vector(vecdata)
    #Calculate mean of array
    mean_vec = mean(vecdata)
    #Empty string to store binsarised output
    Str = ""

    #Binarise each element of array
    for i in 1:size(vecdata)[1]
        if vecdata[i] < mean_vec
            Str = string(Str,"0")
        else
            Str = string(Str,"1")
        end
    end
    return Str
end

"""
    lempelzivdata(data) → Vector{Float64}
Calculates Lempel-Ziv complexity measure for all the variables in data.
The final element is the average of the Lempel-Ziv measure of all variables.
"""
function lempelzivdata(data)
    num_variables = size(data)[2]

    LZ_all = Vector{Float64}(undef,num_variables+1)

    #LZ calculation for each variable
    for i in 1:num_variables
        binary_vector = binarise_vector(data[:,i])
        LZ_vector = Float64(lempel_ziv_complexity(binary_vector))
        LZ_all[i] = LZ_vector
    end

    #Mean of LZ measure of all variables
    mean_LZ_all = mean(LZ_all[1:end-1])
    #Add mean at the end of vector
    LZ_all[end] = mean_LZ_all

    return LZ_all
end
