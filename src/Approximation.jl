module Approximation

export linapprox

using FlexPoints.Types

"Linear approximation"
function linapprox(data::Points2D, targetx::Real)
    @assert !isempty(data)
    @assert targetx >= data[1][1]
    @assert targetx <= data[end][1]

    for (i, point) in enumerate(data)
        x1, y1 = point
        if targetx == x1
            return y1
        elseif targetx < x1
            x2, y2 = data[i-1]
            slope = (y2 - y1) / (x2 - x1)
            intercept = y1 - slope * x1
            return slope * targetx + intercept
        end
    end
end

end