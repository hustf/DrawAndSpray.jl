module DrawAndSpray

import ImageCore
using ImageCore: Gray, RGB, RGBA, XYZ, XYZA
using ImageCore: N0f8, Normed, alpha, red, green, blue
using ImageCore: scaleminmax, colorview

export mark_at!, line!, color_neighbors!
export draw_vector!, draw_bidirectional_vector!, spray_along_nested_indices! 
export spray!, LogMapper, apply_color_by_coverage!

"Fixed taper for vector glyphs, including bidirectional vectors"
const VECTOR_REL_HALFWIDTH = 0.075

include("mark.jl")
include("blend.jl")
include("spray.jl")
include("spray_shapes.jl")
include("user_utilties.jl")
end