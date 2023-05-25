module FlexPoints

using Reexport

include("Types.jl")
include("Algorithm.jl")
include("Approximation.jl")
include("GUI.jl")
include("Measures.jl")

@reexport using FlexPoints.Algorithm
@reexport using FlexPoints.Approximation
@reexport using FlexPoints.GUI
@reexport using FlexPoints.Measures
@reexport using FlexPoints.Types

end
