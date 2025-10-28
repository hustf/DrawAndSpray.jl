import Pkg
if ! haskey(Pkg.project().dependencies, "SHA") 
    @warn "For interactive tests: Use a test
    environment outside of this package's /src/ and /test/ folder. 
    The interactive test environment should `Pkg|> develop` DrawAndSpray, 
    and `Pkg|> add` test dependencies listed in `test/Project.toml.
    In VSCode, manually change the environment to that environment folder."
end
using Test

@testset "DrawAndSpray" begin
@testset "markers" begin
    include("t_mark.jl")
end
@testset "spray" begin
    include("t_spray.jl")
end
@testset "spray shapes" begin
    include("t_spray_shapes.jl")
end

end