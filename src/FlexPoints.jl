module FlexPoints

using Reexport

include("Types.jl")
@reexport using FlexPoints.Types

include("Algorithm.jl")
@reexport using FlexPoints.Algorithm

include("Approximation.jl")
@reexport using FlexPoints.Approximation

include("Measures.jl")
@reexport using FlexPoints.Measures

include("GUI.jl")
@reexport using FlexPoints.GUI

end
