# Markers 
using Test
import DrawAndSpray
using DrawAndSpray: apply_color_by_coverage!, RGB, RGBA, N0f8
using DrawAndSpray: over!, chromaticity_over!, over, chromaticity_over
using DrawAndSpray: blend_multiply, blend_multiply!


!@isdefined(hash_image) && include("common.jl")

@testset "Apply color by coverage. Alpha and not alpha" begin
    # The values won't be tested and could vary between tests.
    img = rand(RGB{N0f8}, 10, 10)
    imgA = rand(RGBA{N0f8}, 10, 10)
    cov = rand(Float32, 10, 10)
    col = RGB{N0f8}(0.1, 0.2, 0.3)
    colA = RGBA{N0f8}(0.1, 0.2, 0.3, 0.4)
    @test apply_color_by_coverage!(img, cov, col) isa Matrix{RGB{N0f8}}
    @test_throws MethodError apply_color_by_coverage!(img, cov, colA)
    @test apply_color_by_coverage!(imgA, cov, col) isa Matrix{RGBA{N0f8}}
end

@testset "Composite blend modes" begin
    vhash = ["04932c274140965b5329ea31947e332407183bb6", "bf861405e58424836768656e484ec2b79b36717c", "ca9047d0f74e2cf7aae33a7509153eb0e68f73ef", "ba308599a33eb5bbd9f4be35d918277c58135f8a", "a7b0fcc4348b2a68c43c90aeaa671569f6ec55f2", "9703d0de433769b63decf08b126f74602b9e1541", "45653cfae11acdba965ba305060540e5619543c1", "fb768368d204f4658c357062229aba638612e5c3"]
    COUNT[] = 0
    img =  [RGB{N0f8}(0.1i, 0.1i, 0.1i) for i in 1:10, j in 1:10]
    imgA = [RGBA{N0f8}(0.1i, 0.1i, 0.1i, 0.1i) for i in 1:10, j in 1:10]
    src =  [RGB{N0f8}(0.1j, (1 - 0.1j), 0.1j) for i in 1:10, j in 1:10]
    src[3,3] = RGB{N0f8}(0,0,0)
    srcA = [RGBA{N0f8}(0.1j, (1 - 0.1j), 0.1j, 0.1j) for i in 1:10, j in 1:10]
    for (bkg, source) in [(img, srcA) (imgA, srcA)]
        b = copy(bkg)
        over!(b, source)
        @test is_hash_stored(b, vhash)
    end
    for (bkg, source) in [(img, src) (img, srcA) (imgA, srcA)]
        b = copy(bkg)
        chromaticity_over!(b, source)
        @test is_hash_stored(b, vhash)
    end
    for (bkg, source) in [(img, src) (img, srcA) (imgA, srcA)]
        b = copy(bkg)
        blend_multiply!(b, source)
        @test is_hash_stored(b, vhash)
    end
end