using DataFrames
using CSV
using OrderedCollections

const DEFAULT_DATA_DIR = "data"
const DEFAULT_DATA_FILE = "data/mit_bih_arrhythmia_5k.csv"
const SAMPES_PER_SECOND = 360
const SAMPES_PER_MILLISECOND = SAMPES_PER_SECOND / 1000

function csv2df(
    path::String=DEFAULT_DATA_FILE;
    limit=20
)::DataFrame
    df = CSV.File(path) |> DataFrame
    if !isnothing(limit)
        df[:, 1:limit]
    else
        df
    end
end

function listfiles(dir::String=DEFAULT_DATA_DIR)::Vector{String}
    filter(f -> endswith(f, ".csv"), readdir(dir)) |> collect
end