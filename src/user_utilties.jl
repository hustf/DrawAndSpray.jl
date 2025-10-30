"""
    display_if_vscode(M)

 Stretch gray colors from black to white (if M allows).

    display_if_vscode(M::Matrix{T}) where T <: Colorant

Use instead of 'display' to avoid showing a text representation.
"""
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
function display_if_vscode(M::Matrix{T}) where T <: Colorant
    if isinteractive()
        if get(ENV, "TERM_PROGRAM", "") == "vscode"
            # Display
            display(M)
        end
    end
end
