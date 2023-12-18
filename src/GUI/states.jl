using GLMakie
using DataFrames
using Parameters
using OrderedCollections

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

@with_kw mutable struct AppState
    figure::Figure
    topbar::TopBarState
    leftpanel::GridLayout
    centralpanel::GridLayout
    rightpanel::GridLayout
    bottombar::GridLayout
    nightmode::Observable{Bool} = Observable(true)
    styles::Styles = Styles()
    graph::Ref{Union{Nothing,Axis}} = nothing
    resolution::Tuple{Integer,Integer}
    datadir::Observable{String} = Observable("data")
    datasources::OrderedDict{Symbol,Observable{Bool}} = OrderedDict()
    dataframe::Observable{DataFrame} = Observable(DataFrame())
    series::OrderedDict{Symbol,Observable{Bool}} = OrderedDict()
    data::Observable{Vector{Float64}} = []
end

function applystyle!(appstate::AppState)
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

function dataframe!(appstate::AppState)
    for (name, active) in appstate.datasources
        if active[]
            df = csv2df(
                joinpath(appstate.datadir[], string(name))
            )
            appstate.dataframe[] = df
            appstate.series = OrderedDict(
                map(enumerate(names(df))) do (i, name)
                    state = if i == 1
                        appstate.data[] = df[!, name]
                        Symbol(name) => Observable(true)
                    else
                        Symbol(name) => Observable(false)
                    end
                    on(last(state)) do state
                        if state
                            appstate.data[] = df[!, name]
                        end
                    end
                    state
                end
            )
            return
        end
    end
end

function datasources!(appstate::AppState, files::Vector{String})
    sources = OrderedDict(map(f -> Symbol(f) => Observable(false), files))
    for (i, state) in enumerate(values(sources))
        if i == 1
            state[] = true
        end
        on(state) do state
            state && dataframe!(appstate)
        end
    end
    appstate.datasources = sources
end