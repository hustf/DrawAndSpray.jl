# Markers 
using Test
import DrawAndSpray
using DrawAndSpray: apply_color_by_coverage!, RGB, RGBA, N0f8

@testset "Alpha and not alpha" begin
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

