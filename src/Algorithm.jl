module Algorithm

export flexpoints, FlexPointsParameters

using Parameters
using Statistics

using FlexPoints

@with_kw struct FlexPointsParameters
    noisefilter::NoiseFilterParameters = NoiseFilterParameters()
    mfilter::MFilterParameters = MFilterParameters()
    mspp::Unsigned = 5 # minimum samples per period
    frequency::Unsigned = 360 # number of samples of signal per second 
    devv::Float64 = 0.6 # statistical measure for outliers in terms of standard deviation
end

function flexpointsremoval(
    data::Vector{Float64},
    points::Vector{Int},
    params::FlexPointsParameters
)::Vector{Int}
    outliersremove(data, points, params)
end

function outliersremove(
    data::Vector{Float64},
    points::Vector{Int},
    params::FlexPointsParameters
)::Vector{Int}
    @unpack mspp, frequency, devv = params
    blank = frequency / mspp # max size of the blank space - space on x axis without samples
    datamean = mean(data)
    datastd = std(data)
    highoutlier = datamean + devv * datastd
    lowoutlier = datamean - devv * datastd
    removeo = []

    current = 0 # current counts in which windows outliers are specified

    points
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

    datafiltered = if params.noisefilter.data
        noisefilter(datay, params.noisefilter.filtersize)
    else
        datay
    end

    ∂1data = maxderivative >= 1 ? ∂(collect(zip(datax, datafiltered)), 1) : nothing
    ∂2data = maxderivative >= 1 ? ∂(collect(zip(datax, ∂1data)), 2) : nothing
    ∂3data = maxderivative >= 2 ? ∂(collect(zip(datax, ∂2data)), 3) : nothing
    ∂4data = maxderivative >= 3 ? ∂(collect(zip(datax, ∂3data)), 4) .* 5 / 3 : nothing

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

    validpoints = flexpointsremoval(datafiltered, validzeros, params)

    datafiltered, validpoints
end

end