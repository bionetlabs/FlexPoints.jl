module GUI

export plotdata

using GLMakie
using Colors

using FlexPoints

function plotdata(;
    resolution=primary_resolution(), darkmode=true
)
    figure = createfigure(resolution, darkmode)
  
    lines, points = drawgraph(figure)

    darkmode, colorpicker = drawmenu(figure)

    connect(figure, darkmode, colorpicker, lines, points)

    figure
end

function connect(figure, darkmode, colorpicker, lines, points)
    on(c -> points.color = c, colorpicker.selection)
    notify(colorpicker.selection)

    on(mode -> applymode(figure, mode), darkmode.active)
    notify(darkmode.active)
end

function drawgraph(figure)
    scene = LScene(
        figure[1, 2],
        show_axis=true,
        scenekw = (
            clear=true,
            backgroundcolor=:black
        )
    )

    cam2d!(scene.scene)

    xs = LinRange(0, 10, 130)
    ys = 0.5 .* sin.(xs)

    lines = scatterlines!(scene, xs, ys, color=:green, markersize=0)

    data = collect(zip(xs, ys))
    indices = flexpoints(data, (true, true, true, true))
    points = [data[i...] for i in indices]

    points = scatter!(scene, points, color=:white, markersize=8)

    lines, points
end

function drawmenu(figure)
    darkmode = Toggle(figure, active=true)
    darkmode_label = Label(figure, lift(x -> x ? "dark mode" : "light mode", darkmode.active))

    colorpicker = Menu(figure, options = ["blue", "green", "white"], default = "white")
    
    figure[1, 1] = vgrid!(
        darkmode_label, darkmode,
        Label(figure, "Colormap", width = nothing), colorpicker,
        tellheight = false, width = 200
    )

    darkmode, colorpicker
end

function createfigure(resolution::Tuple{Integer, Integer}, darkmode::Bool)
    if darkmode
        set_theme!(theme_black(), resolution=resolution)
    else
        set_theme!(theme_light(), resolution=resolution)
    end

    GLMakie.activate!(; 
        fullscreen=true,
        framerate=120,
        fxaa=true,
        title="FlexPoints",
        vsync=true
    )

    figure = Figure(figure_padding=1)

    figure
end

function applymode(figure, darkmode::Bool)
    if darkmode
        figure.scene.theme = theme_black()
        figure.scene.backgroundcolor = parse(RGBA, figure.scene.theme.Axis.backgroundcolor[])
    else
        figure.scene.theme = theme_light()
        figure.scene.backgroundcolor = parse(RGBA, figure.scene.theme.Axis.backgroundcolor[])
    end
end

function primary_resolution()
    monitor = GLMakie.GLFW.GetPrimaryMonitor()
    videomode = GLMakie.MonitorProperties(monitor).videomode
    return (videomode.width, videomode.height)
end

end