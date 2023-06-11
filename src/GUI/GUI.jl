module GUI

export gui

using GLMakie
using Colors

import FreeTypeAbstraction.FTFont

using FlexPoints

include("widgets.jl")

struct UIState
    figure::Figure
    topbar::GridLayout
    leftpanel::GridLayout
    centralpanel::GridLayout
    rightpanel::GridLayout
    bottombar::GridLayout
end

function gui(;
    resolution=primary_resolution(), darkmode=true
)
    uistate = prepareui(resolution, darkmode)
  
    scene, lines, points = drawgraph(uistate.centralpanel)

    drawmenu(uistate.topbar)

    # connect(scene, darkmode, colorpicker, lines, points)

    uistate.figure
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
    
    tag(topbar[1, 1], "▤|dataload")
    tag(topbar[1, 2], "⛁|data")
    tag(topbar[1, 3], "❉|data")
    tag(topbar[1, 4], "|data")
    tag(topbar[1, 5], "䷀ 3D ䷀")
    Box(topbar[1, 6], color=RGBAf(0, 0, 0, 0), height=BUTTON_HEIGHT, strokevisible=false)
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

function prepareui(resolution::Tuple{Integer, Integer}, darkmode::Bool)::UIState
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

    
    loadfonts()

    figure = Figure(figure_padding=5)

    topbar = figure[1, 1:3] = GridLayout(alignmode=Outside(LAYOUT_PADDING))
    leftpanel = figure[2, 1] = GridLayout()
    centralpanel = figure[2, 2] = GridLayout()
    rightpanel = figure[2, 3] = GridLayout()
    bottombar = figure[3, 1:3] = GridLayout()
    
    UIState(
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

function loadfonts()
    fonts = Dict{Symbol, FTFont}()
    fontspath = joinpath("asset", "font")
    for fontfile in readdir(fontspath)
        fontpath = joinpath(fontspath, fontfile)
        if isfile(fontpath)
            font = GLMakie.to_font(fontpath)
            fontid = Symbol(lowercase(font.family_name), "_", lowercase(font.style_name))
            fonts[fontid] = font
        end
    end
    

    update_theme!(
        fonts=NamedTuple{Tuple(keys(fonts))}(values(fonts))
    )

    @info "available fonts", keys(fonts)
end

end