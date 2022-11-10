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

"""
    fractal_dimension(data) → Float64
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

    #Calculates the slope of the linear region
    slope_info = linear_region(log10.(εs),log10.(cs))

    frac_dim = round(slope_info[2], digits= 5)
    return frac_dim
end

"""
    standard_deviation(data) → Vector{Float64}
Calculates the standard deviation for all variables in data.
"""
function standard_deviation(data)
    ans = Vector{Float64}(undef,size(data)[2])

    for i in 1:size(data)[2]
        std_xi = round(std(data[:,i]),digits=3)
        ans[i] = std_xi
    end

    return ans
end

#TO-DO get these graphs
#The correlation sums are plotted as a function of the radii, in a logarithmic scale
#scatter(log10.(εs),log10.(cs))
