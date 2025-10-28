"""
    over(bkg::RGBA{T}, src::RGBA{T}) where {T<:Normed}

Straight-alpha source-over compositing of two pixels.
"""
@inline function over(bkg::RGBA{T}, src::RGBA{T}) where {T<:Normed}
    # Note, this was tested against ColorBlendModes.jl. However, 
    # we don't want that dependency any longer, not even in the testing 
    # environment.
    #=
    img = RGBA{N0f8}(0.502,0.502,0.502,0.502)
    source = RGBA{N0f8}(0.2,0.4,0.6,0.243)
    dest = blend(img, source) # RGBA{N0f8}(0.384,0.463,0.541,0.624)
    dest1 = over(img, source)
    @assert dest == dest1
    =#
    # Compute in Float32 for accuracy, then convert back
    s = RGBA{Float32}(src)
    d = RGBA{Float32}(bkg)
    αs = alpha(s)
    αd = alpha(d)
    αo = αs + αd * (1 - αs)
    if αo == 0f0
        return zero(RGBA{T})
    end
    r = (red(s)   * αs + red(d)   * αd * (1 - αs)) / αo
    g = (green(s) * αs + green(d) * αd * (1 - αs)) / αo
    b = (blue(s)  * αs + blue(d)  * αd * (1 - αs)) / αo
    return RGBA{T}(r, g, b, αo)
end
@inline function over(bkg::RGB{T}, src::RGBA{T}) where {T<:Normed}
    s = RGBA{Float32}(src)
    d = RGB{Float32}(bkg)
    a = alpha(s)                # 0..1
    # α_out = 1, so plain convex combination
    r = red(d)   * (1 - a) + red(s)   * a
    g = green(d) * (1 - a) + green(s) * a
    b = blue(d)  * (1 - a) + blue(s)  * a
    return RGB{T}(r, g, b)
end

"""
    over!(img, src)

In-place straight-alpha source-over compositing of two images.
"""
function over!(img, src)
    img .= over.(img, src)
    img
end