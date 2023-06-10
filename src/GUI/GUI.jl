module GUI

export plotdata

using GLMakie
using Colors

using FlexPoints

include("consts.jl")

struct AppLayout
    figure::Figure
    topbar::GridLayout
    leftpanel::GridLayout
    centralpanel::GridLayout
    rightpanel::GridLayout
    bottombar::GridLayout
end

function plotdata(;
    resolution=primary_resolution(), darkmode=true
)
    applayout = layout(resolution, darkmode)
  
    scene, lines, points = drawgraph(applayout.centralpanel)

    drawmenu(applayout.topbar)

    # connect(scene, darkmode, colorpicker, lines, points)

    applayout.figure
end

function connect(scene, darkmode, colorpicker, lines, points)
    on(c -> points.color = c, colorpicker.selection)
    notify(colorpicker.selection)

    on(mode -> applymode(scene, mode), darkmode.active)
    notify(darkmode.active)
end

function drawmenu(topbar)
    # darkmode = Toggle(figure, active=true)
    # darkmode_label = Label(figure, lift(x -> x ? "dark mode" : "light mode", darkmode.active))

    # colorpicker = Menu(figure, options = ["blue", "green", "white"], default = "white")
    
    Button(topbar[1, 1], label="Data", height=BUTTON_HEIGHT)
    Button(topbar[1, 2], label="Data", height=BUTTON_HEIGHT)
    Box(topbar[1, 3], color=RGBAf(0, 0, 0, 0), height=BUTTON_HEIGHT, strokevisible=false)
    # figure[1, 1] = hgrid!(
    #     Button(figure, label="Data", height=BUTTON_HEIGHT),
    #     # darkmode_label, darkmode,
    #     # Label(figure, "Colormap", width = nothing), colorpicker,
    #     Box(figure, color=RGBAf(0, 0, 0, 0)),
    #     tellheight=true, height=TOP_BAR_HEIGHT
    # )

    # colorpicker
end

function drawgraph(figure)
    scene = LScene(
        figure[2, 1],
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

    scene, lines, points
end

function layout(resolution::Tuple{Integer, Integer}, darkmode::Bool)::AppLayout
    if darkmode
        set_theme!(theme_dark(), resolution=resolution)
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

    figure = Figure(figure_padding=5)

    topbar = figure[1, 1:3] = GridLayout()
    leftpanel = figure[2, 1] = GridLayout()
    centralpanel = figure[2, 2] = GridLayout()
    rightpanel = figure[2, 3] = GridLayout()
    bottombar = figure[3, 1:3] = GridLayout()

    # colsize!(figure.layout, 1, Relative(1))
    # rowsize!(figure.layout, 1, Fixed(TOP_BAR_HEIGHT))

    # colgap!(figure.layout, 0)
    # rowgap!(figure.layout, 0)

    
    AppLayout(
        figure,
        topbar,
        leftpanel,
        centralpanel,
        rightpanel,
        bottombar,
    )
end

function applymode(scene, darkmode::Bool)
    if darkmode
        scene.scene.backgroundcolor = parse(RGBA, theme_black().backgroundcolor[])
    else
        scene.scene.backgroundcolor = colorant"white"
    end
end

function primary_resolution()
    monitor = GLMakie.GLFW.GetPrimaryMonitor()
    videomode = GLMakie.MonitorProperties(monitor).videomode
    return (videomode.width, videomode.height)
end

end