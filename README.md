# DrawAndSpray.jl
Basic drawing and coverage accumulation on matrices.

## Why

* [ImageDraw.jl](https://github.com/JuliaImages/ImageDraw.jl) can't spray.
* [ColorBlend.jl](https://github.com/kimikage/ColorBlendModes.jl/tree/master) is currently not compatible with the latest `ColorTypes.jl`.

## What

This is a lightweight, light dependency repository for modifying raster images and numeric matrices. It is not a 'user-facing' drawing library. The original code is migrated here from `BitmapMaps.jl` and `BitmapMapsExtras.jl`.

1) It's force principal is spraying: non-linear conversion from pixel coverage to opacity, useful when you want visual feedback on which pixels were visited many times, or when you want aliasing on edges of glyphs. With this method, you have millions of nuances, great for visual analysis.

2) It can also draw 'black-and white' lines, squares and other shapes.

3) It has a small, useful selection of image compositing modes.


`DrawAndSpray.jl` draws fast, but is intended for adding light touches to images, like symbols, glyphs and streamlines. 

## Installation
This package is registered in a separate registry, which holds related packages.

```julia
pkg> registry add https://github.com/hustf/M8

pkg> add DrawAndSpray

julia> using DrawAndSpray
Precompiling DrawAndSpray finished.
  1 dependency successfully precompiled in 5 seconds. 46 already precompiled.

julia> varinfo(DrawAndSpray)
  name                              size summary
  ––––––––––––––––––––––––––– –––––––––– ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
  DrawAndSpray                42.815 KiB Module
  LogMapper                     40 bytes UnionAll
  apply_color_by_coverage!       0 bytes apply_color_by_coverage! (generic function with 1 method)
  blend_lighten!                 0 bytes blend_lighten! (generic function with 1 method)
  blend_multiply!                0 bytes blend_multiply! (generic function with 1 method)
  chromaticity_over!             0 bytes chromaticity_over! (generic function with 1 method)
  color_neighbors!               0 bytes color_neighbors! (generic function with 1 method)
  draw_bidirectional_vector!     0 bytes draw_bidirectional_vector! (generic function with 1 method)
  draw_vector!                   0 bytes draw_vector! (generic function with 1 method)
  line!                          0 bytes line! (generic function with 2 methods)
  mark_at!                       0 bytes mark_at! (generic function with 3 methods)
  over!                          0 bytes over! (generic function with 1 method)
  spray!                         0 bytes spray! (generic function with 1 method)
  spray_along_nested_indices!    0 bytes spray_along_nested_indices! (generic function with 1 method)
```

# Overview

See inline documentation for details, /test for examples.

### Single-color

- `mark_at!` has a default size of 3 pixels and a default shape "`on_square`". It can also do:

  * "`on_square`"
  * "`on_triangle`"
  * "`on_circle`"
  * "`in_square`"
  * "`in_triangle`"
  * "`in_circle`"
  * "`on_cross`"
  * "`on_xcross`"
  * "`on_hline`"
  * "`on_vline`"

- `line!` uses Bresenham's algorithm and comes with a thickness parameter

- `color_neighbors!` marks all pixels nearby, and comes with a mask.

### How color is applied gradually

- `spray!` adds linearly to a coverage matrix, the same size as your image.
- `apply_color_by_coverage!` converts coverage to one transparent color and overlays it over your image
- `LogMapper` is an argument to `apply_color_by_coverage!`. It can be fine tuned to operate more like pencil strokes, spray, or paint with differing thixotropy.
- `apply_color_by_any_coverage!`

### Gradually applied color functions

These are single-color, usually edge-aliased shapes. They all build on `spray`.
When these don't fit, they still make nice templates.

- `draw_vector!` Cone-like
- `draw_bidirectional_vector!`
- `spray_along_indices!` 
- `spray_along_nested_indices!` 

### Composite blending

These function are defined, but the input types (RGB, RGBA, Gray) vary. See inline docs.

- `over!` can do alpha compositing (Porter-Duff over).
- `chromaticity_over!` takes hue and chroma from one image and lightness from another.
- `blend_multiply!` multiplies color channels separately. 
- `blend_lighten!` selects the lightest channel from two images. Nice for overlaying black-and-white drawings.

### Luggage

`ImageShow.jl` is used. This will extend VSCode and IJulia's functions for displaying matrices graphically.

`DrawAndSpray.display_if_vscode` will try to display graphically if possible. Also see `test/common.jl`, which makes hashes.