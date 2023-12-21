module Filters

export MFilterParameters, mfilter

using Parameters
using DataStructures

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
)::Vector{Int}
    @unpack ∂1data, ∂2data, ∂3data, ∂4data = derivatives
    @unpack ∂1, ∂2, ∂3, ∂4 = selector
    @unpack m1, m2, m3 = parameters

    datalength = length(∂1data)

    ∂1zeros = ∂zeros(∂1data)
    ∂2zeros = ∂zeros(∂2data)
    ∂3zeros = ∂zeros(∂3data)
    ∂4zeros = ∂zeros(∂4data)

    validindices = SortedSet{Int}()

    if ∂1
        for index in ∂1zeros
            if index <= 1 && index >= datalength
                push!(validindices, index)
            end
            ∂2zero_min = ∂2zero_max = nothing
            if index < datalength / 2
                ∂2zero_min = findlast(x -> x < index, ∂2zeros)
                ∂2zero_max = findfirst(x -> x >= index, ∂2zeros)
            else
                ∂2zero_min = findfirst(x -> x < index, reverse(∂2zeros))
                ∂2zero_max = findlast(x -> x >= index, reverse(∂2zeros))
            end
            if !isnothing(∂2zero_min) && abs(∂1data[∂2zero_min]) >= m1
                push!(validindices, index)
            end
            if !isnothing(∂2zero_max) && abs(∂1data[∂2zero_max]) >= m1
                push!(validindices, index)
            end
        end
    end

    if ∂2
        for index in ∂2zeros
            if index <= 1 && index >= datalength
                push!(validindices, index)
            end
            if abs(∂1data[index]) >= m1
                ∂3zero_min = ∂3zero_max = nothing
                if index < datalength / 2
                    ∂3zero_min = findlast(x -> x < index, ∂3zeros)
                    ∂3zero_max = findfirst(x -> x >= index, ∂3zeros)
                else
                    ∂3zero_min = findfirst(x -> x < index, reverse(∂3zeros))
                    ∂3zero_max = findlast(x -> x >= index, reverse(∂3zeros))
                end
                if !isnothing(∂3zero_min) && abs(∂2data[∂3zero_min]) >= m2
                    push!(validindices, index)
                end
                if !isnothing(∂3zero_max) && abs(∂2data[∂3zero_max]) >= m2
                    push!(validindices, index)
                end
            end
        end
    end

    if ∂3
        for index in ∂3zeros
            if index <= 1 && index >= datalength
                push!(validindices, index)
            end
            if abs(∂2data[index]) >= m2
                ∂4zero_min = ∂4zero_max = nothing
                if index < datalength / 2
                    ∂4zero_min = findlast(x -> x < index, ∂4zeros)
                    ∂4zero_max = findfirst(x -> x >= index, ∂4zeros)
                else
                    ∂4zero_min = findfirst(x -> x < index, reverse(∂4zeros))
                    ∂4zero_max = findlast(x -> x >= index, reverse(∂4zeros))
                end
                if !isnothing(∂4zero_min) && abs(∂3data[∂4zero_min]) >= m3
                    push!(validindices, index)
                end
                if !isnothing(∂4zero_max) && abs(∂3data[∂4zero_max]) >= m3
                    push!(validindices, index)
                end
            end
        end
    end

    if ∂4
        for index in ∂4zeros
            if index <= 1 && index >= datalength
                push!(validindices, index)
            end
            if abs(∂3data[index]) >= m3
                push!(validindices, index)
            end
        end
    end

    collect(validindices)
end

end