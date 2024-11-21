"""
Functions used to display static 3D simplex representation
"""

using DrWatson
using CairoMakie

# Vertices 3D Cartesian simplex
# Typical order would be p1,p2,p3,p4. This order to have a particular point of view to view attractor
L = 1
p4 = Point(0.0, 0.0, 0.0)
p2 = Point(L, 0.0, 0.0)
p3 = Point(L/2, (sqrt(3)/2)*L, 0.0)
p1 = Point(L/2, (sqrt(3)/6)*L, (sqrt(2/3))*L)

"""
    static_3Dsimplex(data_3D) → png file
`data_3D`: dataset transformed to 3D cartesian (Matrix{Float64})
Plot the 3D Cartesian projection into the speficied 3D simplex via vertices p1, p2, p3, p4
"""
function static_3Dsimplex(data_3D)
    #Define figure and axis
    f = Figure()
    ax = Axis3(f[1,1], aspect = :equal, perspectiveness = 0.6)

    #Aesthetics
    hidedecorations!(ax)
    hidespines!(ax)

    #Angle of visualisation
    ax.azimuth[] = deg2rad(35)
    #ax.elevation = deg2rad(280)

    #3D simplex
    #mesh!(ax, [p1, p2, p3], [1, 2, 3], color = (:blue, 0.2))
    mesh!(ax, [p1, p3, p4], [1, 2, 3], color = (:blue, 0.25))
    mesh!(ax, [p2, p3, p4], [1, 2, 3], color = (:blue, 0.3))
    mesh!(ax, [p1, p2, p4], [1, 2, 3], color = (:blue, 0.2))

    #Labels vertices simplex
    text!(ax, [p1, p2, p3, p4], color= :gray, text = string.("x", 1:4), align = [
        (:center, :bottom),
        (:center, :top),
        (:center, :top),
        (:right, :baseline),
    ])

    #Trajectories
    lines!(ax, data_3D[:,1], data_3D[:,2], data_3D[:,3], color= :green)

    #wait(display(f))
    save(plotsdir("Static_3Dsimplex.png"),f; px_per_unit=10)
end


"""
    static_3Dsimplex(data_3D) → png file
`data_3D`: dataset transformed to 3D cartesian (Matrix{Float64})
Plot the 3D Cartesian projection into the speficied 3D simplex via vertices p1, p2, p3, p4
"""
function static_3Dsimplex_sideview(data_3D)
    #Define figure and axis
    f = Figure()
    ax = Axis3(f[1,1], aspect = :equal, perspectiveness = 0.6)

    #Aesthetics
    hidedecorations!(ax)
    hidespines!(ax)

    #Angle of visualisation
    ax.azimuth[] = deg2rad(135)
    #ax.elevation = deg2rad(280)

    #3D simplex
    mesh!(ax, [p1, p2, p3], [1, 2, 3], color = (:blue, 0.25))
    #mesh!(ax, [p1, p3, p4], [1, 2, 3], color = (:blue, 0.25))
    mesh!(ax, [p2, p3, p4], [1, 2, 3], color = (:blue, 0.3))
    mesh!(ax, [p1, p2, p4], [1, 2, 3], color = (:blue, 0.2))

    #Labels vertices simplex
    text!(ax, [p1, p2, p3, p4], color= :gray, text = string.("x", 1:4), align = [
        (:center, :bottom),
        (:right, :top),
        (:center, :top),
        (:right, :bottom),
    ])

    #Trajectories
    lines!(ax, data_3D[:,1], data_3D[:,2], data_3D[:,3], color= :green)

    #wait(display(f))
    save(plotsdir("Static_3Dsimplex_sideview.png"),f; px_per_unit=10)
end