import ColorBlendModes
using ColorBlendModes: blend
using ImageCore
using DrawAndSpray
using DrawAndSpray: LogMapper


col = RGB{N0f8}(0.2,0.4, 0.6)
mapper = LogMapper()
f = x -> RGBA{N0f8}(col.r, col.g, col.b, mapper(x))
cov = 0.8
f(cov) |> println

# First, let's see what happens when img is without alpha.
# Spoiler: source is copied directly, alpha of source is ignored.
img = RGB{N0f8}(0.1,0.1, 0.1)
img1 = blend(img, f(cov))
img1 |> println
backdrop = img
dest = img
using ColorBlendModes: BlendNormal, _blend_cc, CompositeSourceOver, _blend
mode = BlendNormal
# BlendNormal: The destination color is always the source color.
opacity=nothing
op=CompositeSourceOver
source = convert(typeof(dest), f(cov))
@edit _blend_cc(mode, dest, source, opacity, op)
@edit _blend(mode, dest, source)

# Second, img, source, has alpha
img = RGBA{N0f8}(0.5,0.5,0.5,0.5)
source = f(cov)
source |> println
img1 = blend(img, source) |> println
using ColorBlendModes: _blend_c, _blend_tc, color_type, mix_alpha, alpha
@edit _blend_c(mode, img, source, opacity, op)
alpha(source)
mix_alpha(nothing, alpha(source), op) # It's a multiplication...??
img1 = blend(img, f(cov))

# Just figure the formula by inspection...
source = RGBA{N0f8}(0.2,0.4,0.6,0.8)
background = RGBA{N0f8}(0.5,0.5,0.5,0.5)
dest = blend(img, source)

# Checking
function myblend(αb::T, αs::T; Fa = 1, Fb = 1 - αs) where T
    αs * Fa + αb * Fb
end
@assert N0f8(myblend(background.alpha, source.alpha)) == N0f8(dest.alpha)

function mycolblend(αb::T, αs::T, Cb::T, Cs::T; Fa = 1, Fb = 1 - αs) where T
    αs * Fa * Cs + αb * Fb * Cb
end

dest.r

# Ok, this formula is not what is used:
mycolblend(background.alpha, source.alpha, background.r, source.r)
N0f8(mycolblend(background.alpha, source.alpha, background.r, source.r))


# Let's use the blending section https://drafts.fxtf.org/compositing-1/#blending

# Section 10.1.1 normal
B(Cb, Cs) = Cs

function colblend(αb::T, αs::T, Cb::T, Cs::T; Fa = 1, Fb = 1 - αs) where T
    #αs * Fa * Cs + αb * Fb * Cb
    (1 - αb) * Cs + αb * Fb * B(Cb, Cs)
end

colblend(background.alpha, source.alpha, background.r, source.r)
N0f8(colblend(background.alpha, source.alpha, background.r, source.r))
dest.r
source.r
background.r
myblend(background.alpha, source.alpha)

0.900 * source.r + (1 - 0.900) * dest.r


# Dive deeper
using ColorBlendModes: color, color_type, mapch, _w, mapc, _comp
c1 = img
c2 = source
co2 = color(c2)
cc2 = convert(color_type(c1), color(c2))
opacity = nothing
mix_alpha(opacity, alpha(c2))
op
opacity = alpha(c2)
ma = mix_alpha(opacity, alpha(c2))

@assert _blend_tc(mode, c1, co1, opacity, op) == img1
@enter _blend_tc(mode, c1, cc2, opacity, op)
_blend_tc(mode, c1, cc2, opacity, op)

foo = (v1, v2) -> _w(v1, v2, alpha(c1))
cm = mapch(foo, cc2, _blend(mode, color(c1), cc2))
 
# This is the color combination
cm = mapc(foo, cc2, _blend(mode, color(c1), cc2))
typeof(c1)(cm, opacity)
c1
opacity
_comp(op, c1, typeof(c1)(cm, opacity))
@edit _comp(op, c1, typeof(c1)(cm, opacity))

dest

# This is the compositing operation
function extractmethod(c1, c2)
    k1 = mul(alpha(c1), _n(alpha(c2)))
    k2 = alpha(c2)
    a = k1 + k2
    k1a = a == zero(a) ? a : k1 / a
    k2a = a == zero(a) ? a : oneunit(a) - k1a
    faa = (v1, v2) -> _w(v1, k1a, v2, k2a)
    mapca(faa, a, c1, c2)
end

# Added function `over` to `blend.jl`

dest = blend(img, source)
dest1 = over(img, source)
@assert dest == dest1