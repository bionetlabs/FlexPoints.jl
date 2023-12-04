module GUI

export gui

using GLMakie
using Colors

import FreeTypeAbstraction.FTFont

using FlexPoints

include("state.jl")
include("widgets.jl")

mutable struct TopBarState
    layout::GridLayout
    state::Observable{Vector{Bool}}
end

struct UIState
    figure::Figure
    topbar::TopBarState
    leftpanel::GridLayout
    centralpanel::GridLayout
    rightpanel::GridLayout
    bottombar::GridLayout
    nightmode::Observable{Bool}
    styles::Styles
end

function gui(;
    resolution=primary_resolution(), darkmode=true
)
    uistate = prepareui(resolution, darkmode)

    scene, lines, points = drawgraph(uistate.centralpanel, resolution)

    drawmenu(uistate)

    uistate.figure
end

function drawmenu(uistate::UIState)
    figure = uistate.figure
    topbar = uistate.topbar
    layout = topbar.layout
    nightmode = uistate.nightmode
    styles = uistate.styles

    daynight(layout[1, 1], nightmode, figure, styles)
    tagexclusive(layout[1, 2], "▤ dataload", topbar.state, 1)
    tagexclusive(layout[1, 3], "⛁ data", topbar.state, 2)
    tagexclusive(layout[1, 4], "❉ data", topbar.state, 3)
    tagexclusive(layout[1, 5], " data", topbar.state, 4)
    tag(layout[1, 6], "䷀ 3D ䷀", Observable(true))
    Box(layout[1, 7], color=RGBAf(0, 0, 0, 0), height=BUTTON_HEIGHT, strokevisible=false)
end

function drawgraph(figure, resolution)
    # scene = LScene(
    #     figure[2, 1],
    #     show_axis=true,
    #     # height=resolution[2] / 2,
    #     # width=resolution[1] / 2,
    #     scenekw=(
    #         viewport=Rect(0, 0, resolution[1], resolution[2]),
    #         clear=false,
    #         backgroundcolor=:black,
    #     )
    # )
    # cam2d!(scene.scene)

    # size(figure[2, 1])
    axis = Axis(
        figure[1, 1],
        ylabel="signal [mV]",
        xlabel="time [ms]",
        # title="ECG",
        xrectzoom=false,
        yrectzoom=false,
        valign=:center,
        limits=(0, 50, -2, 2),
        xlabelfont=:juliamono_light,
        xticklabelfont=:juliamono_light,
        ylabelfont=:juliamono_light,
        yticklabelfont=:juliamono_light,
    )
    hidespines!(axis)
    # hidespines!(axis, :t, :r)

    xs = LinRange(0, 100, 1000)
    ys = 1.5 .* sin.(xs)

    lines = scatterlines!(axis, xs, ys, color=:green, markersize=0)

    data = collect(zip(xs, ys))
    indices = flexpoints(data, (true, true, true, true))
    points = [data[i...] for i in indices]

    points = scatter!(axis, points, color=:white, markersize=8)

    axis, lines, points
end

function prepareui(resolution::Tuple{Integer,Integer}, darkmode::Bool)::UIState
    GLMakie.activate!(;
        fullscreen=true,
        framerate=120,
        fxaa=true,
        title="FlexPoints",
        vsync=true
    )

    if darkmode
        set_theme!(theme_black(), size=resolution)
    else
        set_theme!(theme_light(), size=resolution)
    end

    loadfonts()

    figure = Figure(figure_padding=0)

    topbarlayout = figure[1, 1:3] = GridLayout(alignmode=Outside(LAYOUT_PADDING))
    topbar = TopBarState(
        topbarlayout, Observable([false, true, false, false, false]))

    leftpanel = figure[2, 1] = GridLayout()
    centralpanel = figure[2, 2] = GridLayout()
    rightpanel = figure[2, 3] = GridLayout()
    bottombar = figure[3, 1:3] = GridLayout()

    colsize!(figure.layout, 1, Auto(15.0))
    colsize!(figure.layout, 2, Auto(100.0))
    colsize!(figure.layout, 3, Auto(15.0))

    rowsize!(figure.layout, 1, Fixed(TOP_BAR_HEIGHT))
    rowsize!(figure.layout, 2, Auto(1.0))
    rowsize!(figure.layout, 3, Fixed(TOP_BAR_HEIGHT))

    state = UIState(
        figure,
        topbar,
        leftpanel,
        centralpanel,
        rightpanel,
        bottombar,
        Observable(true),
        Styles()
    )

    state
end

function primary_resolution()
    monitor = GLMakie.GLFW.GetPrimaryMonitor()
    videomode = GLMakie.MonitorProperties(monitor).videomode
    return (videomode.width, videomode.height)
end

function loadfonts()
    fonts = Dict{Symbol,FTFont}()
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