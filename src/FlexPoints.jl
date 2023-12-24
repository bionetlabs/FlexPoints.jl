module FlexPoints

using Reexport

include("Types.jl")
@reexport using FlexPoints.Types

include("Data.jl")
@reexport using FlexPoints.Data

include("Approximation.jl")
@reexport using FlexPoints.Approximation

include("Derivatives.jl")
@reexport using FlexPoints.Derivatives

include("Filters.jl")
@reexport using FlexPoints.Filters

include("Algorithm.jl")
@reexport using FlexPoints.Algorithm

include("Measures.jl")
@reexport using FlexPoints.Measures

include("Benchmarks.jl")
@reexport using FlexPoints.Benchmarks

include("GUI/GUI.jl")
@reexport using FlexPoints.GUI

end
