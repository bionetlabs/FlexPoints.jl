using GLMakie
using DataFrames

include("styles.jl")

mutable struct TopBarState
    layout::GridLayout
    state::Observable{Vector{Bool}}
end

mutable struct UIState
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
end

mutable struct AppState
    ui::UIState
    data::DataFrame
end

function applystyle(uistate::UIState)
    figure = uistate.figure
    nightmode = uistate.nightmode[]
    styles = uistate.styles
    axis = figure.current_axis[]
    backgroundcolor = figure.scene.backgroundcolor

    if nightmode
        println("theme dark")
        style = styles.dark
        updatestyle!(styles.current, style)
        for (key, value) in style.theme.Axis
            println("updating $key => $(value[])")
            getproperty(axis, key)[] = parseattribute(value[])
        end
        backgroundcolor[] = style.background
        axis.xlabelcolor[] = axis.ylabelcolor[] = style.ticklabelcolor
        axis.xticklabelcolor[] = axis.yticklabelcolor[] = style.ticklabelcolor
    else
        println("theme light")
        style = styles.light
        updatestyle!(styles.current, style)
        for (key, value) in style.theme.Axis
            println("updating $key => $(value[])")
            getproperty(figure.current_axis[], key)[] = parseattribute(value[])
        end
        backgroundcolor[] = style.background
        axis.xlabelcolor[] = axis.ylabelcolor[] = style.ticklabelcolor
        axis.xticklabelcolor[] = axis.yticklabelcolor[] = style.ticklabelcolor
    end
end

currentstyle(uistate::UIState)::CurrentStyle = uistate.styles.current