"""
Functions used to quantify relevant features of the dynamics.
-Fractal dimension
-Standard deviation
-Fixation time
-LempelZiv complexity measure
-Fourier spectrum
"""

using DrWatson
using DynamicalSystems
using Statistics
using FFTW

include(srcdir("StochasticSRC.jl"))

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
The final value of the list is the average of all the calculated standard deviations.
"""
function standard_deviation(data)
    std_all = Vector{Float64}(undef,size(data)[2]+1)

    for i in 1:size(data)[2]
        std_xi = round(std(data[:,i]),digits=3)
        std_all[i] = std_xi
    end

    std_all[end] = mean(std_all[1:end-1])

    return std_all
end

##################################################
#                  FOURIER SPECTRUM              #
##################################################
"""
    fourier_spectrum(data,xlim_val) → fourier spectrum plot
Returns the fourier spectrum of a data set
`xlim_val`: value of the xlim range
"""
function fourier_spectrum(data)
    sampling_rate = 1.0/0.01
    F = fftshift(fft(data[:,1]))
    freqs = fftshift(fftfreq(length(data[:,1]), sampling_rate))
    return freqs, abs.(F)
end

##################################################
#              PERMUTATION ENTROPY               #
##################################################

"""
    permutation_entropy(data) → Float64 
Returns the normalised permutation entropy value of order 6
"""
function permutation_entropy(data)
    #any variable gives the same behaviour
    dataset = data[:,1]
    order_value = 6
    normalisation_cte = 1/(log(factorial(order_value)))
    PE = normalisation_cte*entropy(SymbolicPermutation(; m=order_value, τ=1), dataset)
    return PE
end

##################################################
#                  FIXATION TIME                 #
##################################################
"""
    fixation_time(data,populationsize, beta) → Float64
Returns the normalised fixation time
i.e. length of trajectory / total available time steps
"""
function fixation_time(data, populationsize, beta)
    total_steps = set_timesteps_others(populationsize, beta)
    trajectory_steps = size(data)[1]

    fix_time = trajectory_steps/total_steps

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

"""
    lempelzivdata_stochastic(data) → Vector{Float64}
Calculates Lempel-Ziv complexity measure for all the variables in data.
 LZ is only measured for the last 100 elements of each variable, 
    given that LZ is proportional to the length of the time series
The final element is the average of the Lempel-Ziv measure of all variables.
"""
function lempelzivdata_stochastic(data)
    num_variables = size(data)[2]

    LZ_all = Vector{Float64}(undef,num_variables+1)

    #LZ calculation for each variable
    for i in 1:num_variables
        #Only the last 100 elements of each variable
        #  This measure is proportional to the length of the time series
        binary_vector = binarise_vector(data[end-100:end,i])
        LZ_vector = Float64(lempel_ziv_complexity(binary_vector))
        LZ_all[i] = LZ_vector
    end

    #Mean of LZ measure of all variables
    mean_LZ_all = mean(LZ_all[1:end-1])
    #Add mean at the end of vector
    LZ_all[end] = mean_LZ_all

    return LZ_all
end

########################################################
#  Auxiliary function to graph according to color map  #
########################################################

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