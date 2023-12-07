using DataFrames
using CSV

const DEFAULT_DATA_DIR = "data"
const DEFAULT_DATA_FILE = "data/mit_bih_arrhythmia_5k.csv"

function csv2df(path::String=DEFAULT_DATA_FILE)::DataFrame
    CSV.File(path) |> DataFrame
end

function listfiles(dir::String=DEFAULT_DATA_DIR)::Vector{String}
    filter(f -> endswith(f, ".csv"), readdir(dir)) |> collect
end