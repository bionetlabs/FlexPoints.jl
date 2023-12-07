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
    uistate = initui(darkmode, resolution)
    appstate = AppState(uistate, DataFrame())

    uistate.figure
end

function drawmenu(uistate::UIState)
    topbar = uistate.topbar
    layout = topbar.layout
    style = currentstyle(uistate)
    index = Ref(0)

    sourcesbutton = tagenum(layout[1, nextint(index)], "⛁ sources", topbar.leftpanel, sources, style)
    panelcontrol(uistate, sourcesbutton, leftpanel)
    samplesbutton = tagenum(layout[1, nextint(index)], "𝝣 samples", topbar.leftpanel, samples, style)
    panelcontrol(uistate, samplesbutton, leftpanel)
    algorithmsbutton = tagenum(layout[1, nextint(index)], "∂ algorithms", topbar.leftpanel, algorithms, style)
    panelcontrol(uistate, algorithmsbutton, leftpanel)

    expander(layout[1, nextint(index)])
    daynight(uistate, layout[1, nextint(index)], layout[1, nextint(index)])
    expander(layout[1, nextint(index)])

    resultsbutton = tagenum(layout[1, nextint(index)], "ஃ results", topbar.rightpanel, results, style)
    panelcontrol(uistate, resultsbutton, rightpanel)
    settingsbutton = tagenum(layout[1, nextint(index)], "🞿 settings", topbar.rightpanel, settings, style)
    panelcontrol(uistate, settingsbutton, rightpanel)

    # separator(layout[1, nextint(index)], style)
end

function panelcontrol(uistate::UIState, button::Button, panelindex::PanelIndex)
    topbar = uistate.topbar
    on(button.clicks) do _
        panel = @match panelindex begin
            $leftpanel => topbar.leftpanel[]
            $rightpanel => topbar.rightpanel[]
        end
        if isnothing(panel)
            colsize!(uistate.figure.layout, Int(panelindex), Relative(0.0))
        else
            colsize!(uistate.figure.layout, Int(panelindex), Relative(0.1))
        end
    end
end

function drawgraph(uistate::UIState)::Axis
    figure = uistate.centralpanel
    style = currentstyle(uistate)

    axis = Axis(
        figure[:, :],
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

    signallines = lines!(axis, xs, ys, color=style.signalcolor)

    data = collect(zip(xs, ys))
    indices = flexpoints(data, (true, true, true, true))
    points = [data[i...] for i in indices]

    flexpointslines = scatterlines!(
        axis,
        points,
        color=style.flexpointcolor,
        linestyle=:dot,
        markersize=12,
        marker=:rect,
        strokewidth=0.5,
        strokecolor=style.disabledbuttoncolor
    )

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

    # rowsize!(leftpanel, 1, Relative(1.0))
    # rowsize!(rightpanel, 1, Relative(1.0))

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

    drawmenu(uistate)
    drawpanels(uistate)
    drawgraph(uistate)
    applystyle(uistate)

    uistate
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