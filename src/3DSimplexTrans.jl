"""
Functions used to perform the 3D simplex transformation
"""

using DrWatson

# Vertices 3D Cartesian simplex
# Typical order would be p1,p2,p3,p4. This order to have a particular point of view to view attractor
L = 1
v4 = [0.0, 0.0, 0.0]
v2 = [L, 0.0, 0.0]
v3 = [L/2, (sqrt(3)/2)*L, 0.0]
v1 = [L/2, (sqrt(3)/6)*L, (sqrt(2/3))*L]

# Define vertices in a list (Vector{Vector{Float64}})
vertices = [v1, v2, v3, v4]

"""
    barycentric_to_cartesian(x, vertices) → Vector{Float64}
`x`: normalised vector to be transformed to 3D cartesian (Vector{Float64})
`vertices`: reference vertices of the 3d simplex (Vector{Vector{Float64}})
Compute the 3D Cartesian projection
Transforms `x` to 3D cartesian coordinates according to the `vertices` of the speficied 3D simplex
"""
function barycentric_to_cartesian(x, vertices)
    # Vertices matrix
    column_vertices = hcat(vertices...)
    V = vcat(column_vertices,transpose(ones(4)))

    # Weighted sum of vertices
    ans = V * x
    return ans
end

"""
    barycentric_to_cartesian_data(data, vertices) → Matrix{Float64}
`data`: normalised 4D dataset to be transformed to 3D cartesian coordinate system. Each row contains a 4D normalised vector (Matrix{Float64})
`vertices`: reference vertices of the 3D simplex (Vector{Vector{Float64}})
Compute the 3D Cartesian projection of dataset
Transforms 4D `data` to 3D cartesian coordinates according to the `vertices` of the speficied 3D simplex
"""
function barycentric_to_cartesian_data(data, vertices)
    ans_trans = Array{Vector{Float64}}(undef, size(data,1))
    for i in 1:size(data,1)
        #Transform each row of dataset
        trans = barycentric_to_cartesian(vec(data[i,:]), vertices)
        #3D cartesian system
        ans_trans[i] = trans[1:3]
    end
    #Add each transformed row to a single matrix
    ans_matrix = permutedims(hcat(ans_trans...))
    return ans_matrix
end