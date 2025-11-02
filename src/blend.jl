"""
    over(bkg::RGBA{T}, src::RGBA{T}) where {T<:Normed}

Straight-alpha source-over compositing of two pixels. Replaces:

  `dest = ColorBlendModes.blend(img, source)`
"""
@inline function over(bkg::RGBA{T}, src::RGBA{T}) where {T<:Normed}
    # 
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

In-place straight-alpha source-over compositing of two images. `src` must have an alpha channel.
"""
function over!(img, src)
    img .= over.(img, src)
    img
end

"""
    chromaticity_over(bkg::RGB{T}, src::RGB{T}) where {T<:Normed}
    chromaticity_over(bkg::RGB{T}, src::RGBA{T}) where {T<:Normed}
    chromaticity_over(bkg::RGBA{T}, src::RGBA{T}) where {T<:Normed}

Take **chromaticity** (hue `h`, chroma `c`) from `src` in the
**Oklab** space while preserving `bkg`'s **lightness** `L`. Alpha compositing is
**source-over** (straight alpha).
"""
@inline function chromaticity_over(bkg::RGB{T}, src::RGB{T}) where {T<:Normed}
    # 
    # Compute in Float32 for accuracy, then convert back
    s = convert(Oklch{Float32}, src)
    d = convert(Oklch{Float32}, bkg)
    if isnan(s.h) || s.c == 0f0       # achromatic source: nothing to tint with
        return bkg
    end
    out = Oklch{Float32}(d.l, s.c, s.h)
    convert(RGB{T}, convert(RGB{Float32}, out))  # clamp via convert
end
@inline function chromaticity_over(bkg::RGB{T}, src::RGBA{T}) where {T<:Normed}
    a = float(alpha(src))
    h = chromaticity_over(bkg, RGB{T}(src))
    RGB{T}(
            (1 - a) * red(bkg)   + a * red(h),
            (1 - a) * green(bkg) + a * green(h),
            (1 - a) * blue(bkg)  + a * blue(h)
        )
end
@inline function chromaticity_over(bkg::RGBA{T}, src::RGBA{T}) where {T<:Normed}
    a_s = float(alpha(src))
    a_d = float(alpha(bkg))
    # First compute the hue-swapped color “as if” fully applied to bkg.rgb:
    mixed = chromaticity_over(RGB{T}(bkg), RGB{T}(src))
    # Then ordinary source-over on channels:
    r = (1 - a_s) * red(bkg)   + a_s * red(mixed)
    g = (1 - a_s) * green(bkg) + a_s * green(mixed)
    b = (1 - a_s) * blue(bkg)  + a_s * blue(mixed)
    a = a_s + a_d * (1 - a_s)
    RGBA{T}(r, g, b, a)
end

"""
    chromaticity_over!(img, src)

Replace `img` colors with **chromaticity** (hue `h`, chroma `c`) from `src` in the
**Oklab** colour space while preserving `img`'s **lightness** `L`. Alpha compositing is
**source-over** (straight alpha).
"""
function chromaticity_over!(img, src)
    img .= chromaticity_over.(img, src)
    img
end






