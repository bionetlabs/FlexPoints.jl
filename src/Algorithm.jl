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
    devv::Float64 = 1.0 # statistical measure for outliers in terms of standard deviation
    removeoutliers::Bool = true
    yresolution::Float64 = 0.025 # values with smaller Δ are considered as one point 
end

function flexpointsremoval(
    data::Vector{Float64},
    points::Vector{Int},
    params::FlexPointsParameters
)::Vector{Int}
    if params.removeoutliers
        points = outliersremove(data, points, params)
    end
    yresolution(data, points, params)
end

function outliersremove(
    data::Vector{Float64},
    points::Vector{Int},
    params::FlexPointsParameters
)::Vector{Int}
    @unpack mspp, frequency, devv = params
    blank = frequency / mspp # max size of the blank space - space on x axis without samples
    winmean = mean(data)
    winstd = std(data)
    highoutlier = winmean + devv * winstd
    lowoutlier = winmean - devv * winstd
    toremove = []

    current = 0 # current counts in which windows outliers are specified
    for i in 2:(length(points)-1)
        if ceil(points[i]/frequency)>current && 0<=length(data)-(current+1)*frequency
            currentdata = data[UInt(current*frequency+1):UInt(current+1*frequency)]
            winmean=mean(currentdata)
            winstd=std(currentdata)
            highoutlier=winmean+devv*winstd;
            lowoutlier=winmean-devv*winstd;
            current=ceil(points[i]/frequency);
        end
        if abs(data[points[i]])>highoutlier && (data[points[i]]-data[points[i]-1])*(data[points[i]]-data[points[i]+1])<0
            push!(toremove, i)
        elseif abs(data[points[i]])<lowoutlier && (data[points[i]]-data[points[i]-1])*(data[points[i]]-data[points[i]+1])<0
            push!(toremove, i)
        end
    end

    filter(p -> !(p in toremove), points) |> collect
end

function yresolution(
    data::Vector{Float64},
    points::Vector{Int},
    params::FlexPointsParameters
)::Vector{Int}
    @unpack yresolution = params
    toremove = []

    valuebefore = data[first(points)]
    for point in points[2:end-1]
        value = data[point]
        if abs(value - valuebefore) < yresolution
            push!(toremove, point)
        else
            valuebefore = value
        end
    end

    filter(p -> !(p in toremove), points) |> collect
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
            ∂1data = noisefilter(∂1data, UInt(max(params.noisefilter.filtersize, 2)))
        end
        if !isnothing(∂2data) && !isempty(∂2data)
            ∂2data = noisefilter(∂2data, UInt(max(params.noisefilter.filtersize ÷ 2, 2)))
        end
        if !isnothing(∂3data) && !isempty(∂3data)
            ∂3data = noisefilter(∂3data, UInt(max(params.noisefilter.filtersize ÷ 3, 2)))
        end
        if !isnothing(∂4data) && !isempty(∂4data)
            ∂4data = noisefilter(∂4data, UInt(max(params.noisefilter.filtersize ÷ 4, 2)))
        end
    end

    derivatives = DerivativesData(∂1data, ∂2data, ∂3data, ∂4data)

    validpoints = mfilter(derivatives, dselector, params.mfilter)

    validpoints = flexpointsremoval(datafiltered, validpoints, params)    

    datafiltered, validpoints
end

end