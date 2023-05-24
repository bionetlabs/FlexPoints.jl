module FlexPoints

using Reexport

include("Algorithm.jl")
include("Approximation.jl")
include("GUI.jl")
include("Measures.jl")

@reexport using FlexPoints.Algorithm
@reexport using FlexPoints.Approximation
@reexport using FlexPoints.GUI
@reexport using FlexPoints.Measures

end
