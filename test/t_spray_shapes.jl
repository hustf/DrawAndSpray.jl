using Test
using DrawAndSpray

!@isdefined(hash_image) && include("common.jl")

@testset "draw and display vec2 and bidirectional vectors" begin
    placements = [CartesianIndex(50, 50), CartesianIndex(25, 25)]
    values = [[50.0, 50.0], [20.0, -20.0]]
    @testset "draw_bidirectional_vector!" begin
        cov = zeros(Float32, 100, 100)
        for (pt, v) in zip(placements, values)
            draw_bidirectional_vector!(cov, pt, v, 0.7f0)
        end
        display_if_vscode(cov)
        @test sum(cov) == 6081.7f0 
    end
    @testset "draw_vector!" begin
        cov = zeros(Float32, 100, 100)
        for (pt, v) in zip(placements, values)
            draw_vector!(cov, pt, Int64(v[1]), Int64(v[2]), 0.7f0)
        end
        display_if_vscode(cov)
        @test sum(cov) == 3040.85f0
    end
end

@testset "spray_along_nested_indices!" begin
    vpts = [CartesianIndex(20 + i, 20 + i) for i = 0:50]
    npts = [vpts, vpts .+ CartesianIndex(10, 0)]
    cov = zeros(Float32, 100, 100)
    spray_along_nested_indices!(cov, npts, 1.5f0, 1.0f0) 
    display_if_vscode(cov)
    @test sum(cov) == 1207.0001f0
    @test extrema(cov) == (0.0f0, 3.9444447f0)
end
