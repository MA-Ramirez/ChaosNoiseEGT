"""
Functions used to display static 3D simplex representation
"""

using DrWatson
using GLMakie

# Vertices 3D Cartesian simplex
# Typical order would be p1,p2,p3,p4. This order to have a particular point of view to view attractor
L = 1
p4 = Point(0.0, 0.0, 0.0)
p2 = Point(L, 0.0, 0.0)
p3 = Point(L/2, (sqrt(3)/2)*L, 0.0)
p1 = Point(L/2, (sqrt(3)/6)*L, (sqrt(2/3))*L)


"""
    interactive_3Dsimplex(data_3D) → interactive interface
`data_3D`: dataset transformed to 3D cartesian (Matrix{Float64})
Plot the 3D Cartesian projection into the speficied 3D simplex via vertices p1, p2, p3, p4
"""
function interactive_3Dsimplex(data_3D)
    s = Scene(; camera = cam3d!)

    #Base 3D simplex
    #mesh!(s, [p2, p3, p4], [1, 2, 3], color = (:blue, 0.1))

    # SIMPLEX LINES
    xs = [p1[1],p2[1]]
    ys = [p1[2],p2[2]]
    zs = [p1[3],p2[3]]
    lines!(s,xs,ys,zs,color = (:blue, 0.3))

    xs = [p1[1],p3[1]]
    ys = [p1[2],p3[2]]
    zs = [p1[3],p3[3]]
    lines!(s,xs,ys,zs,color = (:blue, 0.3))

    xs = [p1[1],p4[1]]
    ys = [p1[2],p4[2]]
    zs = [p1[3],p4[3]]
    lines!(s,xs,ys,zs,color = (:blue, 0.3))

    #BASE SIMPLEX
    xs = [p2[1],p4[1]]
    ys = [p2[2],p4[2]]
    zs = [p2[3],p4[3]]
    lines!(s,xs,ys,zs,color = (:blue, 0.5), linewidth = 5)

    xs = [p3[1],p4[1]]
    ys = [p3[2],p4[2]]
    zs = [p3[3],p4[3]]
    lines!(s,xs,ys,zs,color = (:blue, 0.5), linewidth = 5)

    xs = [p2[1],p3[1]]
    ys = [p2[2],p3[2]]
    zs = [p2[3],p3[3]]
    lines!(s,xs,ys,zs,color = (:blue, 0.5), linewidth = 5)

    #Labels vertices simplex
    text!(s, [p1, p2, p3, p4], color= :gray, text = string.("x", 1:4), align = [
        (:center, :bottom),
        (:center, :top),
        (:center, :top),
        (:right, :baseline),
    ])

    #Trajectories
    lines!(s, data_3D[:,1], data_3D[:,2], data_3D[:,3], color= :green)

    wait(display(s))
end

"""
    animation_3Dsimplex(data_3D) → mp4 file (optional: interactive interface)
`data_3D`: dataset transformed to 3D cartesian (Matrix{Float64})
Animate trajectories in the 3D Cartesian projection into the speficied 3D simplex via vertices p1, p2, p3, p4
"""
function animation_3Dsimplex(data_3D)

    points = Observable(Point3f[(data_3D[1,1], data_3D[1,2], data_3D[1,3])])

    #Trajectories
    f, ax, lin = lines(points, axis = (;type=Axis3, aspect = :equal, perspectiveness = 0.6), color= :green)

    #Aesthetics
    hidedecorations!(ax)
    hidespines!(ax)

    #Angle of visualisation
    ax.azimuth[] = deg2rad(35)

    #3D simplex
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

    # Make the video not so long with good point resolution
    frames = 1:25:(Int(round(size(data_3D,1)/5)))

    record(f, plotsdir("attractor_animation.mp4"), frames;
            framerate = 30, compression=1) do frame
        new_point = Point3f(data_3D[frame,1], data_3D[frame,2], data_3D[frame,3])
        points[] = push!(points[], new_point)
    end

    #Nice interactive 3D simplex (optional)
    wait(display(f))
end