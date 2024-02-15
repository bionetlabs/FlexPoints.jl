#!/bin/sh
julia -O3 -tauto --load $(dirname $0)/../server.jl --project -J$(dirname $0)/../sysimage/FlexPoints.so