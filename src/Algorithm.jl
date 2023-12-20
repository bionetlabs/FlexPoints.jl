module Algorithm

export flexpoints

using DataStructures

using FlexPoints

# Variable derivatives indicates which derivatives should be use
# e.g. if `derivatives = (true, false, true, false)` 
# then the first and the third derivative will be used.
function flexpoints(
    data::Points2D,
    dselector::DerivativesSelector=DerivativesSelector()
)::Vector{Int}
    @assert !isempty(data)
    requiredlen = length(data) ÷ 2 - 1
    maxderivative = topderivative(dselector)
    maxderivative == 0 && error("at least one derivative should be used")
    @assert requiredlen >= maxderivative

    datax = map(point -> x(point), data)

    ∂1data = maxderivative >= 1 && ∂(data, 1)
    ∂2data = maxderivative >= 2 && ∂(collect(zip(datax, ∂1data)), 2)
    ∂3data = maxderivative >= 3 && ∂(collect(zip(datax, ∂2data)), 3)
    ∂4data = maxderivative >= 4 && ∂(collect(zip(datax, ∂3data)), 4)
    derivatives = DerivativesData(∂1data, ∂2data, ∂3data, ∂4data)

    output = SortedSet{Int}()
    if dselector.∂1
        union!(output, ∂zeros(∂1data))
    end
    if dselector.∂2
        union!(output, ∂zeros(∂2data))
    end
    if dselector.∂3
        union!(output, ∂zeros(∂3data))
    end
    if dselector.∂4
        union!(output, ∂zeros(∂4data))
    end

    collect(output)
end

end