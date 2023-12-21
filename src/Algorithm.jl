module Algorithm

export flexpoints

using FlexPoints

# Variable derivatives indicates which derivatives should be use
# e.g. if `derivatives = (true, false, true, false)` 
# then the first and the third derivative will be used.
function flexpoints(
    data::Points2D,
    dselector::DerivativesSelector,
    mfilter_params::MFilterParameters
)::Vector{Int}
    @assert !isempty(data)
    requiredlen = length(data) ÷ 2 - 1
    maxderivative = topderivative(dselector)
    maxderivative == 0 && error("at least one derivative should be used")
    @assert requiredlen >= maxderivative

    datax = map(point -> x(point), data)

    ∂1data = maxderivative >= 1 ? ∂(data, 1) : nothing
    ∂2data = maxderivative >= 1 ? ∂(collect(zip(datax, ∂1data)), 2) : nothing
    ∂3data = maxderivative >= 2 ? ∂(collect(zip(datax, ∂2data)), 3) : nothing
    ∂4data = maxderivative >= 3 ? ∂(collect(zip(datax, ∂3data)), 4) : nothing
    derivatives = DerivativesData(∂1data, ∂2data, ∂3data, ∂4data)

    validzeros = mfilter(derivatives, dselector, mfilter_params)

    validzeros
end

end