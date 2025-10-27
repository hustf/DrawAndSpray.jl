# DrawAndSpray.jl
Basic drawing and coverage accumulation on matrices.


## Why

A lightweight, light dependency repository for modifying raster images and numeric matrices.  

The original code is moved here from `BitmapMaps.jl` and `BitmapMapsExtras.jl`.

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
```

See the test directory for examples.