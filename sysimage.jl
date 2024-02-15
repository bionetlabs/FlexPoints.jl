using Pkg

rootdir = @__DIR__

Pkg.activate(rootdir)
Pkg.instantiate()
Pkg.precompile()

using PackageCompiler

precompilationsfile = joinpath(rootdir, "sysimage/precompilations.jl")
if isfile(precompilationsfile)
    create_sysimage(
        ["FlexPoints"];
        sysimage_path=joinpath(rootdir, "sysimage/FlexPoints.so"),
        incremental=true,
        precompile_execution_file=precompilationsfile
    )
else
    create_sysimage(
        ["FlexPoints"];
        sysimage_path=joinpath(rootdir, "sysimage/FlexPoints.so"),
        incremental=true
    )
end

exit()