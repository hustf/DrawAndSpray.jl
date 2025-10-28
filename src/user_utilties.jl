function display_if_vscode(M)
    if isinteractive()
        if get(ENV, "TERM_PROGRAM", "") == "vscode"
            # Stretch gray colors from black to white
            foo = scaleminmax(extrema(M)...)
            # Display
            display(colorview(Gray, foo.(M)))
        end
    end
end
function display_if_vscode(M::Matrix{T}) where T <: Union{RGBA{N0f8}, RGB{N0f8}, XYZ{Float32}, XYZA{Float32}, RGB{Float32}}
    if isinteractive()
        if get(ENV, "TERM_PROGRAM", "") == "vscode"
            # Display
            display(M)
        end
    else
        @show isinteractive() # Temp
    end
end
