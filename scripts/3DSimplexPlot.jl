"""
Script used to plot the trajectories in a 3D simplex
"""

using DrWatson
@quickactivate "ChaosNoiseEGT"

include(srcdir("3DSimplexTrans.jl"))
include(srcdir("Static_3DSimplex.jl"))
include(srcdir("Interactive_3DSimplex.jl"))

using DelimitedFiles


#Read dataset
Data = readdlm(datadir("Det_B01.csv"))

#Transform 4D normalised data to 3D cartesian
cartesian_data = barycentric_to_cartesian_data(Data, vertices)

# Static 3D simplex representation
#static_3Dsimplex(cartesian_data)
#static_3Dsimplex_sideview(cartesian_data)

# Interactive 3D simplex
#interactive_3Dsimplex(cartesian_data)

# Animation trajectories in 3D simplex (3D interactive simplex possible if displayed)
animation_3Dsimplex(cartesian_data)

