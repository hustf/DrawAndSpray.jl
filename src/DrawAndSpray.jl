module DrawAndSpray

import ImageCore
using ImageCore: Gray, RGB, RGBA, Colorant, Oklch
using ImageCore: N0f8, Normed, alpha, red, green, blue
using ImageCore: scaleminmax, colorview
# Luggage
import PrecompileTools
using PrecompileTools: @setup_workload, @compile_workload
using ImageShow # This enables display of (all) bitmaps in VSCode and IJulia. Not strictly required.

export mark_at!, line!, color_neighbors!
export draw_vector!, draw_bidirectional_vector!
export spray_along_nested_indices!, spray!
export LogMapper, apply_color_by_coverage!
export over!, chromaticity_over!, blend_multiply!, blend_lighten!

"Fixed taper for vector glyphs, including bidirectional vectors"
const VECTOR_REL_HALFWIDTH = 0.075

include("mark.jl")
include("blend.jl")
include("spray.jl")
include("spray_shapes.jl")
include("user_utilties.jl")

@setup_workload begin
    # Putting some things in `@setup_workload` instead of `@compile_workload` can reduce the size of the
    # precompile file and potentially make loading faster.
    # (too much work for me)
    @compile_workload begin
        # all calls in this block will be precompiled, regardless of whether
        # they belong to your package or not (on Julia 1.8 and higher)
        #
        # From t_mark.jl:
        w, h = 100, 100
        bw = zeros(Gray{Bool}, h, w)
        x1, y1 = 5, 5
        x2, y2 = 20, 50
        pis = [CartesianIndex((y1, x1)), CartesianIndex((y2, x2))]
        mark_at!(bw, pis)
        mark_at!(bw, pis, 7, "in_square")
        line!(bw, pis[1], pis[2])
        display_if_vscode(bw)
        # From t_spray_shapes.jl
        placements = [CartesianIndex(50, 50), CartesianIndex(25, 25)]
        values = [[50.0, 50.0], [20.0, -20.0]]
        cov = zeros(Float32, w, h)
        for (pt, v) in zip(placements, values)
            draw_bidirectional_vector!(cov, pt, v, 0.7f0)
            draw_vector!(cov, pt, Int64(v[1]), Int64(v[2]), 0.7f0)
        end
        display_if_vscode(cov)
        vpts = [CartesianIndex(20 + i, 20 + i) for i = 0:50]
        npts = [vpts, vpts .+ CartesianIndex(10, 0)]
        spray_along_nested_indices!(cov, npts, 1.5f0, 1.0f0) 
        # Inspired by _spray
        cov = rand(Float32, w, h)
        img = zeros(RGBA{N0f8}, size(cov))
        apply_color_by_coverage!(img, cov, RGB{N0f8}(1,1,1))
        # From t_blend
        img =  [RGB{N0f8}(0.1i, 0.1i, 0.1i) for i in 1:10, j in 1:10]
        imgA = [RGBA{N0f8}(0.1i, 0.1i, 0.1i, 0.1i) for i in 1:10, j in 1:10]
        src =  [RGB{N0f8}(0.1j, (1 - 0.1j), 0.1j) for i in 1:10, j in 1:10]
        src[3,3] = RGB{N0f8}(0, 0, 0)
        srcA = [RGBA{N0f8}(0.1j, (1 - 0.1j), 0.1j, 0.1j) for i in 1:10, j in 1:10]
        for (bkg, source) in [(img, srcA) (imgA, srcA)]
            b = copy(bkg)
            over!(b, source)
        end
        for (bkg, source) in [(img, src) (img, srcA) (imgA, srcA)]
            b = copy(bkg)
            chromaticity_over!(b, source)
        end
        for (bkg, source) in [(img, src) (img, srcA) (imgA, srcA)]
            b = copy(bkg)
            blend_multiply!(b, source)
        end
        for (bkg, source) in [(Gray{Bool}.(rand(Bool, 10,10)), Gray{Bool}.(rand(Bool, 10,10))) (Gray{N0f8}.(rand(N0f8, 10,10)), Gray{N0f8}.(rand(N0f8, 10,10)))]
            b = copy(bkg)
            blend_lighten!(b, source)
        end
    end
end
end # module