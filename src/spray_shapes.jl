# Drawing functionality for partial coverage
#
# Contains 
# `draw_vector!`
# `draw_bidirectional_vector!`
# `spray_along_indices!` 
# `spray_along_nested_indices!` 


"""
    draw_vector!(cov::Matrix{Float32}, A::CartesianIndex{2}, Δi::Int, Δj::Int, strength::Float32)

Draws a line from A to B in the given coverage matrix. Edges are blurry. At A, maximum radius is 

    `VECTOR_REL_HALFWIDTH` * `l`

where `l` = √(Δi²+Δj²). 

See LogMapper for conversion of `cov` to an image.
"""
function draw_vector!(cov::Matrix{Float32}, A::CartesianIndex{2}, Δi::Int, Δj::Int, strength::Float32)
    #
    i1, j1 = Tuple(A)
    li = abs(Δi)
    lj = abs(Δj)
    si = sign(Δi)
    sj = sign(Δj)
    # Get all valid indices for the image
    R = CartesianIndices(cov)
    # Length
    l = hypot(Δi, Δj)
    # Max radius
    rA = Float32(max(0.5, VECTOR_REL_HALFWIDTH * l))
    # Min radius
    rB = min(0.5f0, rA)
    # Zero vector
    if Δi == 0 && Δj == 0
        spray!(cov,
                CartesianIndex(i1, j1),
                rB,
                strength)
        return cov
    end
    # Non-zero vector
    if li > lj
        # Radius as a function of vertical position
        ρ = let rA = rA, rB = rB, nl = li
            i -> rA + (i - 1) * (rB - rA) / nl
        end
        err = li ÷ 2
        for i in 1:(li + 1)
            r = ρ(i)
            if isnan(r)
                @show  Δi  Δj rA rB li lj r
                throw("ah NaN")
            end 
            spray!(cov,
                CartesianIndex(i1, j1),
                r,
                strength)
            err -= lj
            if err < 0
                j1 += sj
                err += li
            end
            i1 += si
        end
    else
        # Radius as a function of horizontal position
        ρ = let rA = rA, rB = rB, nl = lj
            i -> rA + (i - 1) * (rB - rA) / nl
        end
        err = lj ÷ 2
        for i in 1:(lj + 1)
            r = ρ(i)
            if isnan(r)
                @show  Δi  Δj rA rB li lj r
                throw("ah, what happened?")
            end 
            spray!(cov,
                CartesianIndex(i1, j1),
                r,
                strength)
            err -= li
            if err < 0
                i1 += si
                err += lj
            end
            j1 += sj
        end
    end
    cov
end

"""
    draw_bidirectional_vector!(cov, p, v::AbstractVector, strength::Float32)

Opposing vectors. Outwards pointing means positive, inwards pointing means negative,
as is customary for e.g. tensile / compressive force.

- `v`[1:2] specifies both direction and sign and is given in an x-y up coordinate system. 

`v` points in direction `θ` from x around z in an right-handed coordinate system. Then:

    θ ∈ [0, π>:  Positive sign.   
    θ ∈ [π, 2π>: Negative sign.   
"""
function draw_bidirectional_vector!(cov, p, v::AbstractVector, strength::Float32)
    Δj = Int(round(v[1]))
    Δi = Int(round(v[2]))
    if is_bidirec_vect_positive(v)
        # First or second quadrant. Positive.
        draw_vector!(cov, p, -Δi, Δj, strength)
        draw_vector!(cov, p, Δi, -Δj, strength)
    else
        # Third or fourth quadrant. Negative.
        draw_vector!(cov, p + CartesianIndex(-Δi, Δj), Δi, -Δj, strength)
        draw_vector!(cov, p + CartesianIndex(Δi, -Δj), -Δi, Δj, strength)
    end
end

"""
    spray_along_nested_indices(cov, spts, r::Float32, strength::Float32) 

`spts` is a nested array of CartesianIndex{2}. The outer is a collection of points in each streamline.    

The shape and ordering of streamlines do not currently matter,  but an extension might be
used to convey some property.
"""
function spray_along_nested_indices(cov, spts, r::Float32, strength::Float32) 
    @assert eltype(spts) <: Vector
    for streamline in spts
        spray_along_indices(cov, streamline, r, strength)
    end
    cov
end

"""
    spray_along_nested_indices(cov, spts::Vector{CartesianIndex{2}}, r::Float32, strength::Float32)
"""
function spray_along_indices(cov, spts::Vector{CartesianIndex{2}}, r::Float32, strength::Float32)
    for pt in spts
        spray!(cov, pt,  r, strength)
    end
    cov
end

