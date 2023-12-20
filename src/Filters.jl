module Filters

using FlexPoints

mutable struct MFilterParameters
    m1::Float64
    m2::Float64
    m3::Float64
end

function mfilter(
    derivatives::DerivativesData,
    selector::DerivativesSelector,
    parameters::MFilterParameters
)::Vector{Float64}

end

end