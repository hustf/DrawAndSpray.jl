# DrawAndSpray.jl
Basic drawing and coverage accumulation on matrices.

## Why

[ImageDraw.jl](https://github.com/JuliaImages/ImageDraw.jl) can't spray.

This is a lightweight, light dependency repository for modifying raster images and numeric matrices. The original code is moved here from `BitmapMaps.jl` and `BitmapMapsExtras.jl`.

## For what

For indirect calls en masse, not a 'user-facing' library.

It draws fast, but is intended for adding light touches to images, like symbols, glyphs and streamlines. 

`DrawAndSpray.jl` has non-linear conversion from pixel coverage to opacity, useful when you want visual feedback on which pixels were visited many times, or when you want aliasing on edges of glyphs.

For development, `display_if_vscode` will show numeric matrices graphically.


## Installation
This package is registered in a separate registry, which holds related packages.

```julia
pkg> registry add https://github.com/hustf/M8

pkg> add DrawAndSpray

julia> using DrawAndSpray

julia> varinfo(DrawAndSpray)
  name                             size summary
  –––––––––––––––––––––––––– –––––––––– –––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
  DrawAndSpray               28.413 KiB Module
  LogMapper                    40 bytes UnionAll
  apply_color_by_coverage!      0 bytes apply_color_by_coverage! (generic function with 1 method)  
  color_neighbors!              0 bytes color_neighbors! (generic function with 1 method)
  draw_bidirectional_vector!    0 bytes draw_bidirectional_vector! (generic function with 1 method)
  draw_vector!                  0 bytes draw_vector! (generic function with 1 method)
  line!                         0 bytes line! (generic function with 2 methods)
  mark_at!                      0 bytes mark_at! (generic function with 3 methods)
  spray!                        0 bytes spray! (generic function with 1 method)
```

See the test directory for examples.

# Overview of what `DrawAndSpray`

See inline documentation for details.

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

### Luggage

`DrawAndSpray.display_if_vscode` will display images and also coverage matrices. Used in test files. Also see `test/common.jl`, which makes hashes.