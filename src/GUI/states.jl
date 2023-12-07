using GLMakie
using DataFrames

include("styles.jl")

@enum PanelIndex begin
    leftpanel = 1
    rightpanel = 3
end

@enum LeftPanelState begin
    sources = 1
    samples = 2
    algorithms = 3
end

@enum RightPanelState begin
    results = 1
    settings = 2
end

mutable struct TopBarState
    layout::GridLayout
    leftpanel::Observable{Union{LeftPanelState,Nothing}}
    rightpanel::Observable{Union{RightPanelState,Nothing}}
end

mutable struct AppState
    figure::Figure
    topbar::TopBarState
    leftpanel::GridLayout
    centralpanel::GridLayout
    rightpanel::GridLayout
    bottombar::GridLayout
    nightmode::Observable{Bool}
    styles::Styles
    graph::Ref{Union{Nothing,Axis}}
    resolution::Tuple{Integer,Integer}
    data::Dict{Symbol,DataFrame}
end

function applystyle(appstate::AppState)
    figure = appstate.figure
    nightmode = appstate.nightmode[]
    styles = appstate.styles
    axis = figure.current_axis[]
    backgroundcolor = figure.scene.backgroundcolor

    if nightmode
        style = styles.dark
        updatestyle!(styles.current, style)
        for (key, value) in style.theme.Axis
            getproperty(axis, key)[] = parseattribute(value[])
        end
        backgroundcolor[] = style.background
        axis.xlabelcolor[] = axis.ylabelcolor[] = style.ticklabelcolor
        axis.xticklabelcolor[] = axis.yticklabelcolor[] = style.ticklabelcolor
    else
        style = styles.light
        updatestyle!(styles.current, style)
        for (key, value) in style.theme.Axis
            getproperty(figure.current_axis[], key)[] = parseattribute(value[])
        end
        backgroundcolor[] = style.background
        axis.xlabelcolor[] = axis.ylabelcolor[] = style.ticklabelcolor
        axis.xticklabelcolor[] = axis.yticklabelcolor[] = style.ticklabelcolor
    end
end

currentstyle(appstate::AppState)::CurrentStyle = appstate.styles.current