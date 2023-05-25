module Types

export Points2D

Points2D = Vector{Tuple{T, T}} where T <: Real

end