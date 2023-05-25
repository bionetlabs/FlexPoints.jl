module Types

export Points2D

# First element of the tuple is a value of independent variable
# Second element of the tuple is a value of dependent variable
Points2D = Vector{Tuple{T, T}} where T <: Real

end