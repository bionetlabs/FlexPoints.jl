module GUI

export gui

using GLMakie
using Colors
using DataFrames

import FreeTypeAbstraction.FTFont

using FlexPoints

include("widgets.jl")

function gui(;
    resolution=primary_resolution(), darkmode=true
)
    uistate = initui(darkmode, resolution)
    appstate = AppState(uistate, DataFrame())

    uistate.figure
end

function drawmenu(uistate::UIState)
    topbar = uistate.topbar
    layout = topbar.layout

    daynight(uistate)
    tagexclusive(layout[1, 2], "▤ dataload", topbar.state, 1)
    tagexclusive(layout[1, 3], "⛁ data", topbar.state, 2)
    tagexclusive(layout[1, 4], "❉ data", topbar.state, 3)
    tagexclusive(layout[1, 5], " data", topbar.state, 4)
    tag(layout[1, 6], "䷀ 3D ䷀", Observable(true))
    Box(layout[1, 7], color=RGBAf(0, 0, 0, 0), height=BUTTON_HEIGHT, strokevisible=false)
end

function drawgraph(uistate::UIState)::Axis
    figure = uistate.centralpanel
    style = currentstyle(uistate)

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

    xs = LinRange(0, 100, 1000)
    ys = 1.5 .* sin.(xs)

    signallines = scatterlines!(axis, xs, ys, color=style.signalcolor, markersize=0)

    data = collect(zip(xs, ys))
    indices = flexpoints(data, (true, true, true, true))
    points = [data[i...] for i in indices]

    flexpointslines = scatterlines!(axis, points, color=style.flexpointcolor, markersize=12, linestyle=:dot)

    uistate.graph[] = axis
    axis
end

function initui(darkmode::Bool, resolution::Tuple{Integer,Integer}=primary_resolution())::UIState
    GLMakie.activate!(;
        fullscreen=true,
        framerate=120,
        fxaa=true,
        title="FlexPoints",
        vsync=true,
    )

    makeui(darkmode, resolution)
end

function makeui(darkmode::Bool, resolution::Tuple{Integer,Integer}=primary_resolution())::UIState
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

    uistate = UIState(
        figure,
        topbar,
        leftpanel,
        centralpanel,
        rightpanel,
        bottombar,
        Observable(true),
        Styles(),
        Ref{Union{Nothing,Axis}}(nothing),
        primary_resolution()
    )

    drawgraph(uistate)
    drawmenu(uistate)

    uistate
end

function resetui(uistate::UIState, darkmode::Bool)
    empty!(uistate.figure)

    if darkmode
        set_theme!(theme_black(), size=uistate.resolution)
    else
        set_theme!(theme_light(), size=uistate.resolution)
    end

    loadfonts()

    uistate.figure = Figure(figure_padding=0)
    figure = uistate.figure
    topbarlayout = figure[1, 1:3] = GridLayout(alignmode=Outside(LAYOUT_PADDING))
    uistate.topbar = TopBarState(
        topbarlayout, Observable([false, true, false, false, false]))
    uistate.leftpanel = figure[2, 1] = GridLayout()
    uistate.centralpanel = figure[2, 2] = GridLayout()
    uistate.rightpanel = figure[2, 3] = GridLayout()
    uistate.bottombar = figure[3, 1:3] = GridLayout()

    colsize!(figure.layout, 1, Auto(15.0))
    colsize!(figure.layout, 2, Auto(100.0))
    colsize!(figure.layout, 3, Auto(15.0))
    rowsize!(figure.layout, 1, Fixed(TOP_BAR_HEIGHT))
    rowsize!(figure.layout, 2, Auto(1.0))
    rowsize!(figure.layout, 3, Fixed(TOP_BAR_HEIGHT))

    drawgraph(uistate)
    drawmenu(uistate)

    close(display(uistate.figure))
    display(uistate.figure)
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