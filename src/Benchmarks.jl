module Benchmarks

export benchmark, benchmarkthreads, MIT_BIH_ARRHYTHMIA_2K, MIT_BIH_ARRHYTHMIA_5K, MIT_BIH_ARRHYTHMIA_FULL

using DataFrames
using Statistics

using FlexPoints

const MIT_BIH_ARRHYTHMIA_2K = "data/mit_bih_arrhythmia_2k.csv"
const MIT_BIH_ARRHYTHMIA_5K = "data/mit_bih_arrhythmia_5k.csv"
const MIT_BIH_ARRHYTHMIA_FULL = "data/mit_bih_arrhythmia_full.csv"

function benchmark(
    datafile::String=MIT_BIH_ARRHYTHMIA_2K;
    parameters=FlexPointsParameters(),
    filteredreference::Bool=false
)::DataFrame
    println("loading $datafile")
    datadf = csv2df(datafile)
    cfs = []
    rmses = []
    nrmses = []
    minrmses = []
    prds = []
    nprds = []
    qss = []
    nqss = []
    seriesnames = []

    for seriesname in names(datadf)
        println("benchmarking $seriesname, threadid $(Threads.threadid())")
        ys = datadf[!, seriesname]
        datalen = length(ys)
        xs = LinRange(0, (datalen - 1) / SAMPES_PER_MILLISECOND, datalen)
        data = collect(zip(xs, ys))
        datafiltered, points = flexpoints(data, parameters)
        points2d = map(i -> (Float64(i), ys[i]), points)
        reconstruction = map(1:datalen) do x
            Float64(linapprox(points2d, x))
        end

        if filteredreference
            ys = datafiltered
        end
        push!(seriesnames, seriesname)
        cf_ = cf(ys, points)
        push!(cfs, cf_)
        push!(rmses, rmse(ys, reconstruction))
        push!(nrmses, nrmse(ys, reconstruction))
        push!(minrmses, minrmse(ys, reconstruction))
        prd_ = prd(ys, reconstruction)
        push!(prds, prd_)
        nprd_ = nprd(ys, reconstruction)
        push!(nprds, nprd_)
        push!(qss, qs(cf_, prd_))
        push!(nqss, nqs(cf_, nprd_))
    end

    push!(seriesnames, "mean")
    println(cfs, typeof(cfs))
    push!(cfs, mean(cfs))
    push!(rmses, mean(rmses))
    push!(nrmses, mean(nrmses))
    push!(minrmses, mean(minrmses))
    push!(prds, mean(prds))
    push!(nprds, mean(nprds))
    push!(qss, mean(qss))
    push!(nqss, mean(nqss))

    DataFrame(
        :lead => seriesnames,
        :cf => cfs,
        :rmse => rmses,
        :nrmse => nrmses,
        :minrmse => minrmses,
        :prd => prds,
        :nprd => nprds,
        :qs => qss,
        :nqs => nqss,
    )
end

function benchmarkthreads(
    datafile::String=MIT_BIH_ARRHYTHMIA_2K;
    parameters=FlexPointsParameters(),
    filteredreference::Bool=false
)::DataFrame
    println("loading $datafile")
    datadf = csv2df(datafile)
    cfs = []
    rmses = []
    nrmses = []
    minrmses = []
    prds = []
    nprds = []
    qss = []
    nqss = []
    seriesnames = []

    mutex = ReentrantLock()
    Threads.@threads for seriesname in names(datadf)
        println("benchmarking $seriesname, threadid $(Threads.threadid())")
        ys = datadf[!, seriesname]
        datalen = length(ys)
        xs = LinRange(0, (datalen - 1) / SAMPES_PER_MILLISECOND, datalen)
        data = collect(zip(xs, ys))
        datafiltered, points = flexpoints(data, parameters)
        points2d = map(i -> (Float64(i), ys[i]), points)
        reconstruction = map(1:datalen) do x
            Float64(linapprox(points2d, x))
        end

        if filteredreference
            ys = datafiltered
        end
        lock(mutex)
        try
            push!(seriesnames, seriesname)
            cf_ = cf(ys, points)
            push!(cfs, cf_)
            push!(rmses, rmse(ys, reconstruction))
            push!(nrmses, nrmse(ys, reconstruction))
            push!(minrmses, minrmse(ys, reconstruction))
            prd_ = prd(ys, reconstruction)
            push!(prds, prd_)
            nprd_ = nprd(ys, reconstruction)
            push!(nprds, nprd_)
            push!(qss, qs(cf_, prd_))
            push!(nqss, nqs(cf_, nprd_))
        finally
            unlock(mutex)
        end
    end

    push!(seriesnames, "mean")
    println(cfs, typeof(cfs))
    push!(cfs, mean(cfs))
    push!(rmses, mean(rmses))
    push!(nrmses, mean(nrmses))
    push!(minrmses, mean(minrmses))
    push!(prds, mean(prds))
    push!(nprds, mean(nprds))
    push!(qss, mean(qss))
    push!(nqss, mean(nqss))

    DataFrame(
        :lead => seriesnames,
        :cf => cfs,
        :rmse => rmses,
        :nrmse => nrmses,
        :minrmse => minrmses,
        :prd => prds,
        :nprd => nprds,
        :qs => qss,
        :nqs => nqss,
    )
end

end