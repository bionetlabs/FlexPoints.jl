module Measures

export compfactor

using FlexPoints.Types
   
function compfactor(inputsize::Integer, outputsize::Integer)::Float64
    @assert inputsize > 0
    @assert outputsize > 0
    convert(Float64, inputsize / outputsize)
end

function compfactor(data::Points2D, samples::Points2D)
    compfactor(length(data), length(samples))
end

end