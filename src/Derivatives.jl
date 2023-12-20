module Derivatives

export DerivativesData, DerivativesSelector, topderivative, ∂, ∂zeros

using Parameters

using FlexPoints

@with_kw mutable struct DerivativesData
    ∂1::Union{Vector{Float64},Nothing} = nothing
    ∂2::Union{Vector{Float64},Nothing} = nothing
    ∂3::Union{Vector{Float64},Nothing} = nothing
    ∂4::Union{Vector{Float64},Nothing} = nothing
end

@with_kw mutable struct DerivativesSelector
    ∂1::Bool = true
    ∂2::Bool = false
    ∂3::Bool = true
    ∂4::Bool = false
end

function topderivative(selector::DerivativesSelector)
    if selector.∂4
        4
    elseif selector.∂3
        3
    elseif selector.∂2
        2
    elseif selector.∂1
        1
    else
        0
    end
end


"""
Finds derivative of the sampled function.
Zeros specifies how many values of derivative will be set to zero at the
beginning and at the end of the function.
Derivative is computed from function values before and after sample point
divided by twice the step size.
"""
function ∂(data::Points2D, boundingzeros::Integer)::Vector{Float64}
    lastindex = datalen = length(data)
    @assert datalen >= 3
    @assert 1 <= boundingzeros <= datalen ÷ 2 - 1

    derivatives = zeros(datalen)

    for i in 1:(datalen-2boundingzeros)
        offest = i + boundingzeros
        Δx = x(data, offest + 1) - x(data, offest - 1)
        Δy = y(data, offest + 1) - y(data, offest - 1)
        derivatives[offest] = Δy / Δx
    end

    if datalen >= boundingzeros + 1
        for i in 1:boundingzeros
            derivatives[i] = derivatives[boundingzeros+1]
        end
    end

    for i in (lastindex-boundingzeros):(datalen)
        derivatives[i] = derivatives[lastindex-boundingzeros]
    end

    derivatives
end

"""
Finds derivative of the sampled function.
Derivative is computed from function values before and after sample point
divided by twice the step size. So, `outputsize = inputsize - 2`.
"""
function ∂(data::Points2D)::Vector{Float64}
    @assert datalen >= 3

    derivatives = zeros(datalen - 2)

    for i in 2:(datalen-1)
        offest = i
        Δx = x(data, offest + 1) - x(data, offest - 1)
        Δy = y(data, offest + 1) - y(data, offest - 1)
        derivatives[offest-1] = Δy / Δx
    end

    derivatives
end

function ∂zeros(derivatives::Vector{Float64})::Vector{Int}
    lastindex = derivativeslen = length(derivatives)
    mx = zeros(derivativeslen - 1)

    for i in 1:(lastindex-1)
        mx[i] = derivatives[i] * derivatives[i+1]
    end

    o3 = map(ix -> ix[1], filter(ix -> ix[2] <= 0.0, collect(enumerate(mx))))

    o3tail = if !isempty(o3)
        if first(o3) != 1
            newarray = [1]
            append!(newarray, o3)
            newarray
        else
            o3
        end
    else
        [1]
    end

    if last(o3tail) != lastindex
        push!(o3tail, lastindex)
    end

    o3tail
end

end