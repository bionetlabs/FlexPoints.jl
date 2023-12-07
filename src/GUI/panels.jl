using Match
using GLMakie

include("widgets.jl")

function drawpanels(appstate::AppState)
    drawleftpanel(appstate)
    on(appstate.topbar.leftpanel) do _state
        drawleftpanel(appstate)
    end
    drawrightpanel(appstate)
    on(appstate.topbar.rightpanel) do _state
        drawrightpanel(appstate)
    end
end

function drawleftpanel(appstate::AppState)
    state = appstate.topbar.leftpanel[]
    panel = appstate.leftpanel
    clearpanel!(panel)
    @match state begin
        $sources => drawsources(appstate)
        $samples => drawsamples(appstate)
        $algorithms => drawalgorithms(appstate)
        nothing => nothing
    end
end

function drawrightpanel(appstate::AppState)
    state = appstate.topbar.rightpanel[]
    panel = appstate.rightpanel
    clearpanel!(panel)
    @match state begin
        $results => drawresults(appstate)
        $settings => drawsettings(appstate)
        nothing => nothing
    end
end

function clearpanel!(panel::GridLayout)
    for c in contents(panel)
        delete!(c)
    end
    trim!(panel)
end

function drawsources(appstate::AppState)
    target = appstate.leftpanel
    index = Ref(0)
    style = currentstyle(appstate)
    header(target[nextint(index), 1], "⛁ sources", style)
    list(
        target,
        listfiles(),
        index,
        Observable([true, false, false]),
        1,
        style
    )
    expander(target[nextint(index), 1])
end

function drawsamples(appstate::AppState)
    target = appstate.leftpanel
    header(target[1, 1], "𝝣 samples", currentstyle(appstate))
    expander(target[2, 1])
end

function drawalgorithms(appstate::AppState)
    target = appstate.leftpanel
    header(target[1, 1], "∂ algorithms", currentstyle(appstate))
    expander(target[2, 1])
end

function drawresults(appstate::AppState)
    target = appstate.rightpanel
    header(target[1, 1], "ஃ results", currentstyle(appstate))
    expander(target[2, 1])
end

function drawsettings(appstate::AppState)
    target = appstate.rightpanel
    header(target[1, 1], "🞿 settings", currentstyle(appstate))
    expander(target[2, 1])
end