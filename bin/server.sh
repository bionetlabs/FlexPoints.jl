#!/bin/bash
julia --color=yes --depwarn=no --project=@. -q -i -- $(dirname $0)/../server.jl s "$@"