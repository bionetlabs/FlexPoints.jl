module GUI

export gui

using GLMakie
using Colors
using DataFrames

import FreeTypeAbstraction.FTFont

using FlexPoints

include("panels.jl")
include("data.jl")

function gui(;
    resolution=primary_resolution(), darkmode=true
)
    appstate = initui(darkmode, resolution)

    appstate.figure
end

function drawmenu!(appstate::AppState)
    topbar = appstate.topbar
    layout = topbar.layout
    style = currentstyle(appstate)
    index = Ref(0)

    sourcesbutton = tagenum(layout[1, nextint(index)], "⛁ sources", topbar.leftpanel, sources, style)
    panelcontrol(appstate, sourcesbutton, leftpanel)
    samplesbutton = tagenum(layout[1, nextint(index)], "𝝣 samples", topbar.leftpanel, samples, style)
    panelcontrol(appstate, samplesbutton, leftpanel)
    algorithmsbutton = tagenum(layout[1, nextint(index)], "∂ algorithms", topbar.leftpanel, algorithms, style)
    panelcontrol(appstate, algorithmsbutton, leftpanel)

    expander(layout[1, nextint(index)])
    daynight(appstate, layout[1, nextint(index)], layout[1, nextint(index)])
    expander(layout[1, nextint(index)])

    resultsbutton = tagenum(layout[1, nextint(index)], "ஃ results", topbar.rightpanel, results, style)
    panelcontrol(appstate, resultsbutton, rightpanel)
    settingsbutton = tagenum(layout[1, nextint(index)], "🞿 settings", topbar.rightpanel, settings, style)
    panelcontrol(appstate, settingsbutton, rightpanel)

    # separator(layout[1, nextint(index)], style)
end

function panelcontrol(appstate::AppState, button::Button, panelindex::PanelIndex)
    topbar = appstate.topbar
    on(button.clicks) do _
        panel = @match panelindex begin
            $leftpanel => topbar.leftpanel[]
            $rightpanel => topbar.rightpanel[]
        end
        if isnothing(panel)
            colsize!(appstate.figure.layout, Int(panelindex), Relative(0.0))
        else
            colsize!(appstate.figure.layout, Int(panelindex), Relative(0.1))
        end
    end
end

function emptygraph!(appstate::AppState)::Axis
    figure = appstate.centralpanel

    axis = Axis(
        figure[:, :],
        ylabel="signal [mV]",
        xlabel="time [ms]",
        # title="ECG",
        xrectzoom=false,
        yrectzoom=false,
        valign=:center,
        limits=((0, 1350), (-3.5, 3.5)),
        xlabelfont=:juliamono_light,
        xticklabelfont=:juliamono_light,
        ylabelfont=:juliamono_light,
        yticklabelfont=:juliamono_light,
    )
    hidespines!(axis)

    appstate.graph[] = axis
    axis
end

function drawgraph!(appstate::AppState)::Axis
    appstate.centralpanel
    style = currentstyle(appstate)
    axis = appstate.graph[]
    empty!(axis)

    data = appstate.data[]
    xs = LinRange(0, (length(data) - 1) / SAMPES_PER_MILLISECOND, length(data))
    ys = data

    lines!(axis, xs, ys, color=style.signalcolor)

    data = collect(zip(xs, ys))
    indices = flexpoints(data, (true, true, true, true))
    points = [data[i...] for i in indices]

    scatterlines!(
        axis,
        points,
        color=style.flexpointcolor,
        linestyle=:dot,
        markersize=12,
        marker=:rect,
        strokewidth=0.5,
        strokecolor=style.disabledbuttoncolor
    )

    appstate.graph[] = axis
    axis
end

function initui(darkmode::Bool, resolution::Tuple{Integer,Integer}=primary_resolution())::AppState
    GLMakie.activate!(;
        fullscreen=true,
        framerate=120,
        fxaa=true,
        title="FlexPoints",
        vsync=true,
    )

    makeui(darkmode, resolution)
end

function makeui(darkmode::Bool, resolution::Tuple{Integer,Integer}=primary_resolution())::AppState
    if darkmode
        set_theme!(theme_black(), size=resolution)
    else
        set_theme!(theme_light(), size=resolution)
    end

    loadfonts()

    figure = Figure(figure_padding=0)

    topbarlayout = figure[1, 1:3] = GridLayout(alignmode=Outside(LAYOUT_PADDING))
    topbar = TopBarState(
        topbarlayout, Observable(algorithms), Observable(results))

    leftpanel = figure[2, 1] = GridLayout()
    centralpanel = figure[2, 2] = GridLayout()
    rightpanel = figure[2, 3] = GridLayout()
    bottombar = figure[3, 1:3] = GridLayout()

    colsize!(figure.layout, 1, Relative(0.1))
    colsize!(figure.layout, 2, Auto(1.0))
    colsize!(figure.layout, 3, Relative(0.1))

    rowsize!(figure.layout, 1, Fixed(TOP_BAR_HEIGHT))
    rowsize!(figure.layout, 2, Auto(false))
    rowsize!(figure.layout, 3, Fixed(TOP_BAR_HEIGHT))

    appstate = AppState(
        figure=figure,
        topbar=topbar,
        leftpanel=leftpanel,
        centralpanel=centralpanel,
        rightpanel=rightpanel,
        bottombar=bottombar,
        resolution=primary_resolution(),
    )

    drawmenu!(appstate)
    emptygraph!(appstate)
    drawpanels!(appstate)
    applystyle!(appstate)

    datasources!(appstate, listfiles(DEFAULT_DATA_DIR))
    dataframe!(appstate)

    for state in values(appstate.series)
        if state[]
            drawgraph!(appstate)
        end
        on(state) do state
            state && drawgraph!(appstate)
        end
    end

    appstate
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