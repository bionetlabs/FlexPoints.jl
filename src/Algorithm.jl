module Algorithm

export flexpoints, FlexPointsParameters

using Parameters

using FlexPoints

struct FlexPointsParameters
    noisefilter::NoiseFilterParameters
    mfilter::MFilterParameters
end

# Variable derivatives indicates which derivatives should be use
# e.g. if `derivatives = (true, false, true, false)` 
# then the first and the third derivative will be used.
function flexpoints(
    data::Points2D,
    dselector::DerivativesSelector,
    params::FlexPointsParameters
)::Tuple{Vector{Float64},Vector{Int}}
    @assert !isempty(data)
    requiredlen = length(data) ÷ 2 - 1
    maxderivative = topderivative(dselector)
    maxderivative == 0 && error("at least one derivative should be used")
    @assert requiredlen >= maxderivative

    datax = map(point -> x(point), data)
    datay = map(point -> y(point), data)

    ∂1data = maxderivative >= 1 ? ∂(data, 1) : nothing
    ∂2data = maxderivative >= 1 ? ∂(collect(zip(datax, ∂1data)), 2) : nothing
    ∂3data = maxderivative >= 2 ? ∂(collect(zip(datax, ∂2data)), 3) : nothing
    ∂4data = maxderivative >= 3 ? ∂(collect(zip(datax, ∂3data)), 4) : nothing

    datafiltered = if params.noisefilter.data
        noisefilter(datay, params.noisefilter.filtersize)
    else
        datay
    end

    if params.noisefilter.derivatives
        if !isnothing(∂1data) && !isempty(∂1data)
            ∂1data = noisefilter(∂1data, params.noisefilter.filtersize)
        end
        if !isnothing(∂2data) && !isempty(∂2data)
            ∂2data = noisefilter(∂2data, params.noisefilter.filtersize)
        end
        if !isnothing(∂3data) && !isempty(∂3data)
            ∂3data = noisefilter(∂3data, params.noisefilter.filtersize)
        end
        if !isnothing(∂4data) && !isempty(∂4data)
            ∂4data = noisefilter(∂4data, params.noisefilter.filtersize)
        end
    end

    derivatives = DerivativesData(∂1data, ∂2data, ∂3data, ∂4data)

    validzeros = mfilter(derivatives, dselector, params.mfilter)

    datafiltered, validzeros
end

end