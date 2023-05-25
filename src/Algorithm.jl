module Algorithm

export ∂ 

using FlexPoints

"""
Finds derivative of the sampled function.
Zeros specifies how many values of derivative will be set to zero at the
beginning and at the end of the function.
Derivative is computed from function values before and after sample point
divided by twice the step size.
"""
function ∂(data::Points2D, boundingzeros::Integer)::Vector{Float64}
    endindex = datalen = length(data)
    @assert datalen >= 3
    @assert 1 <= boundingzeros <= datalen ÷ 2 - 1

    derivatives = zeros(datalen)

    for i in 1:(datalen - 2boundingzeros)
        offest = i + boundingzeros
        δx = x(data, offest + 1) - x(data, offest - 1)
        δy = y(data, offest + 1) - y(data, offest - 1)
        derivatives[offest] = δy / δx
    end

    if datalen >= boundingzeros + 1
        for i in 1:boundingzeros
            derivatives[i] = derivatives[boundingzeros + 1]
        end
    end

    for i in (endindex - boundingzeros):(datalen)
        derivatives[i] = derivatives[endindex - boundingzeros]
    end

    derivatives
end

"""
Finds derivative of the sampled function.
Derivative is computed from function values before and after sample point
divided by twice the step size. So, `outputsize = inputsize - 2`.
"""
function ∂(data::Points2D)::Vector{Float64}
    endindex = datalen = length(data)
    @assert datalen >= 3

    derivatives = zeros(datalen - 2)

    for i in 2:(datalen - 1)
        offest = i
        δx = x(data, offest + 1) - x(data, offest - 1)
        δy = y(data, offest + 1) - y(data, offest - 1)
        derivatives[offest - 1] = δy / δx
    end

    derivatives
end

end