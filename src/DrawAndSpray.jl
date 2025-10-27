module DrawAndSpray

import ImageCore
using ImageCore: Gray, RGB, RGBA, XYZ, XYZA
using ImageCore: N0f8
using ImageCore: scaleminmax, colorview
# Note that ColorBlendModes is not well maintained and
# causes downgrades for ColorTypes.jl and ColorVectorSpace.jl.
#  TODO Find a replacement for this!
import ColorBlendModes
using ColorBlendModes: blend 

include("mark.jl")
include("spray.jl")
include("user_utilties.jl")
end