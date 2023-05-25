module Measures

export cf, rmse, nrmse, minrmse, prd, nprd, qs, nqs

using Statistics

using FlexPoints

"Compression Factor (CF)"
function cf(inputsize::Integer, outputsize::Integer)::Float64
    @assert inputsize > 0
    @assert outputsize > 0
    convert(Float64, inputsize / outputsize)
end

"Compression Factor (CF)"
function cf(data::Points2D, samples::Points2D)
    cf(length(data), length(samples))
end

"Root Mean Square Error (RMSE)"
function rmse(data::Points2D, samples::Points2D)::Float64
    @assert !isempty(data)
    @assert !isempty(samples)

    yapprox = []
    for (xi, _yi) in data
        push!(yapprox, linapprox(samples, xi))
    end
    
    errorsum = 0.0
    for (i, yi_approx) in enumerate(yapprox)
        yi = data[i][2]
        errorsum += (yi - yi_approx)^2
    end

    √(errorsum / length(data))
end

"Normalized Root Mean Square Error (NRMSE)"
function nrmse(data::Points2D, samples::Points2D)::Float64
    @assert !isempty(data)
    @assert !isempty(samples)

    yapprox = []
    for (xi, _yi) in data
        push!(yapprox, linapprox(samples, xi))
    end
    
    numerator = 0.0
    denominator = 0.0
    for (i, yi_approx) in enumerate(yapprox)
        yi = data[i][2]
        numerator += (yi - yi_approx)^2
        denominator += yi^2
    end

    √(numerator / denominator)
end

"Mean Independent Normalized Root Mean Square Error (MINRMSE)"
function minrmse(data::Points2D, samples::Points2D)::Float64
    @assert !isempty(data)
    @assert !isempty(samples)

    yapprox = []
    y = []
    for (xi, yi) in data
        push!(yapprox, linapprox(samples, xi))
        push!(y, yi)
    end
    ymean = mean(y)
    
    numerator = 0.0
    denominator = 0.0
    for (i, yi_approx) in enumerate(yapprox)
        yi = y[i]
        numerator += (yi - yi_approx)^2
        denominator += (yi - ymean)^2
    end

    √(numerator / denominator)
end

"Percentage Root mean square Difference (PRD)"
function prd(data::Points2D, samples::Points2D)::Float64
    nrmse(data, samples) * 100.0
end

"Normalized Percentage Root mean square Difference (NPRD)"
function nprd(data::Points2D, samples::Points2D)::Float64
    minrmse(data, samples) * 100.0
end

"Quality Score (QS)"
function qs(data::Points2D, samples::Points2D)::Float64
    cf(data, samples) / prd(data, samples)
end

"Normalized Quality Score (NQS)"
function nqs(data::Points2D, samples::Points2D)::Float64
    cf(data, samples) / nprd(data, samples)
end

end