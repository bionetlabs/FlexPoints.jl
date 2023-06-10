module Algorithm

export ∂, flexpoints

using DataStructures

using FlexPoints

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

    for i in (lastindex - boundingzeros):(datalen)
        derivatives[i] = derivatives[lastindex - boundingzeros]
    end

    derivatives
end

"""
Finds derivative of the sampled function.
Derivative is computed from function values before and after sample point
divided by twice the step size. So, `outputsize = inputsize - 2`.
"""
function ∂(data::Points2D)::Vector{Float64}
    lastindex = datalen = length(data)
    @assert datalen >= 3

    derivatives = zeros(datalen - 2)

    for i in 2:(datalen - 1)
        offest = i
        Δx = x(data, offest + 1) - x(data, offest - 1)
        Δy = y(data, offest + 1) - y(data, offest - 1)
        derivatives[offest - 1] = Δy / Δx
    end

    derivatives
end

function ∂negative(derivatives::Vector{Float64})::Vector{Int}
    lastindex = derivativeslen = length(derivatives)
    mx = zeros(derivativeslen)

    for i in 1:(lastindex - 1)
        mx[i + 1] = derivatives[i] * derivatives[i + 1]
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

# Variable derivatives indicates which derivatives should be use
# e.g. if `derivatives = (true, false, true, false)` 
# then the first and the third derivative will be used.
function flexpoints(
    data::Points2D, derivatives=(true, false, true, false)
)::Vector{Int}
    @assert !isempty(data)
    requiredlen = length(data) ÷ 2 - 1
    maxderivative = if derivatives[4]
        4
    elseif derivatives[3]
        3
    elseif derivatives[2]
        2
    elseif derivatives[1]
        1
    else
        error("at least one derivative should be used")
    end
    @assert requiredlen >= maxderivative

    datax = map(point -> x(point), data)

    ∂first = maxderivative >= 1 && ∂(data, 1)
    ∂second = maxderivative >= 2 && ∂(collect(zip(datax, ∂first)), 2)
    ∂third = maxderivative >= 3 && ∂(collect(zip(datax, ∂second)), 3)
    ∂fourth = maxderivative >= 4 && ∂(collect(zip(datax, ∂third)), 4)

    output = SortedSet{Int}()
    if derivatives[1]
        union!(output, ∂negative(∂first))
    elseif derivatives[2]
        union!(output, ∂negative(∂second))
    elseif derivatives[3]
        union!(output, ∂negative(∂third))
    elseif derivatives[4]
        union!(output, ∂negative(∂fourth))
    end

    collect(output)
end

end